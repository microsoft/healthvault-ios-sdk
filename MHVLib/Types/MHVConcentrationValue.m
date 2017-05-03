//
//  MHVConcentrationValue.m
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
#import "MHVConcentrationValue.h"

NSString* const c_element_mmolPL = @"mmolPerL";
NSString* const c_element_display = @"display";

const xmlChar* x_element_mmolPL = XMLSTRINGCONST("mmolPerL");
const xmlChar* x_element_display = XMLSTRINGCONST("display");

NSString* const c_mmolPlUnits = @"mmol/L";
NSString* const c_mmolUnitsCode = @"mmol-per-l";
NSString* const c_mgDLUnits = @"mg/dL";
NSString* const c_mgDLUnitsCode = @"mg-per-dl";

@implementation MHVConcentrationValue

@synthesize value = m_mmolPerl;
@synthesize display = m_display;

-(double)mmolPerLiter
{
    return m_mmolPerl ? m_mmolPerl.value : NAN;
}

-(void)setMmolPerLiter:(double)mmolPerLiter
{
    HVENSURE(m_mmolPerl, MHVNonNegativeDouble);
    m_mmolPerl.value = mmolPerLiter;
    [self updateDisplayValue:mmolPerLiter units:c_mmolPlUnits andUnitsCode:c_mmolUnitsCode];
}

-(id)initWithMmolPerLiter:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.mmolPerLiter = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithMgPerDL:(double)value gramsPerMole:(double)gramsPerMole
{
    self = [super init];
    HVCHECK_SELF;
    
    [self setMgPerDL:value gramsPerMole:gramsPerMole];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(double)mgPerDL:(double)gramsPerMole
{
    if (m_mmolPerl)
    {
        return mmolPerLToMgDL(m_mmolPerl.value, gramsPerMole);
    }
    
    return NAN;
}

-(void)setMgPerDL:(double)value gramsPerMole:(double)gramsPerMole
{
    double mmolPerl = mgDLToMmolPerL(value, gramsPerMole);
    
    HVENSURE(m_mmolPerl, MHVNonNegativeDouble);
    m_mmolPerl.value = mmolPerl;
    [self updateDisplayValue:value units:c_mgDLUnits andUnitsCode:c_mgDLUnitsCode];
}

-(BOOL) updateDisplayValue:(double)displayValue units:(NSString *)unitValue andUnitsCode:(NSString *)code
{
    MHVDisplayValue *newValue = [[MHVDisplayValue alloc] initWithValue:displayValue andUnits:unitValue];
    HVCHECK_NOTNULL(newValue);
    
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

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_mmolPerl, HVClientError_InvalidConcentrationValue);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_mmolPL content:m_mmolPerl];
    [writer writeElementXmlName:x_element_display content:m_display];
}

-(void)deserialize:(XReader *)reader
{
    m_mmolPerl = [reader readElementWithXmlName:x_element_mmolPL asClass:[MHVNonNegativeDouble class]];
    m_display = [reader readElementWithXmlName:x_element_display asClass:[MHVDisplayValue class]];
}

@end
