//
//  HVApproxMeasurement.m
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
#import "HVApproxMeasurement.h"

static NSString* const c_element_display = @"display";
static NSString* const c_element_structured = @"structured";

@implementation HVApproxMeasurement

@synthesize displayText = m_display;
@synthesize measurement = m_measurement;

-(id)initWithDisplayText:(NSString *)text
{
    HVCHECK_STRING(text);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.displayText = text;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_display release];
    [m_measurement release];
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    if (m_measurement)
    {
        return [m_measurement toString];
    }
    
    return m_display;    
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (m_measurement)
    {
        return [m_measurement toStringWithFormat:format];
    }
    
    return m_display;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE_STRING(m_display, HVClientError_InvalidApproxMeasurement);
    HVVALIDATE_OPTIONAL(m_measurement);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_display, c_element_display);
    HVSERIALIZE(m_measurement, c_element_structured);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_display, c_element_display);
    HVDESERIALIZE(m_measurement, c_element_structured, HVMeasurement);
}

@end
