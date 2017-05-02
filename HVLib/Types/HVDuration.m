//
//  HVDuration.m
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
#import "HVDuration.h"

static NSString* const c_element_start = @"start-date";
static NSString* const c_element_end = @"end-date";

@implementation HVDuration

@synthesize startDate = m_startDate;
@synthesize endDate = m_endDate;

-(id)initWithStartDate:(NSDate *)start endDate:(NSDate *)end
{
    HVCHECK_NOTNULL(start);
    HVCHECK_NOTNULL(end);
        
    m_startDate = [[HVApproxDateTime alloc] initWithDate:start];
    HVCHECK_NOTNULL(m_startDate);
    
    m_endDate = [[HVApproxDateTime alloc] initWithDate:end];
    HVCHECK_NOTNULL(m_endDate);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithDate:(NSDate *)start andDurationInSeconds:(double)duration
{
    return [self initWithStartDate:start endDate:[start dateByAddingTimeInterval:duration]];
}

-(void)dealloc
{
    [m_startDate release];
    [m_endDate release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_startDate, HVClientError_InvalidDuration);
    HVVALIDATE(m_endDate, HVClientError_InvalidDuration);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_start content:m_startDate];
    [writer writeElement:c_element_end content:m_endDate];
}

-(void)deserialize:(XReader *)reader
{
    m_startDate = [[reader readElement:c_element_start asClass:[HVApproxDateTime class]] retain];    
    m_endDate = [[reader readElement:c_element_end asClass:[HVApproxDateTime class]] retain];    
}

@end
