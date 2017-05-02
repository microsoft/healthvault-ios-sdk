//
//  HVImmunization.m
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
#import "HVImmunization.h"
#import "HVClient.h"

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

@implementation HVImmunization

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
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[HVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_administeredDate release];
    [m_administrator release];
    [m_manufacturer release];
    [m_lot release];
    [m_route release];
    [m_expiration release];
    [m_sequence release];
    [m_anatomicSurface release];
    [m_adverseEvent release];
    [m_consent release];
   
    [super dealloc];
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

+(HVVocabIdentifier *)vocabForName
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunizations-common"] autorelease];    
}

+(HVVocabIdentifier *)vocabForAdverseEvent
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-adverse-effect"] autorelease];        
}

+(HVVocabIdentifier *)vocabForManufacturer
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hl7Family andName:@"vaccine-manufacturers-mvx"] autorelease];            
}

+(HVVocabIdentifier *)vocabForSurface
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-anatomic-surface"] autorelease];                
}

+(HVVocabIdentifier *)vocabForRoute
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"immunization-routes"] autorelease];                    
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidImmunization);
    HVVALIDATE_OPTIONAL(m_administeredDate);
    HVVALIDATE_OPTIONAL(m_administrator);
    HVVALIDATE_OPTIONAL(m_manufacturer);
    HVVALIDATE_STRINGOPTIONAL(m_lot, HVClientError_InvalidImmunization);
    HVVALIDATE_OPTIONAL(m_route);
    HVVALIDATE_OPTIONAL(m_expiration);
    HVVALIDATE_STRINGOPTIONAL(m_sequence, HVClientError_InvalidImmunization);
    HVVALIDATE_OPTIONAL(m_anatomicSurface);
    HVVALIDATE_STRINGOPTIONAL(m_adverseEvent, HVClientError_InvalidImmunization);
    HVVALIDATE_STRINGOPTIONAL(m_consent, HVClientError_InvalidImmunization);
    
    HVVALIDATE_SUCCESS
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
    m_name = [[reader readElement:c_element_name asClass:[HVCodableValue class]] retain];
    m_administeredDate = [[reader readElement:c_element_administeredDate asClass:[HVApproxDateTime class]] retain];
    m_administrator = [[reader readElement:c_element_administrator asClass:[HVPerson class]] retain];
    m_manufacturer = [[reader readElement:c_element_manufacturer asClass:[HVCodableValue class]] retain];
    m_lot = [[reader readStringElement:c_element_lot] retain];
    m_route = [[reader readElement:c_element_route asClass:[HVCodableValue class]] retain];
    m_expiration = [[reader readElement:c_element_expiration asClass:[HVApproxDate class]] retain];
    m_sequence = [[reader readStringElement:c_element_sequence] retain];
    m_anatomicSurface = [[reader readElement:c_element_surface asClass:[HVCodableValue class]] retain];
    m_adverseEvent = [[reader readStringElement:c_element_adverseEvent] retain];
    m_consent = [[reader readStringElement:c_element_consent] retain];
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
    return [[HVItem alloc] initWithType:[HVImmunization typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Immunization", @"Immunization Type Name");
}

@end
