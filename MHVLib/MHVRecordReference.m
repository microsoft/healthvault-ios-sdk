//
// MHVRecordReference.m
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
#import "MHVRecordReference.h"
#import "MHVClient.h"

static NSString *const c_attribute_id = @"id";
static NSString *const c_attribute_personID = @"person-id";

@implementation MHVRecordReference

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_STRING(self.ID, MHVClientError_InvalidRecordReference);

    MHVVALIDATE_SUCCESS;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_id value:self.ID];
    [writer writeAttribute:c_attribute_personID value:self.personID];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.ID = [reader readAttribute:c_attribute_id];
    self.personID = [reader readAttribute:c_attribute_personID];
}

- (MHVGetThingsTask *)getThingsForClass:(Class)cls callback:(MHVTaskCompletion)callback
{
    NSString *typeID = [[MHVTypeSystem current] getTypeIDForClassName:NSStringFromClass(cls)];

    if (!typeID)
    {
        return nil;
    }

    return [self getThingsForType:typeID callback:callback];
}

- (MHVGetThingsTask *)getThingsForType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithTypeID:typeID];

    MHVCHECK_NOTNULL(query);

    MHVGetThingsTask *task = [self getThings:query callback:callback];

    return task;
}

- (MHVGetThingsTask *)getPendingThings:(MHVPendingThingCollection *)things callback:(MHVTaskCompletion)callback
{
    return [self getPendingThings:things ofType:nil callback:callback];
}

- (MHVGetThingsTask *)getPendingThings:(MHVPendingThingCollection *)things ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithPendingThings:things];

    MHVCHECK_NOTNULL(query);

    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }

    return [self getThings:query callback:callback];
}

- (MHVGetThingsTask *)getThingWithKey:(MHVThingKey *)key callback:(MHVTaskCompletion)callback
{
    return [self getThingWithKey:key ofType:nil callback:callback];
}

- (MHVGetThingsTask *)getThingWithKey:(MHVThingKey *)key ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingKey:key andType:typeID];

    MHVCHECK_NOTNULL(query);

    return [self getThings:query callback:callback];
}

- (MHVGetThingsTask *)getThingWithID:(NSString *)thingID callback:(MHVTaskCompletion)callback
{
    return [self getThingWithID:thingID ofType:nil callback:callback];
}

- (MHVGetThingsTask *)getThingWithID:(NSString *)thingID ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingID:thingID andType:typeID];

    MHVCHECK_NOTNULL(query);

    return [self getThings:query callback:callback];
}

- (MHVGetThingsTask *)getThings:(MHVThingQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVGetThingsTask *task = [[MHVClient current].methodFactory newGetThingsForRecord:self query:query andCallback:callback];

    MHVCHECK_NOTNULL(task);

    [task start];
    return task;
}

- (MHVPutThingsTask *)newThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(thing);

    [thing prepareForNew];

    return [self putThing:thing callback:callback];
}

- (MHVPutThingsTask *)newThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(things);

    [things prepareForNew];
    return [self putThings:things callback:callback];
}

- (MHVPutThingsTask *)putThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(thing);

    MHVThingCollection *things = [[MHVThingCollection alloc] initWithThing:thing];
    MHVCHECK_NOTNULL(things);

    MHVPutThingsTask *task = [self putThings:things callback:callback];

    return task;
}

- (MHVPutThingsTask *)putThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback
{
    MHVPutThingsTask *task = [[MHVClient current].methodFactory newPutThingsForRecord:self things:things andCallback:callback];

    MHVCHECK_NOTNULL(task);

    [task start];
    return task;
}

- (MHVPutThingsTask *)updateThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback
{
    [thing prepareForUpdate];
    return [self putThing:thing callback:callback];
}

- (MHVPutThingsTask *)updateThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback
{
    [things prepareForUpdate];
    return [self putThings:things callback:callback];
}

- (MHVRemoveThingsTask *)removeThingWithKey:(MHVThingKey *)key callback:(MHVTaskCompletion)callback
{
    MHVThingKeyCollection *keys = [[MHVThingKeyCollection alloc] initWithKey:key];

    MHVCHECK_NOTNULL(keys);

    return [self removeThingsWithKeys:keys callback:callback];
}

- (MHVRemoveThingsTask *)removeThingsWithKeys:(MHVThingKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVRemoveThingsTask *task = [[MHVClient current].methodFactory newRemoveThingsForRecord:self keys:keys andCallback:callback];

    MHVCHECK_NOTNULL(task);

    [task start];
    return task;
}

@end
