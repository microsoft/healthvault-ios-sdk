//
//  HVRecordReference.m
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
#import "HVRecordReference.h"
#import "HVClient.h"

static NSString* const c_attribute_id = @"id";
static NSString* const c_attribute_personID = @"person-id";

@implementation HVRecordReference

@synthesize ID = m_id;
@synthesize personID = m_personID;

-(void) dealloc
{
    [m_id release];
    [m_personID release];
    [super dealloc];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_id, HVClientError_InvalidRecordReference);
    
    HVVALIDATE_SUCCESS;
}

-(void) serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_id value:m_id];
    [writer writeAttribute:c_attribute_personID value:m_personID];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_id = [[reader readAttribute:c_attribute_id] retain];
    m_personID = [[reader readAttribute:c_attribute_personID] retain];
}

@end

@implementation HVRecordReference (HVMethods)

-(HVGetItemsTask *)getItemsForClass:(Class)cls callback:(HVTaskCompletion)callback
{
    NSString* typeID = [[HVTypeSystem current] getTypeIDForClassName:NSStringFromClass(cls)];
    if (!typeID)
    {
        return nil;
    }
    
    return [self getItemsForType:typeID callback:callback];
}

-(HVGetItemsTask *)getItemsForType:(NSString *)typeID callback:(HVTaskCompletion)callback
{
    HVItemQuery *query = [[HVItemQuery alloc] initWithTypeID:typeID];
    HVCHECK_NOTNULL(query);
    
    HVGetItemsTask* task = [self getItems:query callback:callback];
    [query release];
    
    return task;
    
LError:
    return nil;
}

-(HVGetItemsTask *)getPendingItems:(HVPendingItemCollection *)items callback:(HVTaskCompletion)callback
{
    return [self getPendingItems:items ofType:nil callback:callback];
}

-(HVGetItemsTask *)getPendingItems:(HVPendingItemCollection *)items ofType:(NSString *)typeID callback:(HVTaskCompletion)callback
{
    HVItemQuery *query = [[[HVItemQuery alloc] initWithPendingItems:items] autorelease];
    HVCHECK_NOTNULL(query);

    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }

    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(HVGetItemsTask *)getItemWithKey:(HVItemKey *)key callback:(HVTaskCompletion)callback
{
    return [self getItemWithKey:key ofType:nil callback:callback];
}

-(HVGetItemsTask *)getItemWithKey:(HVItemKey *)key ofType:(NSString *)typeID callback:(HVTaskCompletion)callback
{
    HVItemQuery *query = [[[HVItemQuery alloc] initWithItemKey:key andType:typeID] autorelease];
    HVCHECK_NOTNULL(query);

    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(HVGetItemsTask *)getItemWithID:(NSString *)itemID callback:(HVTaskCompletion)callback
{
    return [self getItemWithID:itemID ofType:nil callback:callback];
}

-(HVGetItemsTask *)getItemWithID:(NSString *)itemID ofType:(NSString *)typeID callback:(HVTaskCompletion)callback
{
    HVItemQuery *query = [[[HVItemQuery alloc] initWithItemID:itemID andType:typeID] autorelease];
    HVCHECK_NOTNULL(query);
    
    return [self getItems:query callback:callback];
    
LError:
    return nil;    
}

-(HVGetItemsTask *)getItems:(HVItemQuery *)query callback:(HVTaskCompletion)callback
{
    HVGetItemsTask* task = [[[HVClient current].methodFactory newGetItemsForRecord:self query:query andCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    [task start];
    return task;
    
LError:
    return nil;
}

-(HVPutItemsTask *)newItem:(HVItem *)item callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(item);
    
    [item prepareForNew];
    
    return [self putItem:item callback:callback];
    
LError:
    return nil;
}

-(HVPutItemsTask *)newItems:(HVItemCollection *)items callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(items);
    
    [items prepareForNew];
    return [self putItems:items callback:callback];

LError:
    return nil;
}

-(HVPutItemsTask *)putItem:(HVItem *)item callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(item);
    
    HVItemCollection* items = [[HVItemCollection alloc] initWithItem:item];
    HVCHECK_NOTNULL(items);
    
    HVPutItemsTask* task = [self putItems:items callback:callback];
    [items release];
    
    return task;
    
LError:
    return nil;
}

-(HVPutItemsTask *)putItems:(HVItemCollection *)items callback:(HVTaskCompletion)callback
{
    HVPutItemsTask* task = [[[HVClient current].methodFactory newPutItemsForRecord:self items:items andCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    [task start];
    return task;

LError:
    return nil;
}

-(HVPutItemsTask *)updateItem:(HVItem *)item callback:(HVTaskCompletion)callback
{
    [item prepareForUpdate];
    return [self putItem:item callback:callback];
}

-(HVPutItemsTask *)updateItems:(HVItemCollection *)items callback:(HVTaskCompletion)callback
{
    [items prepareForUpdate];
    return [self putItems:items callback:callback];
}

-(HVRemoveItemsTask *)removeItemWithKey:(HVItemKey *)key callback:(HVTaskCompletion)callback
{
    HVItemKeyCollection* keys = [[[HVItemKeyCollection alloc] initWithKey:key] autorelease];
    HVCHECK_NOTNULL(keys);
    
    return [self removeItemsWithKeys:keys callback:callback];
    
LError:
    return nil;
}

-(HVRemoveItemsTask *)removeItemsWithKeys:(HVItemKeyCollection *)keys callback:(HVTaskCompletion)callback
{
    HVRemoveItemsTask* task = [[[HVClient current].methodFactory newRemoveItemsForRecord:self keys:keys andCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);

    [task start];
    return task;
    
LError:
    return nil;
}

@end
