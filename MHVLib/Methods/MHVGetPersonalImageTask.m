//
// MHVGetPersonalImageTask.m
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

#import "MHVCommon.h"
#import "MHVGetPersonalImageTask.h"
#import "MHVPersonalImage.h"
#import "MHVClient.h"

@implementation MHVGetPersonalImageTask

- (NSData *)imageData
{
    return (NSData *)self.result;
}

- (instancetype)initWithRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    self = [super initWithCallback:callback];
    if (self)
    {
        MHVGetItemsTask *getItemsTask = [self newGetItemsTask:record];
        MHVCHECK_NOTNULL(getItemsTask);
        
        [self setNextTask:getItemsTask];
    }
    return self;
}

#pragma mark - Internal methods

- (MHVGetItemsTask *)newGetItemsTask:(MHVRecordReference *)record
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithTypeID:MHVPersonalImage.typeID];

    MHVCHECK_NOTNULL(query);

    query.view.sections = MHVItemSection_Blobs;

    MHVGetItemsTask *getItemsTask = [[MHVClient current].methodFactory newGetItemsForRecord:record
                                                                                      query:query
                                                                                andCallback:^(MHVTask *task)
    {
        [self getItemComplete:task];
    }];


    return getItemsTask;
}

- (void)getItemComplete:(MHVTask *)task
{
    MHVItem *item = ((MHVGetItemsTask *)task).firstItemRetrieved;

    if (!item.hasBlobData)
    {
        return;
    }

    MHVBlobPayloadItem *blob = [item.blobs getDefaultBlob];
    if (!blob)
    {
        return;
    }

    [self setNextTask:[[MHVTaskAsyncBlock alloc] initWithAsyncBlock:^(MHVTask *taskToComplete)
    {
        [blob downloadBlobDataWithCompletion:^(NSData *data, NSError *error)
        {
            self.result = data;

            [taskToComplete completeTask];
            [self completeTask];
        }];
    }]];
}

@end
