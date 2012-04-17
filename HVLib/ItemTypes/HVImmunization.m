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

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
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
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_administeredDate, c_element_administeredDate);
    HVSERIALIZE(m_administrator, c_element_administrator);
    HVSERIALIZE(m_manufacturer, c_element_manufacturer);
    HVSERIALIZE_STRING(m_lot, c_element_lot);
    HVSERIALIZE(m_route, c_element_route);
    HVSERIALIZE(m_expiration, c_element_expiration);
    HVSERIALIZE_STRING(m_sequence, c_element_sequence);
    HVSERIALIZE(m_anatomicSurface, c_element_surface);
    HVSERIALIZE_STRING(m_adverseEvent, c_element_adverseEvent);
    HVSERIALIZE_STRING(m_consent, c_element_consent);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_administeredDate, c_element_administeredDate, HVApproxDateTime);
    HVDESERIALIZE(m_administrator, c_element_administrator, HVPerson);
    HVDESERIALIZE(m_manufacturer, c_element_manufacturer, HVCodableValue);
    HVDESERIALIZE_STRING(m_lot, c_element_lot);
    HVDESERIALIZE(m_route, c_element_route, HVCodableValue);
    HVDESERIALIZE(m_expiration, c_element_expiration, HVApproxDate);
    HVDESERIALIZE_STRING(m_sequence, c_element_sequence);
    HVDESERIALIZE(m_anatomicSurface, c_element_surface, HVCodableValue);
    HVDESERIALIZE_STRING(m_adverseEvent, c_element_adverseEvent);
    HVDESERIALIZE_STRING(m_consent, c_element_consent);
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

@end
