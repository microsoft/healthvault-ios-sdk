//
//  MHVItemQueryResult.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVItemQueryResult.h"
#import "MHVGetItemsTask.h"
#import "MHVClient.h"

static NSString* const c_element_item = @"thing";
static NSString* const c_element_pending = @"unprocessed-thing-key-info";
static NSString* const c_attribute_name = @"name";

@interface MHVItemQueryResult (MHVPrivate)

-(MHVGetItemsTask *) newGetTaskFor:(MHVPendingItemCollection *)pendingItems forRecord:(MHVRecordReference *) record itemView:(MHVItemView *) view;
-(BOOL) nextGetPendingItems:(MHVPendingItemCollection *)pendingItems forRecord:(MHVRecordReference *) record itemView:(MHVItemView *) view andParentTask:(MHVTask *) parentTask; 
-(void) getItemsComplete:(MHVTask *) task forRecord:(MHVRecordReference *) record itemView:(MHVItemView *) view;

-(void) appendFoundItems:(MHVItemCollection *) items;

@end

@implementation MHVItemQueryResult

@synthesize items = m_items;
@synthesize pendingItems = m_pendingItems;
@synthesize name = m_name;

-(BOOL) hasItems
{
    return !([MHVCollection isNilOrEmpty:m_items]);
}

-(BOOL) hasPendingItems
{
    return !([MHVCollection isNilOrEmpty:m_pendingItems]);
}

-(NSUInteger)itemCount
{
    return (m_items ? m_items.count : 0);
}

-(NSUInteger)pendingCount
{
    return (m_pendingItems ? m_pendingItems.count : 0);
}

-(NSUInteger)resultCount
{
    return (self.itemCount + self.pendingCount);
}


-(MHVTask *)getPendingItemsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback
{
    return [self getPendingItemsForRecord:record itemView:nil withCallback:callback];
}

-(MHVTask *)getPendingItemsForRecord:(MHVRecordReference *)record itemView:(MHVItemView *)view withCallback:(MHVTaskCompletion)callback
{
    MHVTask* task = [self createTaskToGetPendingItemsForRecord:record itemView:view withCallback:callback];
    if (task)
    {
        [task start];
    }
    return task;    
}

-(MHVTask *)createTaskToGetPendingItemsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback
{
    return [self createTaskToGetPendingItemsForRecord:record itemView:nil withCallback:callback];
}

-(MHVTask *)createTaskToGetPendingItemsForRecord:(MHVRecordReference *)record itemView:(MHVItemView *)view withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    if (!self.hasPendingItems)
    {
        return nil;
    }
    
    MHVTask* task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    MHVCHECK_SUCCESS([self nextGetPendingItems:self.pendingItems forRecord:record itemView:view andParentTask:task]);
    
    return task;
    
LError:
    return nil;
    
}

-(void) serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:m_name];
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_item elements:m_items.toArray];
    [writer writeElementArray:c_element_pending elements:m_pendingItems.toArray];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_name = [reader readAttribute:c_attribute_name];
}

-(void) deserialize:(XReader *)reader
{
    m_items = (MHVItemCollection *)[reader readElementArray:c_element_item asClass:[MHVItem class] andArrayClass:[MHVItemCollection class]];
    m_pendingItems = (MHVPendingItemCollection *)[reader readElementArray:c_element_pending asClass:[MHVPendingItem class] andArrayClass:[MHVPendingItemCollection class]];
}

@end

@implementation MHVItemQueryResult (MHVPrivate)

-(MHVGetItemsTask *) newGetTaskFor:(MHVPendingItemCollection *)pendingItems forRecord:(MHVRecordReference *)record itemView:(MHVItemView *) view
{
    MHVItemQuery *pendingQuery = [[MHVItemQuery alloc] initWithPendingItems:pendingItems];
    MHVCHECK_NOTNULL(pendingQuery);
    if (view)
    {
        pendingQuery.view = view;
    }
    MHVGetItemsTask* getPendingTask = [[MHVClient current].methodFactory newGetItemsForRecord:record query:pendingQuery andCallback:^(MHVTask *task){
        
        [self getItemsComplete:task forRecord:record itemView:view];
    
    }];
    
    return getPendingTask;

LError:
    return nil;
}

-(BOOL)nextGetPendingItems:(MHVPendingItemCollection *)pendingItems forRecord:(MHVRecordReference *)record itemView:(MHVItemView *) view andParentTask:(MHVTask *)parentTask
{
    MHVGetItemsTask* getPendingTask = [self newGetTaskFor:pendingItems forRecord:record itemView:view];
    MHVCHECK_NOTNULL(getPendingTask);
    
    [parentTask setNextTask:getPendingTask];    
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)getItemsComplete:(MHVTask *)task forRecord:(MHVRecordReference *)record itemView:(MHVItemView *) view
{
    MHVGetItemsTask* getItems = (MHVGetItemsTask *) task;
    MHVItemQueryResult* result = getItems.queryResults.firstResult;
    
    if (result.hasItems)
    {
        //
        // Append items to this query result's item list
        //
        [self appendFoundItems:result.items];
    }
    
    if (!result.hasPendingItems)
    {
        // No more pending items!
        // We can clear the pending items in this query
        m_pendingItems = nil;
        return;
    }
    //
    // The pending item query did not return all the items we had requested... MORE pending items!
    // So we have to issue another query
    //
    [self nextGetPendingItems:result.pendingItems forRecord:record itemView:view andParentTask:task.parent];
}

-(void)appendFoundItems:(MHVItemCollection *)items
{
    MHVENSURE(m_items, MHVItemCollection);
    [m_items addObjectsFromCollection:items];
}

@end

@implementation MHVItemQueryResultCollection 

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVItemQueryResult class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVItemQueryResult *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end


