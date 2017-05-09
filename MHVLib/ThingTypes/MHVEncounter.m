//
//  MHVEncounter.m
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
//
#import "MHVCommon.h"
#import "MHVEncounter.h"

static NSString* const c_typeid = @"464083cc-13de-4f3e-a189-da8e47d5651b";
static NSString* const c_typename = @"encounter";

static NSString* const c_element_when = @"when";
static NSString* const c_element_type = @"type";
static NSString* const c_element_reason = @"reason";
static NSString* const c_element_duration = @"duration";
static NSString* const c_element_consent = @"consent-granted";
static NSString* const c_element_facility = @"facility";

@implementation MHVEncounter

@synthesize when = m_when;
@synthesize encounterType = m_type;
@synthesize reason = m_reason;
@synthesize duration = m_duration;
@synthesize consent = m_constentGranted;
@synthesize facility = m_facility;


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_when);
    MHVVALIDATE_OPTIONAL(m_type);
    MHVVALIDATE_STRINGOPTIONAL(m_reason, MHVClientError_InvalidEncounter);
    MHVVALIDATE_OPTIONAL(m_duration);
    MHVVALIDATE_OPTIONAL(m_constentGranted);
    MHVVALIDATE_OPTIONAL(m_facility);
    
    MHVVALIDATE_SUCCESS
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
    m_when = [reader readElement:c_element_when asClass:[MHVDateTime class]];
    m_type = [reader readElement:c_element_type asClass:[MHVCodableValue class]];
    m_reason = [reader readStringElement:c_element_reason];
    m_duration = [reader readElement:c_element_duration asClass:[MHVDuration class]];
    m_constentGranted = [reader readElement:c_element_consent asClass:[MHVBool class]];
    m_facility = [reader readElement:c_element_facility asClass:[MHVOrganization class]];
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
    return [[MHVItem alloc] initWithType:[MHVEncounter typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Encounter", @"Encounter Type Name");
}

@end
