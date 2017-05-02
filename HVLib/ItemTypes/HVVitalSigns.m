//
//  HVVitalSigns.m
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
#import "HVVitalSigns.h"

static NSString* const c_typeid = @"73822612-c15f-4b49-9e65-6af369e55c65";
static NSString* const c_typename = @"vital-signs";

static NSString* const c_element_when = @"when";
static NSString* const c_element_results = @"vital-signs-results";
static NSString* const c_element_site = @"site";
static NSString* const c_element_position = @"position";

@implementation HVVitalSigns

@synthesize when = m_when;
@synthesize results = m_results;
@synthesize site = m_site;
@synthesize position = m_position;

-(BOOL)hasResults
{
    return ![NSArray isNilOrEmpty:m_results];
}

-(HVVitalSignResultCollection *)results
{
    HVENSURE(m_results, HVVitalSignResultCollection);
    return m_results;
}

-(void)setResults:(HVVitalSignResultCollection *)results
{
    HVRETAIN(m_results, results);
}

-(HVVitalSignResult *)firstResult
{
    return (self.hasResults) ? [m_results itemAtIndex:0] : nil;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(id)initWithDate:(NSDate *)date
{
    return [self initWithResult:nil onDate:date];
}

-(id)initWithResult:(HVVitalSignResult *)result onDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    if (result)
    {
        [self.results addObject:result];
        HVCHECK_NOTNULL(m_results);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_when release];
    [m_results release];
    [m_site release];
    [m_position release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidVitalSigns);
    HVVALIDATE_ARRAYOPTIONAL(m_results, HVClientError_InvalidVitalSigns);
    HVVALIDATE_STRINGOPTIONAL(m_site, HVClientError_InvalidVitalSigns);
    HVVALIDATE_STRINGOPTIONAL(m_position, HVClientError_InvalidVitalSigns);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElementArray:c_element_results elements:m_results];
    [writer writeElement:c_element_site value:m_site];
    [writer writeElement:c_element_position value:m_position];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElement:c_element_when asClass:[HVDateTime class]] retain];
    m_results = (HVVitalSignResultCollection *)[[reader readElementArray:c_element_results asClass:[HVVitalSignResult class] andArrayClass:[HVVitalSignResultCollection class]] retain];
    m_site = [[reader readStringElement:c_element_site] retain];
    m_position = [[reader readStringElement:c_element_position] retain];
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
    return [[HVItem alloc] initWithType:[HVVitalSigns typeID]];
}

@end
