//
// MHVMethodFactory.m
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
//

#import "MHVCommon.h"
#import "MHVMethodFactory.h"

@implementation MHVMethodFactory

- (MHVGetThingsTask *)newGetThingsForRecord:(MHVRecordReference *)record queries:(MHVThingQueryCollection *)queries andCallback:(MHVTaskCompletion)callback
{
    MHVGetThingsTask *task = [MHVGetThingsTask newForRecord:record queries:queries andCallback:callback];

    task.taskName = @"GetItemsForRecord";
    return task;
}

- (MHVPutThingsTask *)newPutThingsForRecord:(MHVRecordReference *)record things:(MHVThingCollection *)things andCallback:(MHVTaskCompletion)callback
{
    MHVPutThingsTask *task = [MHVPutThingsTask newForRecord:record things:things andCallback:callback];

    task.taskName = @"PutItemsForRecord";
    return task;
}

- (MHVRemoveThingsTask *)newRemoveThingsForRecord:(MHVRecordReference *)record keys:(MHVThingKeyCollection *)keys andCallback:(MHVTaskCompletion)callback
{
    MHVRemoveThingsTask *task = [MHVRemoveThingsTask newForRecord:record keys:keys andCallback:callback];

    task.taskName = @"RemoveItemsForRecord";
    return task;
}

@end

@implementation MHVMethodFactory (MHVMethodFactoryExtensions)

- (MHVGetThingsTask *)newGetThingsForRecord:(MHVRecordReference *)record query:(MHVThingQuery *)query andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(query);

    MHVThingQueryCollection *queries = [[MHVThingQueryCollection alloc] init];
    MHVCHECK_NOTNULL(queries);

    [queries addObject:query];

    MHVGetThingsTask *task = [self newGetThingsForRecord:record queries:queries andCallback:callback];

    return task;
}

- (MHVPutThingsTask *)newPutThingForRecord:(MHVRecordReference *)record thing:(MHVThing *)thing andCallback:(MHVTaskCompletion)callback
{
    MHVThingCollection *things = [[MHVThingCollection alloc] initWithThing:thing];

    MHVCHECK_NOTNULL(things);

    MHVPutThingsTask *putThings = [self newPutThingsForRecord:record things:things andCallback:callback];

    return putThings;
}

@end
