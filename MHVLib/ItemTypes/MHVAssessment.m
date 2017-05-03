//
//  MHVAssessment.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.

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
#import "MHVAssessment.h"

static NSString* const c_typeid = @"58fd8ac4-6c47-41a3-94b2-478401f0e26c";
static NSString* const c_typename = @"health-assessment";

static NSString* const c_element_when = @"when";
static NSString* const c_element_name = @"name";
static NSString* const c_element_category = @"category";
static NSString* const c_element_result = @"result";

@implementation MHVAssessment

@synthesize when = m_when;
@synthesize name = m_name;
@synthesize category = m_category;

-(MHVAssessmentFieldCollection *)results
{
    HVENSURE(m_results, MHVAssessmentFieldCollection);
    return m_results;
}

-(void)setResults:(MHVAssessmentFieldCollection *)results
{
    m_results = results;
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return m_name ? m_name : c_emptyString;
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidAssessment);
    HVVALIDATE_STRING(m_name, HVClientError_InvalidAssessment);
    HVVALIDATE(m_category, HVClientError_InvalidAssessment);
    HVVALIDATE_ARRAY(m_results, HVClientError_InvalidAssessment);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_name value:m_name];
    [writer writeElement:c_element_category content:m_category];
    [writer writeElementArray:c_element_result elements:m_results];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVDateTime class]];
    m_name = [reader readStringElement:c_element_name];
    m_category = [reader readElement:c_element_category asClass:[MHVCodableValue class]];
    m_results = (MHVAssessmentFieldCollection *)[reader readElementArray:c_element_result asClass:[MHVAssessmentField class] andArrayClass:[MHVAssessmentFieldCollection class]];
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
    return [[MHVItem alloc] initWithType:[MHVAssessment typeID]];
}

@end
