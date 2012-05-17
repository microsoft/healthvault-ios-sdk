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
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_type, c_element_type);
    HVSERIALIZE_STRING(m_reason, c_element_reason);
    HVSERIALIZE(m_duration, c_element_duration);
    HVSERIALIZE(m_constentGranted, c_element_consent);
    HVSERIALIZE(m_facility, c_element_facility);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_type, c_element_type, HVCodableValue);
    HVDESERIALIZE_STRING(m_reason, c_element_reason);
    HVDESERIALIZE(m_duration, c_element_duration, HVDuration);
    HVDESERIALIZE(m_constentGranted, c_element_consent, HVBool);
    HVDESERIALIZE(m_facility, c_element_facility, HVOrganization);
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
