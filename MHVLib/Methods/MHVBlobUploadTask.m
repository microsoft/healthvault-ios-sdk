//
// MHVBlobUploadTask.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVCommon.h"
#import "MHVBlobUploadTask.h"
#import "MHVBeginBlobPutTask.h"
#import "MHVHttpRequestResponse.h"
#import "MHVDirectory.h"
#import "MHVClient.h"

// ------------------------------
//
// MHVBlobUpload
//
// ------------------------------
@interface MHVBlobUploadTask (MHVPrivate)

- (void)beginPutBlobComplete:(MHVTask *)task;
- (void)postNextChunk;
- (void)postChunkComplete:(MHVTask *)task;
- (void)uploadComplete;

@end

@implementation MHVBlobUploadTask

@synthesize source = m_source;
@synthesize record = m_record;

- (NSString *)blobUrl
{
    return (NSString *)self.result;
}

- (id)init
{
    return [self initWithSource:nil record:nil andCallback:nil];
}

- (id)initWithData:(NSData *)data record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
    
    self = [self initWithSource:blobSource record:record andCallback:callback];
    
    return self;
}

- (id)initWithFilePath:(NSString *)filePath record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobFileHandleSource *blobSource = [[MHVBlobFileHandleSource alloc] initWithFilePath:filePath];
    
    self = [self initWithSource:blobSource record:record andCallback:callback];
    
    return self;
}

- (id)initWithSource:(id<MHVBlobSource>)source record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(source);
    
    self = [super initWithCallback:callback];
    MHVCHECK_SELF;
    
    m_source = source;
    m_record = record;
    //
    // First, we'll issue an operation to retrieve a Blob Url.
    // This is the  blobUrl to which we'll push the blob
    // The app can subsequently 'commit' the blob by adding to an MHVItem's Blob collection and saving it to MHV
    //
    MHVBeginBlobPutTask *beginPutTask = [[MHVBeginBlobPutTask alloc] initWithCallback:^(MHVTask *task) {
        [self beginPutBlobComplete:task];
    } ];
    
    beginPutTask.record = m_record;
    
    [self setNextTask:beginPutTask];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

- (void)totalBytesWritten:(NSInteger)byteCount
{
    if (self.delegate)
    {
        [self.delegate totalBytesWritten:m_byteCountUploaded + byteCount];
    }
}

+ (MHVHttpRequestResponse *)newUploadRequestForUrl:(NSURL *)url withCallback:(MHVTaskCompletion)callback
{
    MHVHttpRequestResponse *postRequest = [[MHVHttpRequestResponse alloc] initWithVerb:@"POST" url:url andCallback:callback];
    
    [postRequest.request setContentType:@"application/octet-stream"];
    
    return postRequest;
}

+ (void)addIsFinalUploadChunkHeaderTo:(NSMutableURLRequest *)request
{
    [request setValue:@"1" forHTTPHeaderField:@"x-hv-blob-complete"];
}

@end

@implementation MHVBlobUploadTask (MHVPrivate)

- (void)beginPutBlobComplete:(MHVTask *)task
{
    MHVBeginBlobPutTask *blobTask = (MHVBeginBlobPutTask *)task;
    
    m_putParams = blobTask.putParams;
    
    m_blobUrl = [NSURL URLWithString:m_putParams.url];
    MHVCHECK_OOM(m_blobUrl);
    
    //
    // Now that we know where to write the blob to, and in what chunks, we can begin
    //
    
    MHVTask *nextTask = [[MHVTaskAsyncBlock alloc] initWithAsyncBlock:^(MHVTask *taskToComplete)
    {
        //TODO: Need to wrap httpService in MHVTask so the blob upload flow works. This can be simplified when tasks are removed
        [[MHVClient current].service.httpService uploadBlobSource:m_source
                                                            toUrl:m_blobUrl
                                                        chunkSize:m_putParams.chunkSize
                                                       completion:^(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error)
         {
             [self uploadComplete];
             
             [taskToComplete completeTask];
         }];
    }];
    
    [self setNextTask:nextTask];
}

- (void)postNextChunk
{
    MHVHttpRequestResponse *postRequest = [MHVBlobUploadTask newUploadRequestForUrl:m_blobUrl withCallback:^(MHVTask *task) {
        [self postChunkComplete:task];
    }];
    
    MHVCHECK_OOM(postRequest);
    
    postRequest.delegate = self.delegate;
    
    @try
    {
        NSUInteger nextChunkSize = MIN(m_putParams.chunkSize, (m_source.length - m_byteCountUploaded));
        if (nextChunkSize > 0)
        {
            NSData *nextChunk = [m_source readStartAt:m_byteCountUploaded chunkSize:(int)nextChunkSize];
            postRequest.requestBody = nextChunk;
            
            [postRequest.request setContentRangeStart:m_byteCountUploaded end:(m_byteCountUploaded + nextChunkSize - 1)];
        }
        
        if (nextChunkSize <= m_putParams.chunkSize)
        {
            [MHVBlobUploadTask addIsFinalUploadChunkHeaderTo:postRequest.request];
        }
        
        [self setNextTask:postRequest];
    }
    @finally
    {
        postRequest = nil;
    }
}

- (void)postChunkComplete:(MHVTask *)task
{
    MHVHttpRequestResponse *putTask = (MHVHttpRequestResponse *)task;
    
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

- (void)uploadComplete
{
    self.result = m_putParams.url;
}

@end
