//
//  HVEncounter.m
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
//
#import "HVCommon.h"
#import "HVEncounter.h"

static NSString* const c_typeid = @"464083cc-13de-4f3e-a189-da8e47d5651b";
static NSString* const c_typename = @"encounter";

static NSString* const c_element_when = @"when";
static NSString* const c_element_type = @"type";
static NSString* const c_element_reason = @"reason";
static NSString* const c_element_duration = @"duration";
static NSString* const c_element_consent = @"consent-granted";
static NSString* const c_element_facility = @"facility";

@implementation HVEncounter

@synthesize when = m_when;
@synthesize encounterType = m_type;
@synthesize reason = m_reason;
@synthesize duration = m_duration;
@synthesize consent = m_constentGranted;
@synthesize facility = m_facility;

-(void)dealloc
{
    [m_when release];
    [m_type release];
    [m_reason release];
    [m_duration release];
    [m_constentGranted release];
    [m_facility release];
    
    [super dealloc];
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_OPTIONAL(m_type);
    HVVALIDATE_STRINGOPTIONAL(m_reason, HVClientError_InvalidEncounter);
    HVVALIDATE_OPTIONAL(m_duration);
    HVVALIDATE_OPTIONAL(m_constentGranted);
    HVVALIDATE_OPTIONAL(m_facility);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_type content:m_type];
    [writer writeElement:c_element_reason value:m_reason];
    [writer writeElement:c_element_duration content:m_duration];
    [writer writeElement:c_element_consent content:m_constentGranted];
    [writer writeElement:c_element_facility content:m_facility];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElement:c_element_when asClass:[HVDateTime class]] retain];
    m_type = [[reader readElement:c_element_type asClass:[HVCodableValue class]] retain];
    m_reason = [[reader readStringElement:c_element_reason] retain];
    m_duration = [[reader readElement:c_element_duration asClass:[HVDuration class]] retain];
    m_constentGranted = [[reader readElement:c_element_consent asClass:[HVBool class]] retain];
    m_facility = [[reader readElement:c_element_facility asClass:[HVOrganization class]] retain];
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
    return [[HVItem alloc] initWithType:[HVEncounter typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Encounter", @"Encounter Type Name");
}

@end
