//
//  HVItemQueryResult.m
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

#import "HVCommon.h"
#import "HVItemQueryResult.h"
#import "HVGetItemsTask.h"
#import "HVClient.h"

static NSString* const c_element_item = @"thing";
static NSString* const c_element_pending = @"unprocessed-thing-key-info";
static NSString* const c_attribute_name = @"name";

@interface HVItemQueryResult (HVPrivate)

-(HVGetItemsTask *) newGetTaskFor:(HVPendingItemCollection *)pendingItems forRecord:(HVRecordReference *) record;
-(BOOL) nextGetPendingItems:(HVPendingItemCollection *)pendingItems forRecord:(HVRecordReference *) record andParentTask:(HVTask *) parentTask; 
-(void) getItemsComplete:(HVTask *) task forRecord:(HVRecordReference *) record;

@end

@implementation HVItemQueryResult

@synthesize items = m_items;
@synthesize pendingItems = m_pendingItems;
@synthesize name = m_name;

-(BOOL) hasItems
{
    return !([NSArray isNilOrEmpty:m_items]);
}

-(BOOL) hasPendingItems
{
    return !([NSArray isNilOrEmpty:m_pendingItems]);
}

-(void) dealloc
{
    [m_items release];
    [m_pendingItems release];
    [m_name release];
    [super dealloc];
}

-(HVTask *)getPendingItemsForRecord:(HVRecordReference *)record withCallback:(HVTaskCompletion)callback
{
    HVTask* task = [self createTaskToGetPendingItemsForRecord:record withCallback:callback];
    if (task)
    {
        [task start];
    }
    return task;
}

-(HVTask *)createTaskToGetPendingItemsForRecord:(HVRecordReference *)record withCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    if (!self.hasPendingItems)
    {
        return nil;
    }
    
    HVTask* task = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    HVCHECK_SUCCESS([self nextGetPendingItems:self.pendingItems forRecord:record andParentTask:task]);
    
    return task;
    
LError:
    return nil;
}

-(void) serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_items, c_element_item);
    HVSERIALIZE_ARRAY(m_pendingItems, c_element_pending);
}

-(void) deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE(m_name, c_attribute_name);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_items, c_element_item, HVItem, HVItemCollection);
    HVDESERIALIZE_TYPEDARRAY(m_pendingItems, c_element_pending, HVPendingItem, HVPendingItemCollection);
}

@end

@implementation HVItemQueryResult (HVPrivate)

-(HVGetItemsTask *) newGetTaskFor:(HVPendingItemCollection *)pendingItems forRecord:(HVRecordReference *)record
{
    HVItemQuery *pendingQuery = [[HVItemQuery alloc] initWithPendingItems:pendingItems];
    HVGetItemsTask* getPendingTask = [[HVGetItemsTask alloc] initWithQuery:pendingQuery andCallback:^(HVTask *task) {
        
        [self getItemsComplete:task forRecord:record];
    
    }];
    
    [pendingQuery release];
    return getPendingTask;
}

-(BOOL)nextGetPendingItems:(HVPendingItemCollection *)pendingItems forRecord:(HVRecordReference *)record andParentTask:(HVTask *)parentTask
{
    HVGetItemsTask* getPendingTask = [self newGetTaskFor:pendingItems forRecord:record];
    HVCHECK_NOTNULL(getPendingTask);
    
    [parentTask setNextTask:getPendingTask];    
    [getPendingTask release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)getItemsComplete:(HVTask *)task forRecord:(HVRecordReference *)record
{
    HVGetItemsTask* getItems = (HVGetItemsTask *) task;
    HVItemQueryResult* result = getItems.queryResults.firstResult;
    
    if (result.hasItems)
    {
        //
        // Append items to this query result's item list
        //
        [self.items addObjectsFromArray:result.items];
    }
    
    if (!result.hasPendingItems)
    {
        // No more pending items!
        // We can clear the pending items in this query
        HVCLEAR(m_pendingItems);
        return;
    }
    //
    // The pending item query did not return all the items we had requested... MORE pending items!
    // So we have to issue another query
    //
    [self nextGetPendingItems:result.pendingItems forRecord:record andParentTask:task.parent];   
}

@end

@implementation HVItemQueryResultCollection 

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVItemQueryResult class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end


