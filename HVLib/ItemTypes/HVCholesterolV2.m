//
//  HVCholesterolV2.m
//  HVLib
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
#import "HVCholesterolV2.h"

static NSString* const c_typeid = @"98f76958-e34f-459b-a760-83c1699add38";
static NSString* const c_typename = @"cholesterol-profile";

static NSString* const c_element_when = @"when";
static NSString* const c_element_ldl = @"ldl";
static NSString* const c_element_hdl = @"hdl";
static NSString* const c_element_total = @"total-cholesterol";
static NSString* const c_element_triglycerides = @"triglyceride";

@implementation HVCholesterolV2

@synthesize when = m_when;
@synthesize ldl = m_ldl;
@synthesize hdl = m_hdl;
@synthesize triglycerides = m_triglycerides;
@synthesize total = m_total;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(double)ldlValue
{
    return (m_ldl) ? m_ldl.mmolPerLiter : NAN;
}

-(void)setLdlValue:(double)ldl
{
    HVENSURE(m_ldl, HVConcentrationValue);
    m_ldl.mmolPerLiter = ldl;
}

-(double) hdlValue
{
    return (m_hdl) ? m_hdl.mmolPerLiter : NAN;
}

-(void)setHdlValue:(double)hdl
{
    HVENSURE(m_hdl, HVConcentrationValue);
    m_hdl.mmolPerLiter = hdl;
}

-(double) triglyceridesValue
{
    return (m_triglycerides) ? m_triglycerides.mmolPerLiter : NAN;
}

-(void)setTriglyceridesValue:(double)triglycerides
{
    HVENSURE(m_triglycerides, HVConcentrationValue);
    m_triglycerides.mmolPerLiter = triglycerides;
}

-(double)totalValue
{
    return (m_total) ? m_total.mmolPerLiter : NAN;
}

-(void)setTotalValue:(double)totalValue
{
    HVENSURE(m_total, HVConcentrationValue);
    m_total.mmolPerLiter = totalValue;
}

-(double)ldlValueMgDL
{
    return (m_ldl) ? [m_ldl mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setLdlValueMgDL:(double)ldlValueMgDL
{
    HVENSURE(m_ldl, HVConcentrationValue);
    [m_ldl setMgPerDL:ldlValueMgDL gramsPerMole:c_cholesterolMolarMass];
}

-(double)hdlValueMgDL
{
    return (m_hdl) ? [m_hdl mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setHdlValueMgDL:(double)hdlValueMgDL
{
    HVENSURE(m_hdl, HVConcentrationValue);
    [m_hdl setMgPerDL:hdlValueMgDL gramsPerMole:c_cholesterolMolarMass];
}

-(double)triglyceridesMgDl
{
    return (m_triglycerides) ? [m_triglycerides mgPerDL:c_triglyceridesMolarMass] : NAN;
}

-(void)setTriglyceridesMgDl:(double)triglyceridesMgDl
{
    HVENSURE(m_triglycerides, HVConcentrationValue);
    [m_triglycerides setMgPerDL:triglyceridesMgDl gramsPerMole:c_triglyceridesMolarMass];
}

-(double)totalValueMgDL
{
    return (m_total) ? [m_total mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setTotalValueMgDL:(double)totalValueMgDL
{
    HVENSURE(m_total, HVConcentrationValue);
    [m_total setMgPerDL:totalValueMgDL gramsPerMole:c_cholesterolMolarMass];
}

-(void)dealloc
{
    [m_when release];
    [m_ldl release];
    [m_hdl release];
    [m_triglycerides release];
    [m_total release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidCholesterol);
    HVVALIDATE_OPTIONAL(m_ldl);
    HVVALIDATE_OPTIONAL(m_hdl);
    HVVALIDATE_OPTIONAL(m_total);
    HVVALIDATE_OPTIONAL(m_triglycerides);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_ldl, c_element_ldl);
    HVSERIALIZE(m_hdl, c_element_hdl);
    HVSERIALIZE(m_total, c_element_total);
    HVSERIALIZE(m_triglycerides, c_element_triglycerides);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_ldl, c_element_ldl, HVConcentrationValue);
    HVDESERIALIZE(m_hdl, c_element_hdl, HVConcentrationValue);
    HVDESERIALIZE(m_total, c_element_total, HVConcentrationValue);
    HVDESERIALIZE(m_triglycerides, c_element_triglycerides, HVConcentrationValue);
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVCholesterolV2 typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Cholesterol", @"Cholesterol Type Name");
}

@end
