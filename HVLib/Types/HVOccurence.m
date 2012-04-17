//
//  HVOccurence.m
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
#import "HVOccurence.h"

static NSString* const c_element_when = @"when";
static NSString* const c_element_minutes = @"minutes";

@implementation HVOccurence

@synthesize when = m_when;
@synthesize minutes = m_minutes;

-(id)initWithMinutes:(int)minutes forTime:(NSDate *)time
{
    HVCHECK_NOTNULL(time);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVTime alloc] initWithDate:time];
    HVCHECK_NOTNULL(m_when);
    
    m_minutes = [[HVNonNegativeInt alloc] initWith:minutes];
    HVCHECK_NOTNULL(m_minutes);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_when release];
    [m_minutes release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidOccurrence);
    HVVALIDATE(m_minutes, HVClientError_InvalidOccurrence);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_minutes, c_element_minutes);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVTime);
    HVDESERIALIZE(m_minutes, c_element_minutes, HVNonNegativeInt);    
}

@end

@implementation HVOccurenceCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVOccurence class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end