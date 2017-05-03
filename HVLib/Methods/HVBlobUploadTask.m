//
//  HVBlobUploadTask.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#import "HVCommon.h"
#import "HVBlobUploadTask.h"
#import "HVBeginBlobPutTask.h"
#import "HVHttpRequestResponse.h"
#import "HVDirectory.h"

//------------------------------
//
// HVBlobUpload
//
//------------------------------
@interface HVBlobUploadTask (HVPrivate)

-(void) beginPutBlobComplete:(HVTask *) task;
-(void) postNextChunk;
-(void) postChunkComplete:(HVTask *) task;
-(void) uploadComplete;

@end

@implementation HVBlobUploadTask

@synthesize source = m_source;
@synthesize delegate = m_delegate;
@synthesize record = m_record;

-(NSString *)blobUrl
{
    return (NSString *) self.result;
}

-(id)init
{
    return [self initWithSource:nil record:nil andCallback:nil];
}

-(id)initWithData:(NSData *)data record:(HVRecordReference *) record andCallback:(HVTaskCompletion)callback
{
    HVBlobMemorySource* blobSource = [[HVBlobMemorySource alloc] initWithData:data];
    self = [self initWithSource:blobSource record:record andCallback:callback];
    [blobSource release];
    
    return self;
}

-(id)initWithFilePath:(NSString *)filePath record:(HVRecordReference *) record  andCallback:(HVTaskCompletion)callback
{
    HVBlobFileHandleSource* blobSource = [[HVBlobFileHandleSource alloc] initWithFilePath:filePath];
    self = [self initWithSource:blobSource record:record andCallback:callback];
    [blobSource release];
    
    return self;    
}

-(id)initWithSource:(id<HVBlobSource>)source record:(HVRecordReference *) record  andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(source);
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_source = [source retain];
    m_record = [record retain];
    //
    // First, we'll issue an operation to retrieve a Blob Url.
    // This is the  blobUrl to which we'll push the blob
    // The app can subsequently 'commit' the blob by adding to an HVItem's Blob collection and saving it to HV
    //
    HVBeginBlobPutTask* beginPutTask = [[HVBeginBlobPutTask alloc] initWithCallback:^(HVTask *task) {
        [self beginPutBlobComplete:task];
    } ];
    
    beginPutTask.record = m_record;
    
    [self setNextTask:beginPutTask];
    [beginPutTask release];
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_putParams release];
    [m_source release];
    [m_blobUrl release];
    [m_record release];
    
    [super dealloc];
}

-(void)totalBytesWritten:(NSInteger)byteCount
{
    if (m_delegate)
    {
        [m_delegate totalBytesWritten:m_byteCountUploaded + byteCount];
    }
}

+(HVHttpRequestResponse *)newUploadRequestForUrl:(NSURL *)url withCallback:(HVTaskCompletion)callback
{
    HVHttpRequestResponse* postRequest = [[HVHttpRequestResponse alloc] initWithVerb:@"POST" url:url andCallback:callback]; 
    [postRequest.request setContentType:@"application/octet-stream"];
 
    return postRequest;    
}

+(void)addIsFinalUploadChunkHeaderTo:(NSMutableURLRequest *)request
{
    [request setValue:@"1" forHTTPHeaderField:@"x-hv-blob-complete"];
}

@end

@implementation HVBlobUploadTask (HVPrivate)

-(void)beginPutBlobComplete:(HVTask *)task
{
    HVBeginBlobPutTask* blobTask = (HVBeginBlobPutTask *) task;
    m_putParams = [blobTask.putParams retain];

    m_blobUrl = [[NSURL URLWithString:m_putParams.url] retain];
    HVCHECK_OOM(m_blobUrl);
    //
    // Now that we know where to write the blob to, and in what chunks, we can begin
    //
    [self postNextChunk];
}

-(void)postNextChunk
{
    HVHttpRequestResponse* postRequest = [HVBlobUploadTask newUploadRequestForUrl:m_blobUrl withCallback:^(HVTask *task) {
        
        [self postChunkComplete:task];
    }];
    HVCHECK_OOM(postRequest);
    
    postRequest.delegate = m_delegate;
    
    @try 
    {
        NSUInteger nextChunkSize = MIN(m_putParams.chunkSize, (m_source.length - m_byteCountUploaded));
        if (nextChunkSize > 0)
        {
            NSData* nextChunk = [m_source readStartAt:m_byteCountUploaded chunkSize:(int)nextChunkSize];
            postRequest.requestBody = nextChunk;
            
            [postRequest.request setContentRangeStart:m_byteCountUploaded end:(m_byteCountUploaded + nextChunkSize - 1)];
        }
        
        if (nextChunkSize <= m_putParams.chunkSize)
        {
            [HVBlobUploadTask addIsFinalUploadChunkHeaderTo:postRequest.request];
        }
        
        [self setNextTask:postRequest];
    }
    @finally 
    {
        [postRequest release];
    }    
}

-(void)postChunkComplete:(HVTask *)task
{
    HVHttpRequestResponse* putTask = (HVHttpRequestResponse *) task;
    [putTask checkSuccess];
    
    int chunkLength = (int)putTask.requestBody.length;
    [self totalBytesWritten:chunkLength];  // Notify delegates that we've completed writing these many bytes
    
    m_byteCountUploaded += chunkLength;
    if (m_byteCountUploaded < m_source.length)
    {
        [self postNextChunk];
        return;
    }
    
    [self uploadComplete];
}

-(void)uploadComplete
{
    self.result = m_putParams.url;
}
@end
