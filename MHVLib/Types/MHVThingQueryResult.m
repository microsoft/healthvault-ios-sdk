//
// MHVThingQueryResult.m
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
#import "MHVThingQueryResult.h"
#import "MHVGetThingsTask.h"
#import "MHVClient.h"

static NSString *const c_element_thing = @"thing";
static NSString *const c_element_pending = @"unprocessed-thing-key-info";
static NSString *const c_attribute_name = @"name";

@implementation MHVThingQueryResult

- (BOOL)hasThings
{
    return !([MHVCollection isNilOrEmpty:self.things]);
}

- (BOOL)hasPendingThings
{
    return !([MHVCollection isNilOrEmpty:self.pendingThings]);
}

- (NSUInteger)thingCount
{
    return self.things ? self.things.count : 0;
}

- (NSUInteger)pendingCount
{
    return self.pendingThings ? self.pendingThings.count : 0;
}

- (NSUInteger)resultCount
{
    return self.thingCount + self.pendingCount;
}

- (MHVTask *)getPendingThingsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback
{
    return [self getPendingThingsForRecord:record thingView:nil withCallback:callback];
}

- (MHVTask *)getPendingThingsForRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view withCallback:(MHVTaskCompletion)callback
{
    MHVTask *task = [self createTaskToGetPendingThingsForRecord:record thingView:view withCallback:callback];
    
    if (task)
    {
        [task start];
    }
    
    return task;
}

- (MHVTask *)createTaskToGetPendingThingsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback
{
    return [self createTaskToGetPendingThingsForRecord:record thingView:nil withCallback:callback];
}

- (MHVTask *)createTaskToGetPendingThingsForRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    if (!self.hasPendingThings)
    {
        return nil;
    }
    
    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    MHVCHECK_SUCCESS([self nextGetPendingThings:self.pendingThings forRecord:record thingView:view andParentTask:task]);
    
    return task;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:self.name];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_thing elements:self.things.toArray];
    [writer writeElementArray:c_element_pending elements:self.pendingThings.toArray];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.name = [reader readAttribute:c_attribute_name];
}

- (void)deserialize:(XReader *)reader
{
    self.things = (MHVThingCollection *)[reader readElementArray:c_element_thing
                                                       asClass:[MHVThing class]
                                                 andArrayClass:[MHVThingCollection class]];
    self.pendingThings = (MHVPendingThingCollection *)[reader readElementArray:c_element_pending
                                                                     asClass:[MHVPendingThing class]
                                                               andArrayClass:[MHVPendingThingCollection class]];
}

#pragma mark - Internal methods

- (MHVGetThingsTask *)newGetTaskFor:(MHVPendingThingCollection *)pendingThings forRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view
{
    MHVThingQuery *pendingQuery = [[MHVThingQuery alloc] initWithPendingThings:pendingThings];
    
    MHVCHECK_NOTNULL(pendingQuery);
    if (view)
    {
        pendingQuery.view = view;
    }
    
    MHVGetThingsTask *getPendingTask = [[MHVClient current].methodFactory newGetThingsForRecord:record query:pendingQuery andCallback:^(MHVTask *task) {
        [self getThingsComplete:task forRecord:record thingView:view];
    }];
    
    return getPendingTask;
}

- (BOOL)nextGetPendingThings:(MHVPendingThingCollection *)pendingThings forRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view andParentTask:(MHVTask *)parentTask
{
    MHVGetThingsTask *getPendingTask = [self newGetTaskFor:pendingThings forRecord:record thingView:view];
    
    MHVCHECK_NOTNULL(getPendingTask);
    
    [parentTask setNextTask:getPendingTask];
    
    return TRUE;
}

- (void)getThingsComplete:(MHVTask *)task forRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view
{
    MHVGetThingsTask *getThings = (MHVGetThingsTask *)task;
    MHVThingQueryResult *result = getThings.queryResults.firstResult;
    
    if (result.hasThings)
    {
        //
        // Append things to this query result's thing list
        //
        [self appendFoundThings:result.things];
    }
    
    if (!result.hasPendingThings)
    {
        // No more pending things!
        // We can clear the pending things in this query
        self.pendingThings = nil;
        return;
    }
    
    //
    // The pending thing query did not return all the things we had requested... MORE pending things!
    // So we have to issue another query
    //
    [self nextGetPendingThings:result.pendingThings forRecord:record thingView:view andParentTask:task.parent];
}

- (void)appendFoundThings:(MHVThingCollection *)things
{
    if (!self.things)
    {
        self.things = [[MHVThingCollection alloc] init];
    }
    
    [self.things addObjectsFromCollection:things];
}

@end

@implementation MHVThingQueryResultCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVThingQueryResult class];
    }
    return self;
}

- (MHVThingQueryResult *)resultWithName:(NSString *)name
{
    for (MHVThingQueryResult *result in self)
    {
        if ([result.name isEqualToString:name])
        {
            return result;
        }
    }
    return nil;
}

- (void)mergeThingQueryResultCollection:(MHVThingQueryResultCollection *)collection
{
    for (MHVThingQueryResult *result in collection)
    {
        MHVThingQueryResult *existingResult = [self resultWithName:result.name];
        if (existingResult)
        {
            [existingResult.things addObjectsFromCollection:result.things];
            [existingResult.pendingThings removeThings:result.things];
        }
        else
        {
            [self addObject:result];
        }
    }
}

@end
