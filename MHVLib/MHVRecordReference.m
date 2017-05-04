//
//  MHVRecordReference.m
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
#import "MHVRecordReference.h"
#import "MHVClient.h"

static NSString* const c_attribute_id = @"id";
static NSString* const c_attribute_personID = @"person-id";

@implementation MHVRecordReference

@synthesize ID = m_id;
@synthesize personID = m_personID;


-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_STRING(m_id, MHVClientError_InvalidRecordReference);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_id value:m_id];
    [writer writeAttribute:c_attribute_personID value:m_personID];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_id = [reader readAttribute:c_attribute_id];
    m_personID = [reader readAttribute:c_attribute_personID];
}

@end

@implementation MHVRecordReference (MHVMethods)

-(MHVGetItemsTask *)getItemsForClass:(Class)cls callback:(MHVTaskCompletion)callback
{
    NSString* typeID = [[MHVTypeSystem current] getTypeIDForClassName:NSStringFromClass(cls)];
    if (!typeID)
    {
        return nil;
    }
    
    return [self getItemsForType:typeID callback:callback];
}

-(MHVGetItemsTask *)getItemsForType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithTypeID:typeID];
    MHVCHECK_NOTNULL(query);
    
    MHVGetItemsTask* task = [self getItems:query callback:callback];
    
    return task;
    
LError:
    return nil;
}

-(MHVGetItemsTask *)getPendingItems:(MHVPendingItemCollection *)items callback:(MHVTaskCompletion)callback
{
    return [self getPendingItems:items ofType:nil callback:callback];
}

-(MHVGetItemsTask *)getPendingItems:(MHVPendingItemCollection *)items ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithPendingItems:items];
    MHVCHECK_NOTNULL(query);

    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }

    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(MHVGetItemsTask *)getItemWithKey:(MHVItemKey *)key callback:(MHVTaskCompletion)callback
{
    return [self getItemWithKey:key ofType:nil callback:callback];
}

-(MHVGetItemsTask *)getItemWithKey:(MHVItemKey *)key ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithItemKey:key andType:typeID];
    MHVCHECK_NOTNULL(query);

    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(MHVGetItemsTask *)getItemWithID:(NSString *)itemID callback:(MHVTaskCompletion)callback
{
    return [self getItemWithID:itemID ofType:nil callback:callback];
}

-(MHVGetItemsTask *)getItemWithID:(NSString *)itemID ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithItemID:itemID andType:typeID];
    MHVCHECK_NOTNULL(query);
    
    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(MHVGetItemsTask *)getItems:(MHVItemQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVGetItemsTask* task = [[MHVClient current].methodFactory newGetItemsForRecord:self query:query andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    return task;
    
LError:
    return nil;
}

-(MHVPutItemsTask *)newItem:(MHVItem *)item callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(item);
    
    [item prepareForNew];
    
    return [self putItem:item callback:callback];
    
LError:
    return nil;
}

-(MHVPutItemsTask *)newItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(items);
    
    [items prepareForNew];
    return [self putItems:items callback:callback];

LError:
    return nil;
}

-(MHVPutItemsTask *)putItem:(MHVItem *)item callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(item);
    
    MHVItemCollection* items = [[MHVItemCollection alloc] initWithItem:item];
    MHVCHECK_NOTNULL(items);
    
    MHVPutItemsTask* task = [self putItems:items callback:callback];
    
    return task;
    
LError:
    return nil;
}

-(MHVPutItemsTask *)putItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback
{
    MHVPutItemsTask* task = [[MHVClient current].methodFactory newPutItemsForRecord:self items:items andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    return task;

LError:
    return nil;
}

-(MHVPutItemsTask *)updateItem:(MHVItem *)item callback:(MHVTaskCompletion)callback
{
    [item prepareForUpdate];
    return [self putItem:item callback:callback];
}

-(MHVPutItemsTask *)updateItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback
{
    [items prepareForUpdate];
    return [self putItems:items callback:callback];
}

-(MHVRemoveItemsTask *)removeItemWithKey:(MHVItemKey *)key callback:(MHVTaskCompletion)callback
{
    MHVItemKeyCollection* keys = [[MHVItemKeyCollection alloc] initWithKey:key];
    MHVCHECK_NOTNULL(keys);
    
    return [self removeItemsWithKeys:keys callback:callback];
    
LError:
    return nil;
}

-(MHVRemoveItemsTask *)removeItemsWithKeys:(MHVItemKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVRemoveItemsTask* task = [[MHVClient current].methodFactory newRemoveItemsForRecord:self keys:keys andCallback:callback];
    MHVCHECK_NOTNULL(task);

    [task start];
    return task;
    
LError:
    return nil;
}

@end
