//
//  BasicDemographics.m
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
#import "HVBasicDemographics.h"

static NSString* const c_gender_female = @"f";
static NSString* const c_gender_male = @"m";

NSString* stringFromGender(enum HVGender gender)
{
    NSString* genderString = nil;
    
    switch (gender) {
        case HVGenderFemale:
            genderString = c_gender_female; 
            break;
        
        case HVGenderMale:
            genderString = c_gender_male;
            break;
            
        default:
            break;
    }
    
    return genderString;
}

enum HVGender stringToGender(NSString* genderString)
{
    if ([genderString isEqualToString:c_gender_female])
    {
        return HVGenderFemale;
    }
    
    if ([genderString isEqualToString:c_gender_male])
    {
        return HVGenderMale;
    }
    
    return HVGenderNone;   
}


static NSString* const c_typeid = @"3b3e6b16-eb69-483c-8d7e-dfe116ae6092";
static NSString* const c_typename = @"basic";

static NSString* const c_element_gender = @"gender";
static NSString* const c_element_birthyear = @"birthyear";
static NSString* const c_element_country = @"country";
static NSString* const c_element_postcode = @"postcode";
static NSString* const c_element_city = @"city";
static NSString* const c_element_state = @"state";
static NSString* const c_element_dow = @"firstdow";
static NSString* const c_element_lang = @"language";

@implementation HVBasicDemographics

@synthesize gender = m_gender;
@synthesize birthYear = m_birthYear;
@synthesize country = m_country;
@synthesize postalCode = m_postalCode;
@synthesize city = m_city;
@synthesize state = m_state;
@synthesize languageXml = m_languageXml;

-(void)dealloc
{
    [m_birthYear release];
    [m_country release];
    [m_postalCode release];
    [m_city release];
    [m_state release];
    [m_firstDOW release];
    [m_languageXml release];
    [super dealloc];
}

-(NSString *)genderAsString
{
    return stringFromGender(m_gender);
}

+(HVVocabIdentifier *)vocabForGender
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"gender-types"] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE_OPTIONAL(m_birthYear);
    HVVALIDATE_OPTIONAL(m_country);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_gender value:stringFromGender(m_gender)];
    [writer writeElement:c_element_birthyear content:m_birthYear];
    [writer writeElement:c_element_country content:m_country];
    [writer writeElement:c_element_postcode value:m_postalCode];
    [writer writeElement:c_element_city value:m_city];
    [writer writeElement:c_element_state content:m_state];
    [writer writeElement:c_element_dow content:m_firstDOW];
    [writer writeRaw:m_languageXml];
}

-(void)deserialize:(XReader *)reader
{
    NSString* gender = [[reader readStringElement:c_element_gender] retain];
    if (gender)
    {
        m_gender = stringToGender(gender);
    }
    
    m_birthYear = [[reader readElement:c_element_birthyear asClass:[HVYear class]] retain];
    m_country = [[reader readElement:c_element_country asClass:[HVCodableValue class]] retain];
    m_postalCode = [[reader readStringElement:c_element_postcode] retain];
    m_city = [[reader readStringElement:c_element_city] retain];
    m_state = [[reader readElement:c_element_state asClass:[HVCodableValue class]] retain];
    m_firstDOW = [[reader readElement:c_element_dow asClass:[HVInt class]] retain];
    m_languageXml = [[reader readElementRaw:c_element_lang] retain];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVBasicDemographics typeID]];
}

+(BOOL)isSingletonType
{
    return TRUE;
}

@end
