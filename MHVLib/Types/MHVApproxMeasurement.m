//
//  MHVApproxMeasurement.m
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
#import "MHVApproxMeasurement.h"

static NSString* const c_element_display = @"display";
static NSString* const c_element_structured = @"structured";

@implementation MHVApproxMeasurement

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

-(id)initWithDisplayText:(NSString *)text andMeasurement:(MHVMeasurement *)measurement
{
    MHVCHECK_STRING(text);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.displayText = text;
    
    if (measurement)
    {
        self.measurement = measurement;
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


+(MHVApproxMeasurement *)fromDisplayText:(NSString *)text
{
    return [[MHVApproxMeasurement alloc] initWithDisplayText:text];
}

+(MHVApproxMeasurement *)fromDisplayText:(NSString *)text andMeasurement:(MHVMeasurement *)measurement
{
    return [[MHVApproxMeasurement alloc] initWithDisplayText:text andMeasurement:measurement];
}

+(MHVApproxMeasurement *) fromValue:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)code unitsVocab:(NSString *) vocab
{
    MHVMeasurement* measurement = [MHVMeasurement fromValue:value unitsDisplayText:unitsText unitsCode:code unitsVocab:vocab];
    MHVCHECK_NOTNULL(measurement);
    
    NSString* displayText = [NSString localizedStringWithFormat:@"%g %@", value, unitsText];
    MHVCHECK_NOTNULL(displayText);
    
    MHVApproxMeasurement* approxMeasurement = [MHVApproxMeasurement fromDisplayText:displayText andMeasurement:measurement];
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

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_STRING(m_display, MHVClientError_InvalidApproxMeasurement);
    MHVVALIDATE_OPTIONAL(m_measurement);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_display value:m_display];
    [writer writeElement:c_element_structured content:m_measurement];
}

-(void)deserialize:(XReader *)reader
{
    m_display = [reader readStringElement:c_element_display];
    m_measurement = [reader readElement:c_element_structured asClass:[MHVMeasurement class]];
}

@end
