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
#import "MHVDirectory.h"
#import "MHVClient.h"

// ------------------------------
//
// MHVBlobUpload
//
// ------------------------------
@interface MHVBlobUploadTask ()

@property (readwrite, nonatomic, strong) MHVBlobPutParameters* putParams;

@end

@implementation MHVBlobUploadTask

- (NSString *)blobUrl
{
    return (NSString *)self.result;
}

- (instancetype)init
{
    return [self initWithSource:nil record:nil andCallback:nil];
}

- (instancetype)initWithData:(NSData *)data record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
    
    self = [self initWithSource:blobSource record:record andCallback:callback];
    
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobFileHandleSource *blobSource = [[MHVBlobFileHandleSource alloc] initWithFilePath:filePath];
    
    self = [self initWithSource:blobSource record:record andCallback:callback];
    
    return self;
}

- (instancetype)initWithSource:(id<MHVBlobSourceProtocol>)source record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(source);
    
    self = [super initWithCallback:callback];
    if (self)
    {
        _source = source;
        _record = record;
        
        //
        // First, we'll issue an operation to retrieve a Blob Url.
        // This is the  blobUrl to which we'll push the blob
        // The app can subsequently 'commit' the blob by adding to an MHVItem's Blob collection and saving it to MHV
        //
        MHVBeginBlobPutTask *beginPutTask = [[MHVBeginBlobPutTask alloc] initWithCallback:^(MHVTask *task)
        {
            @try
            {
                [task checkSuccess];
                
                [self beginPutBlob:task];
            }
            @catch (NSException *exception)
            {
                [self completeTask];
            }
        }];
        
        beginPutTask.record = _record;
        
        [self setNextTask:beginPutTask];
    }
    return self;
}

#pragma mark - Internal methods

- (void)beginPutBlob:(MHVTask *)task
{
    MHVBeginBlobPutTask *blobTask = (MHVBeginBlobPutTask *)task;
    
    self.putParams = blobTask.putParams;
    
    //
    // Now that we know where to write the blob to, and in what chunks, we can upload the data
    //
    
    MHVTask *nextTask = [[MHVTaskAsyncBlock alloc] initWithAsyncBlock:^(MHVTask *taskToComplete)
    {
        //Wrap httpService in MHVTask so the blob upload flow works. This can be simplified when tasks are removed
        [[MHVClient current].service.httpService uploadBlobSource:self.source
                                                            toUrl:[NSURL URLWithString:self.putParams.url]
                                                        chunkSize:self.putParams.chunkSize
                                                       completion:^(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error)
         {
             [self uploadComplete];
             
             [taskToComplete completeTask];
         }];
    }];
    
    [self setNextTask:nextTask];
}

- (void)uploadComplete
{
    self.result = self.putParams.url;
}

@end
