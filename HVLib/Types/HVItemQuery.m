//
//  HVItemQuery.m
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
#import "HVItemQuery.h"
#import "HVType.h"
#import "HVPendingItem.h"

static NSString* const c_attribute_name = @"name";
static NSString* const c_attribute_max = @"max";
static NSString* const c_attribute_maxfull = @"max-full";
static NSString* const c_element_id = @"id";
static NSString* const c_element_key = @"key";
static NSString* const c_element_clientID = @"client-thing-id";
static NSString* const c_element_filter = @"filter";
static NSString* const c_element_view = @"format";


@implementation HVItemQuery

@synthesize name = m_name;
@synthesize itemIDs = m_itemIDs;
@synthesize clientIDs = m_clientIDs;
@synthesize keys = m_keys;
@synthesize filters = m_filters;
@synthesize view = m_view;
-(void)setView:(HVItemView *)view
{
    HVASSERT(view != nil);
    if (view)
    {
        HVRETAIN(m_view, view);
    }
}

-(int) maxResults
{
    return (m_max) ? m_max.value : -1;
}

-(void) setMaxResults:(int)maxResultsValue
{
    if (maxResultsValue >= 0)
    {
        HVENSURE(m_max, HVInt);
        m_max.value = maxResultsValue;       
    }
    else
    {
        HVCLEAR(m_max);
    }
}

-(int) maxFullResults
{
    return (m_maxFull) ? m_maxFull.value : -1;
}

-(void) setMaxFullResults:(int)maxFullResultsValue
{
    if (maxFullResultsValue >= 0)
    {
        HVENSURE(m_maxFull, HVInt);
        m_maxFull.value = maxFullResultsValue;       
    }
    else
    {
        HVCLEAR(m_maxFull);
    }
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_view = [[HVItemView alloc] init];
    m_itemIDs = [[HVStringCollection alloc] init];
    m_keys = [[HVItemKeyCollection alloc] init];
    m_clientIDs = [[HVStringCollection alloc] init];
    m_filters = [[HVItemFilterCollection alloc] init];
    
    HVCHECK_TRUE(m_view && m_itemIDs && m_keys && m_filters);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithTypeID:(NSString *)typeID
{
    HVCHECK_STRING(typeID);
    
    HVItemFilter* filter = [[HVItemFilter alloc] initWithTypeID:typeID];
    self = [self initWithFilter:filter];
    [filter release];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithFilter:(HVItemFilter *)filter
{
    HVCHECK_NOTNULL(filter);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_filters addObject:filter];
    
    if (![NSArray isNilOrEmpty:filter.typeIDs])
    {
        [m_view.typeVersions addObjectsFromArray:filter.typeIDs];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initwithItemID:(NSString *)itemID
{
    HVCHECK_STRING(itemID);

    self = [self init];
    HVCHECK_SELF;
    
    [m_itemIDs addObject:itemID];

    return self;

LError:
    HVALLOC_FAIL;
}

-(id)initWithItemIDs:(NSArray *)ids
{
    HVCHECK_NOTNULL(ids);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_itemIDs addObjectsFromArray:ids];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItemKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_keys addObject:key];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItemKeys:(NSArray *)keys
{
    HVCHECK_NOTNULL(keys);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_keys addObjectsFromArray:keys];
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(id)initWithPendingItems:(NSArray *)pendingItems
{
    HVCHECK_NOTNULL(pendingItems);
    
    self = [self init];
    HVCHECK_SELF;
    
    for (HVPendingItem *item in pendingItems) 
    {
        [m_keys addObject:item.key];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItemKey:(HVItemKey *)key andType:(NSString *)typeID
{
    self = [self init];
    HVCHECK_SELF;
    
    [m_keys addObject:key];   
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }

    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItemID:(NSString *)itemID andType:(NSString *)typeID
{
    HVCHECK_STRING(itemID);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_itemIDs addObject:itemID];
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithClientID:(NSString *)clientID andType:(NSString *)typeID
{
    HVCHECK_STRING(clientID);
    
    self = [self init];
    HVCHECK_SELF;
    
    [m_clientIDs addObject:clientID];
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_name release];
    [m_itemIDs release];
    [m_keys release];
    [m_clientIDs release];
    [m_filters release];
    [m_view release];
    [m_max release];
    [m_maxFull release];   
    
    [super dealloc];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_view, HVClientError_InvalidItemQuery);
    
    HVVALIDATE_ARRAYOPTIONAL(m_itemIDs, HVClientError_InvalidItemQuery);
    HVVALIDATE_ARRAYOPTIONAL(m_keys, HVClientError_InvalidItemQuery);
    HVVALIDATE_ARRAYOPTIONAL(m_filters, HVClientError_InvalidItemQuery);

    HVVALIDATE_OPTIONAL(m_max);
    HVVALIDATE_OPTIONAL(m_maxFull);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:m_name];
    if (m_max)
    {
        [writer writeAttribute:c_attribute_max intValue:m_max.value];
    }
    if (m_maxFull)
    {
        [writer writeAttribute:c_attribute_maxfull intValue:m_maxFull.value];
    }
}

-(void) serialize:(XWriter *)writer
{
    //
    // Query xml schema says - ids are a choice element 
    //
    if (![NSArray isNilOrEmpty:m_itemIDs])
    {
        [writer writeElementArray:c_element_id elements:m_itemIDs];        
    }
    else if (![NSArray isNilOrEmpty:m_keys])
    {
        [writer writeElementArray:c_element_key elements:m_keys];        
    }
    else if (![NSArray isNilOrEmpty:m_clientIDs])
    {
        [writer writeElementArray:c_element_clientID elements:m_clientIDs]; 
    }
    
    [writer writeElementArray:c_element_filter elements:m_filters];
    [writer writeElement:c_element_view content:m_view];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_name = [[reader readAttribute:c_attribute_name] retain];
    
    int intValue;
    if ([reader readIntAttribute:c_attribute_max intValue:&intValue])
    {
        self.maxResults = intValue;
    }
    if ([reader readIntAttribute:c_attribute_maxfull intValue:&intValue])
    {
        self.maxFullResults = intValue;
    }
}

-(void) deserialize:(XReader *)reader
{
    m_itemIDs = [[reader readStringElementArray:c_element_id] retain];
    m_keys = (HVItemKeyCollection *)[[reader readElementArray:c_element_key asClass:[HVItemKey class] andArrayClass:[HVItemKeyCollection class]] retain];
    m_clientIDs = [[reader readStringElementArray:c_element_clientID] retain];
    m_filters = (HVItemFilterCollection *)[[reader readElementArray:c_element_filter asClass:[HVItemFilter class] andArrayClass:[HVItemFilterCollection class]] retain];
    m_view = [[reader readElement:c_element_view asClass:[HVItemView class]] retain];
}

@end

@implementation HVItemQueryCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVItemQuery class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(HVItemQuery *)query
{
    return [super addObject:query];
}

-(HVItemQuery *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
