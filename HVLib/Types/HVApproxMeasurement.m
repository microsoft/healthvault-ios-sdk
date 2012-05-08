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

-(BOOL)hasMeasurement
{
    return (m_measurement != nil);
}

-(id)initWithDisplayText:(NSString *)text
{
    return [self initWithDisplayText:text andMeasurement:nil];
}

-(id)initWithDisplayText:(NSString *)text andMeasurement:(HVMeasurement *)measurement
{
    HVCHECK_STRING(text);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.displayText = text;
    
    if (measurement)
    {
        self.measurement = measurement;
    }
    
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

+(HVApproxMeasurement *)fromDisplayText:(NSString *)text
{
    return [[[HVApproxMeasurement alloc] initWithDisplayText:text] autorelease];
}

+(HVApproxMeasurement *)fromDisplayText:(NSString *)text andMeasurement:(HVMeasurement *)measurement
{
    return [[[HVApproxMeasurement alloc] initWithDisplayText:text andMeasurement:measurement] autorelease];
}

+(HVApproxMeasurement *) fromValue:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)code unitsVocab:(NSString *) vocab
{
    HVMeasurement* measurement = [HVMeasurement fromValue:value unitsDisplayText:unitsText unitsCode:code unitsVocab:vocab];
    HVCHECK_NOTNULL(measurement);
    
    NSString* displayFormat;
    if (floor(value) == value)
    {
        displayFormat = @"%.0f %@";
    }
    else 
    {
        displayFormat = @"%.3f %@";
    }
    NSString* displayText = [NSString stringWithFormat:displayFormat, value, unitsText];
    HVCHECK_NOTNULL(displayText);
    
    HVApproxMeasurement* approxMeasurement = [HVApproxMeasurement fromDisplayText:displayText andMeasurement:measurement];
    return approxMeasurement;
    
LError:
    return nil;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    if (m_display)
    {
        return m_display;
    }
    
    if (m_measurement)
    {
        return [m_measurement toString];
    }
    
    return c_emptyString;    
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (m_measurement)
    {
        return [m_measurement toStringWithFormat:format];
    }
    
    return (m_display) ? m_display : c_emptyString;
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
