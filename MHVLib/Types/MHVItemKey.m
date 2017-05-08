//
// MHVItemKey.m
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
#import "MHVItemKey.h"
#import "MHVValidator.h"
#import "MHVGuid.h"

static const xmlChar *x_attribute_version = XMLSTRINGCONST("version-stamp");
static NSString *const c_localIDPrefix = @"L";

@implementation MHVItemKey

- (BOOL)hasVersion
{
    return ![NSString isNilOrEmpty:self.version];
}

- (instancetype)initWithID:(NSString *)itemID
{
    return [self initWithID:itemID andVersion:nil];
}

- (instancetype)initWithID:(NSString *)itemID andVersion:(NSString *)version
{
    if (!itemID)
    {
        MHVASSERT_PARAMETER(itemID);
        return nil;
    }

    self = [super init];
    
    if (self)
    {
        self.itemID = itemID;
        if (version)
        {
            self.version = version;
        }
    }

    return self;
}

- (instancetype)initWithKey:(MHVItemKey *)key
{
    if (!key)
    {
        MHVASSERT_PARAMETER(key);
        return nil;
    }

    return [self initWithID:key.itemID andVersion:key.version];
}

- (instancetype)initNew
{
    return [self initWithID:[[NSUUID UUID] UUIDString]];
}

+ (MHVItemKey *)newLocal
{
    NSString *itemID =  [c_localIDPrefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
    NSString *version = [[NSUUID UUID] UUIDString];

    return [[MHVItemKey alloc] initWithID:itemID andVersion:version];
}

+ (MHVItemKey *)local
{
    return [MHVItemKey newLocal];
}

- (BOOL)isVersion:(NSString *)version
{
    return [self.version isEqualToString:version];
}

- (BOOL)isLocal
{
    return [self.itemID hasPrefix:c_localIDPrefix];
}

- (BOOL)isEqualToKey:(MHVItemKey *)key
{
    if (!key)
    {
        MHVASSERT_PARAMETER(key);
        return NO;
    }

    return [self.itemID isEqualToString:key.itemID] &&
           (self.version && key.version) &&
           [self.version isEqualToString:key.version]
    ;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_STRING(self.itemID, MHVClientError_InvalidItemKey);

    MHVVALIDATE_STRING(self.version, MHVClientError_InvalidItemKey);

    MHVVALIDATE_SUCCESS
}

- (NSString *)description
{
    return self.itemID;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttributeXmlName:x_attribute_version value:self.version];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeText:self.itemID];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.version = [reader readAttributeWithXmlName:x_attribute_version];
}

- (void)deserialize:(XReader *)reader
{
    self.itemID = [reader readValue];
}

@end

static NSString *const c_element_key = @"thing-id";

@interface MHVItemKeyCollection ()

@property (nonatomic, strong) NSMutableArray *inner;

@end

@implementation MHVItemKeyCollection

- (instancetype)init
{
    return [self initWithKey:nil];
}

- (instancetype)initWithKey:(MHVItemKey *)key
{
    self = [super init];

    if (self)
    {
        _inner = [NSMutableArray new];

        self.type = [MHVItemKey class];

        if (key)
        {
            [self addObject:key];
        }
    }

    return self;
}

- (void)addItem:(MHVItemKey *)key
{
    [super addObject:key];
}

- (MHVItemKey *)firstKey
{
    return [self itemAtIndex:0];
}

- (MHVItemKey *)itemAtIndex:(NSUInteger)index
{
    return (MHVItemKey *)[self objectAtIndex:index];
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_ARRAY(self, MHVClientError_InvalidItemList);

    MHVVALIDATE_SUCCESS
}

- (void)serializeAttributes:(XWriter *)writer
{
}

- (void)deserializeAttributes:(XReader *)reader
{
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_key elements:self.inner];
}

- (void)deserialize:(XReader *)reader
{
    _inner = [reader readElementArray:c_element_key asClass:[MHVItemKey class]];
}

@end
