//
//  MHVItemQuery.m
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
#import "MHVItemQuery.h"
#import "MHVType.h"
#import "MHVPendingItem.h"

static NSString* const c_attribute_name = @"name";
static NSString* const c_attribute_max = @"max";
static NSString* const c_attribute_maxfull = @"max-full";
static NSString* const c_element_id = @"id";
static NSString* const c_element_key = @"key";
static NSString* const c_element_clientID = @"client-thing-id";
static NSString* const c_element_filter = @"filter";
static NSString* const c_element_view = @"format";


@implementation MHVItemQuery

@synthesize name = m_name;
@synthesize itemIDs = m_itemIDs;
@synthesize clientIDs = m_clientIDs;
@synthesize keys = m_keys;
@synthesize filters = m_filters;
@synthesize view = m_view;
-(void)setView:(MHVItemView *)view
{
    MHVASSERT(view != nil);
    if (view)
    {
        m_view = view;
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
        MHVENSURE(m_max, MHVInt);
        m_max.value = maxResultsValue;       
    }
    else
    {
        m_max = nil;
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
        MHVENSURE(m_maxFull, MHVInt);
        m_maxFull.value = maxFullResultsValue;       
    }
    else
    {
        m_maxFull = nil;
    }
}

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_view = [[MHVItemView alloc] init];
    m_itemIDs = [[MHVStringCollection alloc] init];
    m_keys = [[MHVItemKeyCollection alloc] init];
    m_clientIDs = [[MHVStringCollection alloc] init];
    m_filters = [[MHVItemFilterCollection alloc] init];
    
    MHVCHECK_TRUE(m_view && m_itemIDs && m_keys && m_filters);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithTypeID:(NSString *)typeID
{
    MHVCHECK_STRING(typeID);
    
    MHVItemFilter* filter = [[MHVItemFilter alloc] initWithTypeID:typeID];
    self = [self initWithFilter:filter];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithFilter:(MHVItemFilter *)filter
{
    MHVCHECK_NOTNULL(filter);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_filters addObject:filter];
    
    if (![MHVCollection isNilOrEmpty:filter.typeIDs])
    {
        [m_view.typeVersions addObjectsFromArray:filter.typeIDs.toArray];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemID:(NSString *)itemID
{
    MHVCHECK_STRING(itemID);

    self = [self init];
    MHVCHECK_SELF;
    
    [m_itemIDs addObject:itemID];

    return self;

LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemIDs:(NSArray *)ids
{
    MHVCHECK_NOTNULL(ids);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_itemIDs addObjectsFromArray:ids];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemKey:(MHVItemKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_keys addObject:key];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemKeys:(NSArray *)keys
{
    MHVCHECK_NOTNULL(keys);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_keys addObjectsFromArray:keys];
    
    return self;

LError:
    MHVALLOC_FAIL;
}

-(id)initWithPendingItems:(MHVCollection *)pendingItems
{
    MHVCHECK_NOTNULL(pendingItems);
    
    self = [self init];
    MHVCHECK_SELF;
    
    for (MHVPendingItem *item in pendingItems) 
    {
        [m_keys addObject:item.key];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemKey:(MHVItemKey *)key andType:(NSString *)typeID
{
    self = [self init];
    MHVCHECK_SELF;
    
    [m_keys addObject:key];   
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }

    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItemID:(NSString *)itemID andType:(NSString *)typeID
{
    MHVCHECK_STRING(itemID);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_itemIDs addObject:itemID];
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithClientID:(NSString *)clientID andType:(NSString *)typeID
{
    MHVCHECK_STRING(clientID);
    
    self = [self init];
    MHVCHECK_SELF;
    
    [m_clientIDs addObject:clientID];
    if (![NSString isNilOrEmpty:typeID])
    {
        [self.view.typeVersions addObject:typeID];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_view, MHVClientError_InvalidItemQuery);
    
    MHVVALIDATE_ARRAYOPTIONAL(m_itemIDs, MHVClientError_InvalidItemQuery);
    MHVVALIDATE_ARRAYOPTIONAL(m_keys, MHVClientError_InvalidItemQuery);
    MHVVALIDATE_ARRAYOPTIONAL(m_filters, MHVClientError_InvalidItemQuery);

    MHVVALIDATE_OPTIONAL(m_max);
    MHVVALIDATE_OPTIONAL(m_maxFull);
    
    MHVVALIDATE_SUCCESS;
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
    if (![MHVCollection isNilOrEmpty:m_itemIDs])
    {
        [writer writeElementArray:c_element_id elements:m_itemIDs.toArray];
    }
    else if (![MHVCollection isNilOrEmpty:m_keys])
    {
        [writer writeElementArray:c_element_key elements:m_keys.toArray];
    }
    else if (![MHVCollection isNilOrEmpty:m_clientIDs])
    {
        [writer writeElementArray:c_element_clientID elements:m_clientIDs.toArray];
    }
    
    [writer writeElementArray:c_element_filter elements:m_filters.toArray];
    [writer writeElement:c_element_view content:m_view];
}

-(void) deserializeAttributes:(XReader *)reader
{
    m_name = [reader readAttribute:c_attribute_name];
    
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
    m_itemIDs = [reader readStringElementArray:c_element_id];
    m_keys = (MHVItemKeyCollection *)[reader readElementArray:c_element_key asClass:[MHVItemKey class] andArrayClass:[MHVItemKeyCollection class]];
    m_clientIDs = [reader readStringElementArray:c_element_clientID];
    m_filters = (MHVItemFilterCollection *)[reader readElementArray:c_element_filter asClass:[MHVItemFilter class] andArrayClass:[MHVItemFilterCollection class]];
    m_view = [reader readElement:c_element_view asClass:[MHVItemView class]];
}

@end

@implementation MHVItemQueryCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVItemQuery class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void)addItem:(MHVItemQuery *)query
{
    return [super addObject:query];
}

-(MHVItemQuery *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
