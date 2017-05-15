//
// MHVItemData.m
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
#import "MHVItemData.h"
#import "MHVItemType.h"
#import "MHVItemRaw.h"

static NSString *const c_element_common = @"common";

@implementation MHVItemData

- (BOOL)hasTyped
{
    return self.typed != nil;
}

- (MHVItemDataTyped *)typed
{
    if (!_typed)
    {
        _typed = [[MHVItemDataTyped alloc] init];
    }
    
    return _typed;
}

- (BOOL)hasCommon
{
    return self.common != nil;
}

- (MHVItemDataCommon *)common
{
    if (!_common)
    {
        _common = [[MHVItemDataCommon alloc] init];
    }
    
    return _common;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(self.common);
    MHVVALIDATE_OPTIONAL(self.typed);
    
    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    if (self.typed)
    {
        [writer writeElement:self.typed.rootElement content:self.typed];
    }
    
    [writer writeElement:c_element_common content:self.common];
}

- (void)deserialize:(XReader *)reader
{
    if (![reader isStartElementWithName:c_element_common])
    {
        //
        // Typed Item Data!
        //
        self.typed = [self deserializeTyped:reader];
        if (!self.typed)
        {
            self.typed = [self deserializeRaw:reader];
        }
        
        MHVCHECK_OOM(self.typed);
    }
    
    if ([reader isStartElementWithName:c_element_common])
    {
        self.common = [reader readElement:c_element_common asClass:[MHVItemDataCommon class]];
    }
}

#pragma mark - Internal methods

- (MHVItemDataTyped *)deserializeTyped:(XReader *)reader
{
    MHVItemType *itemType = (MHVItemType *)reader.context;
    NSString *typeID = (itemType != nil) ? itemType.typeID : nil;
    
    MHVItemDataTyped *typedItem = [[MHVTypeSystem current] newFromTypeID:typeID];
    
    if (typedItem)
    {
        if (typedItem.hasRawData)
        {
            [typedItem deserialize:reader];
        }
        else
        {
            [reader readElementRequired:reader.localName intoObject:typedItem];
        }
    }
    
    return typedItem;
}

- (MHVItemRaw *)deserializeRaw:(XReader *)reader
{
    MHVItemRaw *raw = [[MHVItemRaw alloc] init];
    
    if (raw)
    {
        [raw deserialize:reader];
    }
    
    return raw;
}

@end
