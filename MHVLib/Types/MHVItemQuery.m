//
// MHVItemQuery.m
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
#import "MHVItemQuery.h"
#import "MHVType.h"
#import "MHVPendingItem.h"

static NSString *const c_attribute_name = @"name";
static NSString *const c_attribute_max = @"max";
static NSString *const c_attribute_maxfull = @"max-full";
static NSString *const c_element_id = @"id";
static NSString *const c_element_key = @"key";
static NSString *const c_element_clientID = @"client-thing-id";
static NSString *const c_element_filter = @"filter";
static NSString *const c_element_view = @"format";

@interface MHVItemQuery ()

@property (readwrite, nonatomic, strong) MHVStringCollection *itemIDs;
@property (readwrite, nonatomic, strong) MHVItemKeyCollection *keys;
@property (readwrite, nonatomic, strong) MHVStringCollection *clientIDs;
@property (readwrite, nonatomic, strong) MHVItemFilterCollection *filters;
@property (readwrite, nonatomic, strong) MHVInt *max;
@property (readwrite, nonatomic, strong) MHVInt *maxFull;

@end

@implementation MHVItemQuery

- (void)setView:(MHVItemView *)view
{
    MHVASSERT(view != nil);
    if (view)
    {
        _view = view;
    }
}

- (int)maxResults
{
    return (self.max) ? self.max.value : -1;
}

- (void)setMaxResults:(int)maxResultsValue
{
    if (maxResultsValue >= 0)
    {
        MHVENSURE(self.max, MHVInt);
        self.max.value = maxResultsValue;
    }
    else
    {
        self.max = nil;
    }
}

- (int)maxFullResults
{
    return (self.maxFull) ? self.maxFull.value : -1;
}

- (void)setMaxFullResults:(int)maxFullResultsValue
{
    if (maxFullResultsValue >= 0)
    {
        MHVENSURE(self.maxFull, MHVInt);
        self.maxFull.value = maxFullResultsValue;
    }
    else
    {
        self.maxFull = nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _view = [[MHVItemView alloc] init];
        _itemIDs = [[MHVStringCollection alloc] init];
        _keys = [[MHVItemKeyCollection alloc] init];
        _clientIDs = [[MHVStringCollection alloc] init];
        _filters = [[MHVItemFilterCollection alloc] init];
        
        MHVCHECK_TRUE(_view && _itemIDs && _keys && _filters);
    }
    return self;
}

- (instancetype)initWithTypeID:(NSString *)typeID
{
    MHVCHECK_STRING(typeID);
    
    MHVItemFilter *filter = [[MHVItemFilter alloc] initWithTypeID:typeID];
    self = [self initWithFilter:filter];
    
    return self;
}

- (instancetype)initWithFilter:(MHVItemFilter *)filter
{
    MHVCHECK_NOTNULL(filter);
    
    self = [self init];
    if (self)
    {
        [_filters addObject:filter];
        
    	if (![MHVCollection isNilOrEmpty:filter.typeIDs])
        {
      	  	[_view.typeVersions addObjectsFromArray:filter.typeIDs.toArray];
        }
    }
    return self;
}

- (instancetype)initWithItemID:(NSString *)itemID
{
    MHVCHECK_STRING(itemID);
    
    self = [self init];
    if (self)
    {
        [_itemIDs addObject:itemID];
    }
    return self;
}

- (instancetype)initWithItemIDs:(NSArray *)ids
{
    MHVCHECK_NOTNULL(ids);
    
    self = [self init];
    if (self)
    {
        [_itemIDs addObjectsFromArray:ids];
    }
    return self;
}

- (instancetype)initWithItemKey:(MHVItemKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    self = [self init];
    if (self)
    {
        [_keys addObject:key];
    }
    
    return self;
}

- (instancetype)initWithItemKeys:(NSArray *)keys
{
    MHVCHECK_NOTNULL(keys);
    
    self = [self init];
    if (self)
    {
        [_keys addObjectsFromArray:keys];
    }
    return self;
}

- (instancetype)initWithPendingItems:(MHVCollection *)pendingItems
{
    MHVCHECK_NOTNULL(pendingItems);
    
    self = [self init];
    if (self)
    {
        for (MHVPendingItem *item in pendingItems)
        {
            [_keys addObject:item.key];
        }
    }
    return self;
}

- (instancetype)initWithItemKey:(MHVItemKey *)key andType:(NSString *)typeID
{
    self = [self init];
    if (self)
    {
        [_keys addObject:key];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (instancetype)initWithItemID:(NSString *)itemID andType:(NSString *)typeID
{
    MHVCHECK_STRING(itemID);
    
    self = [self init];
    if (self)
    {
        [_itemIDs addObject:itemID];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (instancetype)initWithClientID:(NSString *)clientID andType:(NSString *)typeID
{
    MHVCHECK_STRING(clientID);
    
    self = [self init];
    if (self)
    {
        [_clientIDs addObject:clientID];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(self.view, MHVClientError_InvalidItemQuery);
    
    MHVVALIDATE_ARRAYOPTIONAL(self.itemIDs, MHVClientError_InvalidItemQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.keys, MHVClientError_InvalidItemQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.filters, MHVClientError_InvalidItemQuery);
    
    MHVVALIDATE_OPTIONAL(self.max);
    MHVVALIDATE_OPTIONAL(self.maxFull);
    
    MHVVALIDATE_SUCCESS;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:self.name];
    if (self.max)
    {
        [writer writeAttribute:c_attribute_max intValue:self.max.value];
    }
    
    if (self.maxFull)
    {
        [writer writeAttribute:c_attribute_maxfull intValue:self.maxFull.value];
    }
}

- (void)serialize:(XWriter *)writer
{
    //
    // Query xml schema says - ids are a choice element
    //
    if (![MHVCollection isNilOrEmpty:self.itemIDs])
    {
        [writer writeElementArray:c_element_id elements:self.itemIDs.toArray];        
    }
    else if (![MHVCollection isNilOrEmpty:self.keys])
    {
        [writer writeElementArray:c_element_key elements:self.keys.toArray];        
    }
    else if (![MHVCollection isNilOrEmpty:self.clientIDs])
    {
        [writer writeElementArray:c_element_clientID elements:self.clientIDs.toArray]; 
    }
    
    [writer writeElementArray:c_element_filter elements:self.filters.toArray];
    [writer writeElement:c_element_view content:self.view];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.name = [reader readAttribute:c_attribute_name];
    
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

- (void)deserialize:(XReader *)reader
{
    self.itemIDs = [reader readStringElementArray:c_element_id];
    self.keys = (MHVItemKeyCollection *)[reader readElementArray:c_element_key
                                                         asClass:[MHVItemKey class]
                                                   andArrayClass:[MHVItemKeyCollection class]];
    self.clientIDs = [reader readStringElementArray:c_element_clientID];
    self.filters = (MHVItemFilterCollection *)[reader readElementArray:c_element_filter
                                                               asClass:[MHVItemFilter class]
                                                         andArrayClass:[MHVItemFilterCollection class]];
    self.view = [reader readElement:c_element_view asClass:[MHVItemView class]];
}

@end

@implementation MHVItemQueryCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVItemQuery class];
    }
    return self;
}

@end
