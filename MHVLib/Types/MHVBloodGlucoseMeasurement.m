//
//  MHVBloodGlucoseMeasurement.m
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
#import "MHVBloodGlucoseMeasurement.h"
#import "MHVMeasurement.h"

@implementation MHVBloodGlucoseMeasurement

@synthesize value = m_mmolPerl;
@synthesize display = m_display;

-(double)mmolPerLiter
{
    return (m_mmolPerl) ? m_mmolPerl.value : NAN;
}

-(void)setMmolPerLiter:(double)mmolPerLiter
{
    MHVENSURE(m_mmolPerl, MHVPositiveDouble);
    m_mmolPerl.value = mmolPerLiter;
    [self updateDisplayValue:mmolPerLiter units:c_mmolPlUnits andUnitsCode:c_mmolUnitsCode];
}

-(double)mgPerDL
{
    if (m_mmolPerl)
    {
        return [MHVBloodGlucoseMeasurement mMolPerLiterToMgPerDL:m_mmolPerl.value];
    }
    
    return NAN;
}

-(void)setMgPerDL:(double)mgPerDL
{
    MHVENSURE(m_mmolPerl, MHVPositiveDouble);
    m_mmolPerl.value = [MHVBloodGlucoseMeasurement mgPerDLToMmolPerLiter:mgPerDL];
    [self updateDisplayValue:mgPerDL units:c_mgDLUnits andUnitsCode:c_mgDLUnitsCode];
}


-(id)initWithMmolPerLiter:(double)value
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.mmolPerLiter = value;
    MHVCHECK_NOTNULL(m_mmolPerl);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithMgPerDL:(double)value
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.mgPerDL = value;
    MHVCHECK_NOTNULL(m_mmolPerl);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(BOOL) updateDisplayValue:(double)displayValue units:(NSString *)unitValue andUnitsCode:(NSString *)code
{
    MHVDisplayValue *newValue = [[MHVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    MHVCHECK_NOTNULL(newValue);
    
    if (code)
    {
        newValue.unitsCode = code;
    }
    
    m_display = newValue;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.3f mmol/l"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.mmolPerLiter];
}

+(double)mMolPerLiterToMgPerDL:(double)value
{
    return value * 18;
}

+(double)mgPerDLToMmolPerLiter:(double)value
{
    return value / 18;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_mmolPerl, MHVClientError_InvalidBloodGlucoseMeasurement);
    MHVVALIDATE_OPTIONAL(m_display);
    
    MHVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_mmolPL content:m_mmolPerl];
    [writer writeElementXmlName:x_element_display content:m_display];
}

-(void)deserialize:(XReader *)reader
{    
    m_mmolPerl = [reader readElementWithXmlName:x_element_mmolPL asClass:[MHVPositiveDouble class]];
    m_display = [reader readElementWithXmlName:x_element_display asClass:[MHVDisplayValue class]];
}

@end