//
//  MHVImmunization.m
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
#import "MHVImmunization.h"
#import "MHVClient.h"

static NSString* const c_typeid = @"cd3587b5-b6e1-4565-ab3b-1c3ad45eb04f";
static NSString* const c_typename = @"immunization";

static NSString* const c_element_name = @"name";
static NSString* const c_element_administeredDate = @"administration-date";
static NSString* const c_element_administrator = @"administrator";
static NSString* const c_element_manufacturer = @"manufacturer";
static NSString* const c_element_lot = @"lot";
static NSString* const c_element_route = @"route";
static NSString* const c_element_expiration = @"expiration-date";
static NSString* const c_element_sequence = @"sequence";
static NSString* const c_element_surface = @"anatomic-surface";
static NSString* const c_element_adverseEvent = @"adverse-event";
static NSString* const c_element_consent = @"consent";

@implementation MHVImmunization

@synthesize name = m_name;
@synthesize administeredDate = m_administeredDate;
@synthesize administrator = m_administrator;
@synthesize manufacturer = m_manufacturer;
@synthesize lot = m_lot;
@synthesize route = m_route;
@synthesize expiration = m_expiration;
@synthesize sequence = m_sequence;
@synthesize anatomicSurface = m_anatomicSurface;
@synthesize adverseEvent = m_adverseEvent;
@synthesize consent = m_consent;

-(id)initWithName:(NSString *)name
{
    MHVCHECK_STRING(name);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSDate *)getDate
{
    return (m_administeredDate) ? [m_administeredDate toDate] : nil;
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return (m_administeredDate) ? [m_administeredDate toDateForCalendar:calendar] : nil;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

+(MHVVocabIdentifier *)vocabForName
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunizations-common"];    
}

+(MHVVocabIdentifier *)vocabForAdverseEvent
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-adverse-effect"];        
}

+(MHVVocabIdentifier *)vocabForManufacturer
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hl7Family andName:@"vaccine-manufacturers-mvx"];            
}

+(MHVVocabIdentifier *)vocabForSurface
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-anatomic-surface"];                
}

+(MHVVocabIdentifier *)vocabForRoute
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-routes"];                    
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_name, MHVClientError_InvalidImmunization);
    MHVVALIDATE_OPTIONAL(m_administeredDate);
    MHVVALIDATE_OPTIONAL(m_administrator);
    MHVVALIDATE_OPTIONAL(m_manufacturer);
    MHVVALIDATE_STRINGOPTIONAL(m_lot, MHVClientError_InvalidImmunization);
    MHVVALIDATE_OPTIONAL(m_route);
    MHVVALIDATE_OPTIONAL(m_expiration);
    MHVVALIDATE_STRINGOPTIONAL(m_sequence, MHVClientError_InvalidImmunization);
    MHVVALIDATE_OPTIONAL(m_anatomicSurface);
    MHVVALIDATE_STRINGOPTIONAL(m_adverseEvent, MHVClientError_InvalidImmunization);
    MHVVALIDATE_STRINGOPTIONAL(m_consent, MHVClientError_InvalidImmunization);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_administeredDate content:m_administeredDate];
    [writer writeElement:c_element_administrator content:m_administrator];
    [writer writeElement:c_element_manufacturer content:m_manufacturer];
    [writer writeElement:c_element_lot value:m_lot];
    [writer writeElement:c_element_route content:m_route];
    [writer writeElement:c_element_expiration content:m_expiration];
    [writer writeElement:c_element_sequence value:m_sequence];
    [writer writeElement:c_element_surface content:m_anatomicSurface];
    [writer writeElement:c_element_adverseEvent value:m_adverseEvent];
    [writer writeElement:c_element_consent value:m_consent];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_administeredDate = [reader readElement:c_element_administeredDate asClass:[MHVApproxDateTime class]];
    m_administrator = [reader readElement:c_element_administrator asClass:[MHVPerson class]];
    m_manufacturer = [reader readElement:c_element_manufacturer asClass:[MHVCodableValue class]];
    m_lot = [reader readStringElement:c_element_lot];
    m_route = [reader readElement:c_element_route asClass:[MHVCodableValue class]];
    m_expiration = [reader readElement:c_element_expiration asClass:[MHVApproxDate class]];
    m_sequence = [reader readStringElement:c_element_sequence];
    m_anatomicSurface = [reader readElement:c_element_surface asClass:[MHVCodableValue class]];
    m_adverseEvent = [reader readStringElement:c_element_adverseEvent];
    m_consent = [reader readStringElement:c_element_consent];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVImmunization typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Immunization", @"Immunization Type Name");
}

@end
