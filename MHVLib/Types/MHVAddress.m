//
//  MHVAddress.m
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
#import "MHVAddress.h"

static NSString* const c_element_description = @"description";
static NSString* const c_element_isPrimary = @"is-primary";
static NSString* const c_element_street = @"street";
static NSString* const c_element_city = @"city";
static NSString* const c_element_state = @"state";
static NSString* const c_element_postalCode = @"postcode";
static NSString* const c_element_country = @"country";
static NSString* const c_element_county = @"county";

@implementation MHVAddress

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

-(MHVStringCollection *)street
{
    MHVENSURE(m_street, MHVStringCollection);
    return m_street;
}

-(void)setStreet:(MHVStringCollection *)street
{
    m_street = street;
}


-(NSString *)toString
{
    NSMutableString* text = [[NSMutableString alloc] init];
    
    [text appendOptionalWords:[m_street toString]];
    
    [text appendOptionalStringOnNewLine:m_city];
    [text appendOptionalStringOnNewLine:m_county];        
    
    [text appendOptionalStringOnNewLine:m_state];
    [text appendOptionalWords:m_postalCode];
    [text appendOptionalStringOnNewLine:m_country];
    
    return text;
}

-(NSString *)description
{
    return [self toString];
}

+(MHVVocabIdentifier *)vocabForCountries
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_isoFamily andName:@"iso3166"];        
}

+(MHVVocabIdentifier *)vocabForUSStates
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"states"];        
}

+(MHVVocabIdentifier *)vocabForCanadianProvinces
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"provinces"];        
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(m_street, MHVClientError_InvalidAddress);
    MHVVALIDATE_STRING(m_city, MHVClientError_InvalidAddress);
    MHVVALIDATE_STRING(m_postalCode, MHVClientError_InvalidAddress);
    MHVVALIDATE_STRING(m_country, MHVClientError_InvalidAddress);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_description value:m_type];
    [writer writeElement:c_element_isPrimary content:m_isprimary];
    [writer writeElementArray:c_element_street elements:m_street];
    [writer writeElement:c_element_city value:m_city];
    [writer writeElement:c_element_state value:m_state];
    [writer writeElement:c_element_postalCode value:m_postalCode];
    [writer writeElement:c_element_country value:m_country];
    [writer writeElement:c_element_county value:m_county];
}

-(void)deserialize:(XReader *)reader
{
    m_type = [reader readStringElement:c_element_description];
    m_isprimary = [reader readElement:c_element_isPrimary asClass:[MHVBool class]];
    m_street = [reader readStringElementArray:c_element_street];
    m_city = [reader readStringElement:c_element_city];
    m_state = [reader readStringElement:c_element_state];
    m_postalCode = [reader readStringElement:c_element_postalCode];
    m_country = [reader readStringElement:c_element_country];
    m_county = [reader readStringElement:c_element_county];    
}

@end

@implementation MHVAddressCollection

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVAddress class];
    
    return self;
}

-(MHVAddress *)itemAtIndex:(NSUInteger)index
{
    return (MHVAddress *) [self objectAtIndex:index];
}
@end
