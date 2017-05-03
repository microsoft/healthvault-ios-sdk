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

static const xmlChar* x_element_value = XMLSTRINGCONST("value");
static const xmlChar* x_element_units = XMLSTRINGCONST("units");

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

+(HVMeasurement *)fromValue:(double)value andUnits:(HVCodableValue *)units
{
    return [[[HVMeasurement alloc] initWithValue:value andUnits:units] autorelease];
}

+(HVMeasurement *)fromValue:(double)value andUnitsString:(NSString *)units
{
    return [[[HVMeasurement alloc] initWithValue:value andUnitsString:units] autorelease];
}

+(HVMeasurement *)fromValue:(double)value unitsDisplayText:(NSString *)unitsText unitsCode:(NSString *)code unitsVocab:(NSString *)vocab
{
    HVCodableValue* unitCode = [[HVCodableValue alloc] initWithText:unitsText code:code andVocab:vocab];
    HVCHECK_NOTNULL(unitCode);
    
    HVMeasurement* measurement = [[HVMeasurement alloc] initWithValue:value andUnits:unitCode];
    [unitCode release];
    
    return measurement;
    
LError:
    HVALLOC_FAIL;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    if (!m_units)
    {
        return [NSString localizedStringWithFormat:@"%g", m_value]; 
    }
    
    return [self toStringWithFormat:@"%g %@"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, m_value, m_units.text];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_units, HVClientError_InvalidMeasurement);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_value doubleValue:m_value];
    [writer writeElementXmlName:x_element_units content:m_units];
}

-(void)deserialize:(XReader *)reader
{
    m_value = [reader readDoubleElementXmlName:x_element_value];
    m_units = [[reader readElementWithXmlName:x_element_units asClass:[HVCodableValue class]] retain];
}

@end
