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
        MHVGetThingsTask *getThingsTask = [self newGetThingsTask:record];
        MHVCHECK_NOTNULL(getThingsTask);
        
        [self setNextTask:getThingsTask];
    }
    return self;
}

#pragma mark - Internal methods

- (MHVGetThingsTask *)newGetThingsTask:(MHVRecordReference *)record
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithTypeID:MHVPersonalImage.typeID];

    MHVCHECK_NOTNULL(query);

    query.view.sections = MHVThingSection_Blobs;

    MHVGetThingsTask *getThingsTask = [[MHVClient current].methodFactory newGetThingsForRecord:record
                                                                                      query:query
                                                                                andCallback:^(MHVTask *task)
    {
        [self getThingComplete:task];
    }];


    return getThingsTask;
}

- (void)getThingComplete:(MHVTask *)task
{
    MHVThing *thing = ((MHVGetThingsTask *)task).firstThingRetrieved;

    if (!thing.hasBlobData)
    {
        return;
    }

    MHVBlobPayloadThing *blob = [thing.blobs getDefaultBlob];
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
