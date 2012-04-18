//
//  HVMeasurement.m
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
#import "HVMeasurement.h"

double roundToPrecision(double value, int precision)
{
    double places = pow(10, precision);
    double boosted = round(value * places);
    return (boosted / places);
}

static NSString* const c_element_value = @"value";
static NSString* const c_element_units = @"units";

@implementation HVMeasurement

@synthesize value = m_value;
@synthesize units = m_units;

-(id)initWithValue:(double)value andUnits:(HVCodableValue *)units
{
    HVCHECK_NOTNULL(units);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_value = value;
    self.units = units;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithValue:(double)value andUnitsString:(NSString *)units
{
    HVCodableValue* unitsValue = [[HVCodableValue alloc] initWithText:units];
    HVCHECK_NOTNULL(unitsValue);
    
    self = [self initWithValue:value andUnits:unitsValue];
    [unitsValue release];
    
    HVCHECK_SELF;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_units release];
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.2f %@"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, m_value, m_units.text];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_units, HVClientError_InvalidMeasurement);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_DOUBLE(m_value, c_element_value);
    HVSERIALIZE(m_units, c_element_units);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_DOUBLE(m_value, c_element_value);
    HVDESERIALIZE(m_units, c_element_units, HVCodableValue);
}

@end
