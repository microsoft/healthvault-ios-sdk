//
// MHVMessageHeaderItem.m
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
#import "MHVMessageHeaderItem.h"

static const xmlChar *x_element_name = XMLSTRINGCONST("name");
static const xmlChar *x_element_value = XMLSTRINGCONST("value");

@implementation MHVMessageHeaderItem

- (instancetype)initWithName:(NSString *)name value:(NSString *)value
{
    MHVCHECK_STRING(name);
    MHVCHECK_STRING(value);

    self = [super init];
    if (self)
    {
        _name = name;
        _value = value;
    }

    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_STRING(self.name, MHVClientError_InvalidMessageHeader);
    MHVVALIDATE_STRING(self.value, MHVClientError_InvalidMessageHeader);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_name value:self.name];
    [writer writeElementXmlName:x_element_value value:self.value];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElementWithXmlName:x_element_name];
    self.value = [reader readStringElementWithXmlName:x_element_value];
}

@end

@implementation MHVMessageHeaderItemCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVMessageHeaderItem class];
    }

    return self;
}

- (NSUInteger)indexOfHeaderWithName:(NSString *)name
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        MHVMessageHeaderItem *header = [self objectAtIndex:i];
        if ([header.name isEqualToStringCaseInsensitive:name])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (MHVMessageHeaderItem *)headerWithName:(NSString *)name
{
    NSUInteger index = [self indexOfHeaderWithName:name];

    if (index != NSNotFound)
    {
        return [self objectAtIndex:index];
    }

    return nil;
}

@end
