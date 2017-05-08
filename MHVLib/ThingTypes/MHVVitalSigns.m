//
//  MHVVitalSigns.m
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
#import "MHVVitalSigns.h"

static NSString* const c_typeid = @"73822612-c15f-4b49-9e65-6af369e55c65";
static NSString* const c_typename = @"vital-signs";

static NSString* const c_element_when = @"when";
static NSString* const c_element_results = @"vital-signs-results";
static NSString* const c_element_site = @"site";
static NSString* const c_element_position = @"position";

@implementation MHVVitalSigns

@synthesize when = m_when;
@synthesize results = m_results;
@synthesize site = m_site;
@synthesize position = m_position;

-(BOOL)hasResults
{
    return ![MHVCollection isNilOrEmpty:m_results];
}

-(MHVVitalSignResultCollection *)results
{
    MHVENSURE(m_results, MHVVitalSignResultCollection);
    return m_results;
}

-(void)setResults:(MHVVitalSignResultCollection *)results
{
    m_results = results;
}

-(MHVVitalSignResult *)firstResult
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

-(id)initWithResult:(MHVVitalSignResult *)result onDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(m_when);
    
    if (result)
    {
        [self.results addObject:result];
        MHVCHECK_NOTNULL(m_results);
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_when, MHVClientError_InvalidVitalSigns);
    MHVVALIDATE_ARRAYOPTIONAL(m_results, MHVClientError_InvalidVitalSigns);
    MHVVALIDATE_STRINGOPTIONAL(m_site, MHVClientError_InvalidVitalSigns);
    MHVVALIDATE_STRINGOPTIONAL(m_position, MHVClientError_InvalidVitalSigns);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElementArray:c_element_results elements:m_results.toArray];
    [writer writeElement:c_element_site value:m_site];
    [writer writeElement:c_element_position value:m_position];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVDateTime class]];
    m_results = (MHVVitalSignResultCollection *)[reader readElementArray:c_element_results asClass:[MHVVitalSignResult class] andArrayClass:[MHVVitalSignResultCollection class]];
    m_site = [reader readStringElement:c_element_site];
    m_position = [reader readStringElement:c_element_position];
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
    return [[MHVItem alloc] initWithType:[MHVVitalSigns typeID]];
}

@end
