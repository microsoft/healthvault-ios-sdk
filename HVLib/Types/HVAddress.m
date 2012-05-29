//
//  HVAddress.m
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
#import "HVAddress.h"

static NSString* const c_element_description = @"description";
static NSString* const c_element_isPrimary = @"is-primary";
static NSString* const c_element_street = @"street";
static NSString* const c_element_city = @"city";
static NSString* const c_element_state = @"state";
static NSString* const c_element_postalCode = @"postcode";
static NSString* const c_element_country = @"country";
static NSString* const c_element_county = @"county";

@implementation HVAddress

@synthesize type = m_type;
@synthesize isPrimary = m_isprimary;
@synthesize city = m_city;
@synthesize state = m_state;
@synthesize postalCode = m_postalCode;
@synthesize country = m_country;
@synthesize county = m_county;

-(BOOL)hasStreet
{
    return ![NSArray isNilOrEmpty:m_street];
}

-(HVStringCollection *)street
{
    HVENSURE(m_street, HVStringCollection);
    return m_street;
}

-(void)setStreet:(HVStringCollection *)street
{
    HVRETAIN(m_street, street);
}

-(void)dealloc
{
    [m_type release];
    [m_isprimary release];
    [m_street release];
    [m_city release];
    [m_state release];
    [m_postalCode release];
    [m_country release];
    [m_county release];

    [super dealloc];
}

-(NSString *)toString
{
    NSMutableString* text = [[[NSMutableString alloc] init] autorelease];
    
    [text appendOptionalStringAsLine:[m_street toString]];
    
    [text appendOptionalWords:m_city];
    [text appendOptionalWords:m_county];
    [text appendOptionalWords:m_state];
    [text appendOptionalWords:m_postalCode];
    
    if (m_country && text.length > 0)
    {
        [text appendNewLine];
        [text appendStringAsLine:m_country];
    }
    
    return text;
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_street, HVClientError_InvalidAddress);
    HVVALIDATE_STRING(m_city, HVClientError_InvalidAddress);
    HVVALIDATE_STRING(m_postalCode, HVClientError_InvalidAddress);
    HVVALIDATE_STRING(m_country, HVClientError_InvalidAddress);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_type, c_element_description);
    HVSERIALIZE(m_isprimary, c_element_isPrimary);
    HVSERIALIZE_STRINGCOLLECTION(m_street, c_element_street);
    HVSERIALIZE_STRING(m_city, c_element_city);
    HVSERIALIZE_STRING(m_state, c_element_state);
    HVSERIALIZE_STRING(m_postalCode, c_element_postalCode);
    HVSERIALIZE_STRING(m_country, c_element_country);
    HVSERIALIZE_STRING(m_county, c_element_county);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_type, c_element_description);
    HVDESERIALIZE(m_isprimary, c_element_isPrimary, HVBool);
    HVDESERIALIZE_STRINGCOLLECTION(m_street, c_element_street);
    HVDESERIALIZE_STRING(m_city, c_element_city);
    HVDESERIALIZE_STRING(m_state, c_element_state);
    HVDESERIALIZE_STRING(m_postalCode, c_element_postalCode);
    HVDESERIALIZE_STRING(m_country, c_element_country);
    HVDESERIALIZE_STRING(m_county, c_element_county);    
}

@end

@implementation HVAddressCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVAddress class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVAddress *)itemAtIndex:(NSUInteger)index
{
    return (HVAddress *) [self objectAtIndex:index];
}
@end