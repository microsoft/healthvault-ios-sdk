//
//  HVBloodGlucoseMeasurement.m
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
#import "HVBloodGlucoseMeasurement.h"
#import "HVMeasurement.h"

static NSString* const c_element_mmolPL = @"mmolPerL";
static NSString* const c_element_display = @"display";

static NSString* const c_mmolPlUnits = @"mmol/L";
static NSString* const c_mmolUnitsCode = @"mmol-per-l";
static NSString* const c_mgDLUnits = @"mg/dL";
static NSString* const c_mgDLUnitsCode = @"mg-per-dl";

@implementation HVBloodGlucoseMeasurement

@synthesize value = m_mmolPerl;
@synthesize display = m_display;

-(double)mmolPerLiter
{
    return (m_mmolPerl) ? m_mmolPerl.value : NAN;
}

-(void)setMmolPerLiter:(double)mmolPerLiter
{
    HVENSURE(m_mmolPerl, HVPositiveDouble);
    m_mmolPerl.value = mmolPerLiter;
    [self updateDisplayValue:mmolPerLiter units:c_mmolPlUnits andUnitsCode:c_mmolUnitsCode];
}

-(double)mgPerDL
{
    if (m_mmolPerl)
    {
        return [HVBloodGlucoseMeasurement mMolPerLiterToMgPerDL:m_mmolPerl.value];
    }
    
    return NAN;
}

-(void)setMgPerDL:(double)mgPerDL
{
    HVENSURE(m_mmolPerl, HVPositiveDouble);
    m_mmolPerl.value = [HVBloodGlucoseMeasurement mgPerDLToMmolPerLiter:mgPerDL];
    [self updateDisplayValue:mgPerDL units:c_mgDLUnits andUnitsCode:c_mgDLUnitsCode];
}

-(void)dealloc
{
    [m_mmolPerl release];
    [m_display release];
    [super dealloc];
}

-(id)initWithMmolPerLiter:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.mmolPerLiter = value;
    HVCHECK_NOTNULL(m_mmolPerl);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithMgPerDL:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.mgPerDL = value;
    HVCHECK_NOTNULL(m_mmolPerl);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(BOOL) updateDisplayValue:(double)displayValue units:(NSString *)unitValue andUnitsCode:(NSString *)code
{
    HVDisplayValue *newValue = [[HVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    HVCHECK_NOTNULL(newValue);
    
    if (code)
    {
        newValue.unitsCode = code;
    }
    
    HVASSIGN(m_display, newValue);
    
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

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_mmolPerl, HVClientError_InvalidBloodGlucoseMeasurement);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;  
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_mmolPerl, c_element_mmolPL);
    HVSERIALIZE(m_display, c_element_display);
}

-(void)deserialize:(XReader *)reader
{    
    HVDESERIALIZE(m_mmolPerl, c_element_mmolPL, HVPositiveDouble);
    HVDESERIALIZE(m_display, c_element_display, HVDisplayValue);
}

@end
