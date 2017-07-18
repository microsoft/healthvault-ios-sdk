//
// MHVThingQuery.m
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

#import "MHVThingQuery.h"
#import "MHVStringExtensions.h"
#import "MHVArrayExtensions.h"
#import "MHVValidator.h"
#import "MHVType.h"
#import "MHVPendingThing.h"

static NSString *const c_attribute_name = @"name";
static NSString *const c_attribute_maxfull = @"max-full";
static NSString *const c_element_id = @"id";
static NSString *const c_element_key = @"key";
static NSString *const c_element_clientID = @"client-thing-id";
static NSString *const c_element_filter = @"filter";
static NSString *const c_element_view = @"format";

@interface MHVThingQuery ()

@property (readwrite, nonatomic, strong) MHVThingKeyCollectionInternal *keysInternal;
@property (readwrite, nonatomic, strong) MHVThingFilterCollectionInternal *filtersInternal;

@end

@implementation MHVThingQuery


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _view = [[MHVThingView alloc] init];
        _thingIDs = @[];
        _keysInternal = [MHVThingKeyCollectionInternal new];
        _clientIDs = @[];
        _filtersInternal = [MHVThingFilterCollectionInternal new];
        _limit = 240;
        _offset = 0;
        _shouldUseCachedResults = YES;
    }
    
    return self;
}

- (NSArray<MHVThingKey *> *)keys
{
    if (!self.keysInternal)
    {
        self.keysInternal = [MHVThingKeyCollectionInternal new];
    }
    return self.keysInternal.toArray;
}

- (void)setKeys:(NSArray<MHVThingKey *> *)keys
{
    self.keysInternal = [[MHVThingKeyCollectionInternal alloc] initWithArray:keys];
}

- (NSArray<MHVThingFilter *> *)filters
{
    if (!self.filtersInternal)
    {
        self.filtersInternal = [MHVThingFilterCollectionInternal new];
    }
    return self.filtersInternal.toArray;
}

- (void)setFilters:(NSArray<MHVThingFilter *> *)filters
{
    self.filtersInternal = [[MHVThingFilterCollectionInternal alloc] initWithArray:filters];
}

- (instancetype)initWithFilter:(MHVThingFilter *)filter
{
    MHVCHECK_NOTNULL(filter);
    
    self = [self init];
    if (self)
    {
        _filtersInternal = [[MHVThingFilterCollectionInternal alloc] initWithArray:@[filter]];
    }
    return self;
}

- (instancetype)initWithFilters:(NSArray<MHVThingFilter *> *)filters
{
    MHVCHECK_NOTNULL(filters);
    
    self = [self init];
    
    if (self)
    {
        _filtersInternal = [[MHVThingFilterCollectionInternal alloc] initWithArray:filters];
    }
    return self;
}

- (instancetype)initWithThingID:(NSString *)thingID
{
    MHVCHECK_STRING(thingID);
    
    self = [self init];
    if (self)
    {
        _thingIDs = @[thingID];
    }
    return self;
}

- (instancetype)initWithThingIDs:(NSArray<NSString *> *)ids
{
    MHVCHECK_NOTNULL(ids);
    
    self = [self init];
    if (self)
    {
        _thingIDs = ids;
    }
    return self;
}

- (instancetype)initWithThingKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    self = [self init];
    if (self)
    {
        _keysInternal = [[MHVThingKeyCollectionInternal alloc] initWithArray:@[key]];
    }
    
    return self;
}

- (instancetype)initWithThingKeys:(NSArray<MHVThingKey *> *)keys
{
    MHVCHECK_NOTNULL(keys);
    
    self = [self init];
    if (self)
    {
        _keysInternal = [[MHVThingKeyCollectionInternal alloc] initWithArray:keys];
    }
    return self;
}

- (void)setView:(MHVThingView *)view
{
    MHVASSERT_PARAMETER(view);
    
    if (view)
    {
        _view = view;
    }
}

- (void)setLimit:(NSUInteger)limit
{
    if (limit <= 500)
    {
        _limit = limit;
    }
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(self.view, MHVClientError_InvalidThingQuery);
    
    MHVVALIDATE_ARRAYOPTIONAL(self.thingIDs, MHVClientError_InvalidThingQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.keysInternal.toArray, MHVClientError_InvalidThingQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.filtersInternal.toArray, MHVClientError_InvalidThingQuery);
    
    MHVVALIDATE_SUCCESS;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:self.name];

    // If the offset property is greater than zero, only partial things will
    // be fetched initially, and subsequent calls to retrieve full things
    // will be issued.
    if (self.offset <= 0)
    {
        [writer writeAttribute:c_attribute_maxfull intValue:(int)self.limit];
    }
    else
    {
        [writer writeAttribute:c_attribute_maxfull intValue:0];
    }
}

- (void)serialize:(XWriter *)writer
{
    //
    // Query xml schema says - ids are a choice element
    //
    if (![NSArray isNilOrEmpty:self.thingIDs])
    {
        [writer writeElementArray:c_element_id elements:self.thingIDs];
    }
    else if (![MHVCollectionInternal isNilOrEmpty:self.keysInternal])
    {
        [writer writeElementArray:c_element_key elements:self.keysInternal];
    }
    else if (![NSArray isNilOrEmpty:self.clientIDs])
    {
        [writer writeElementArray:c_element_clientID elements:self.clientIDs];
    }
    
    [writer writeElementArray:c_element_filter elements:self.filters];
    [writer writeElement:c_element_view content:self.view];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.name = [reader readAttribute:c_attribute_name];
    
    int intValue;
    
    if ([reader readIntAttribute:c_attribute_maxfull intValue:&intValue])
    {
        self.limit = intValue;
    }
}

- (void)deserialize:(XReader *)reader
{
    self.thingIDs = [reader readStringElementArray:c_element_id];
    self.keysInternal = (MHVThingKeyCollectionInternal *)[reader readElementArray:c_element_key
                                                                          asClass:[MHVThingKey class]
                                                                    andArrayClass:[MHVThingKeyCollectionInternal class]];
    self.clientIDs = [reader readStringElementArray:c_element_clientID];
    self.filters = [reader readElementArray:c_element_filter
                                    asClass:[MHVThingFilter class]
                              andArrayClass:[MHVThingFilterCollectionInternal class]];
    self.view = [reader readElement:c_element_view asClass:[MHVThingView class]];
}

@end

