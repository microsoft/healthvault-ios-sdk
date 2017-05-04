//
//  MHVDuration.m
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
#import "MHVDuration.h"

static NSString* const c_element_start = @"start-date";
static NSString* const c_element_end = @"end-date";

@implementation MHVDuration

@synthesize startDate = m_startDate;
@synthesize endDate = m_endDate;

-(id)initWithStartDate:(NSDate *)start endDate:(NSDate *)end
{
    MHVCHECK_NOTNULL(start);
    MHVCHECK_NOTNULL(end);
    
    self = [super init];
        
    m_startDate = [[MHVApproxDateTime alloc] initWithDate:start];
    MHVCHECK_NOTNULL(m_startDate);
    
    m_endDate = [[MHVApproxDateTime alloc] initWithDate:end];
    MHVCHECK_NOTNULL(m_endDate);
    
    return self;
}

-(id)initWithDate:(NSDate *)start andDurationInSeconds:(double)duration
{
    return [self initWithStartDate:start endDate:[start dateByAddingTimeInterval:duration]];
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_startDate, MHVClientError_InvalidDuration);
    MHVVALIDATE(m_endDate, MHVClientError_InvalidDuration);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_start content:m_startDate];
    [writer writeElement:c_element_end content:m_endDate];
}

-(void)deserialize:(XReader *)reader
{
    m_startDate = [reader readElement:c_element_start asClass:[MHVApproxDateTime class]];    
    m_endDate = [reader readElement:c_element_end asClass:[MHVApproxDateTime class]];    
}

@end
