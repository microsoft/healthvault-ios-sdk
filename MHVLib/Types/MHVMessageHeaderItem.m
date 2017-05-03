//
//  MHVMessageHeaderItem.m
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
#import "MHVMessageHeaderItem.h"

static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");

@implementation MHVMessageHeaderItem

@synthesize name = m_name;
@synthesize value = m_value;

-(id)initWithName:(NSString *)name value:(NSString *)value
{
    HVCHECK_STRING(name);
    HVCHECK_STRING(value);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = name;
    m_value = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(MHVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_name, HVClientError_InvalidMessageHeader);
    HVVALIDATE_STRING(m_value, HVClientError_InvalidMessageHeader);
    
    HVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_name value:m_name];
    [writer writeElementXmlName:x_element_value value:m_value];
}

-(void) deserialize:(XReader *)reader
{
    m_name = [reader readStringElementWithXmlName:x_element_name];
    m_value = [reader readStringElementWithXmlName:x_element_value];
}

@end

@implementation MHVMessageHeaderItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVMessageHeaderItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(MHVMessageHeaderItem *)itemAtIndex:(NSUInteger)index
{
    return (MHVMessageHeaderItem *) [self objectAtIndex:index];
}

-(NSUInteger)indexOfHeaderWithName:(NSString *)name
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        MHVMessageHeaderItem* header = [self itemAtIndex:i];
        if ([header.name isEqualToStringCaseInsensitive:name])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(MHVMessageHeaderItem *)headerWithName:(NSString *)name
{
    NSUInteger index = [self indexOfHeaderWithName:name];
    if (index != NSNotFound)
    {
        return [self itemAtIndex:index];
    }
    
    return nil;
}

@end

