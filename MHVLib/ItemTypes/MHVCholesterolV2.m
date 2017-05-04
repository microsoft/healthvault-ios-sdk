//
//  MHVCholesterolV2.m
//  MHVLib
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
#import "MHVCholesterolV2.h"

static NSString* const c_typeid = @"98f76958-e34f-459b-a760-83c1699add38";
static NSString* const c_typename = @"cholesterol-profile";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_ldl = XMLSTRINGCONST("ldl");
static const xmlChar* x_element_hdl = XMLSTRINGCONST("hdl");
static const xmlChar* x_element_total = XMLSTRINGCONST("total-cholesterol");
static const xmlChar* x_element_triglycerides = XMLSTRINGCONST("triglyceride");

@implementation MHVCholesterolV2

@synthesize when = m_when;
@synthesize ldl = m_ldl;
@synthesize hdl = m_hdl;
@synthesize triglycerides = m_triglycerides;
@synthesize total = m_total;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(double)ldlValue
{
    return (m_ldl) ? m_ldl.mmolPerLiter : NAN;
}

-(void)setLdlValue:(double)ldl
{
    MHVENSURE(m_ldl, MHVConcentrationValue);
    m_ldl.mmolPerLiter = ldl;
}

-(double) hdlValue
{
    return (m_hdl) ? m_hdl.mmolPerLiter : NAN;
}

-(void)setHdlValue:(double)hdl
{
    MHVENSURE(m_hdl, MHVConcentrationValue);
    m_hdl.mmolPerLiter = hdl;
}

-(double) triglyceridesValue
{
    return (m_triglycerides) ? m_triglycerides.mmolPerLiter : NAN;
}

-(void)setTriglyceridesValue:(double)triglycerides
{
    MHVENSURE(m_triglycerides, MHVConcentrationValue);
    m_triglycerides.mmolPerLiter = triglycerides;
}

-(double)totalValue
{
    return (m_total) ? m_total.mmolPerLiter : NAN;
}

-(void)setTotalValue:(double)totalValue
{
    MHVENSURE(m_total, MHVConcentrationValue);
    m_total.mmolPerLiter = totalValue;
}

-(double)ldlValueMgDL
{
    return (m_ldl) ? [m_ldl mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setLdlValueMgDL:(double)ldlValueMgDL
{
    MHVENSURE(m_ldl, MHVConcentrationValue);
    [m_ldl setMgPerDL:ldlValueMgDL gramsPerMole:c_cholesterolMolarMass];
}

-(double)hdlValueMgDL
{
    return (m_hdl) ? [m_hdl mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setHdlValueMgDL:(double)hdlValueMgDL
{
    MHVENSURE(m_hdl, MHVConcentrationValue);
    [m_hdl setMgPerDL:hdlValueMgDL gramsPerMole:c_cholesterolMolarMass];
}

-(double)triglyceridesValueMgDl
{
    return (m_triglycerides) ? [m_triglycerides mgPerDL:c_triglyceridesMolarMass] : NAN;
}

-(void)setTriglyceridesValueMgDl:(double)triglyceridesMgDl
{
    MHVENSURE(m_triglycerides, MHVConcentrationValue);
    [m_triglycerides setMgPerDL:triglyceridesMgDl gramsPerMole:c_triglyceridesMolarMass];
}

-(double)totalValueMgDL
{
    return (m_total) ? [m_total mgPerDL:c_cholesterolMolarMass] : NAN;
}

-(void)setTotalValueMgDL:(double)totalValueMgDL
{
    MHVENSURE(m_total, MHVConcentrationValue);
    [m_total setMgPerDL:totalValueMgDL gramsPerMole:c_cholesterolMolarMass];
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_when, MHVClientError_InvalidCholesterol);
    MHVVALIDATE_OPTIONAL(m_ldl);
    MHVVALIDATE_OPTIONAL(m_hdl);
    MHVVALIDATE_OPTIONAL(m_total);
    MHVVALIDATE_OPTIONAL(m_triglycerides);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_ldl content:m_ldl];
    [writer writeElementXmlName:x_element_hdl content:m_hdl];
    [writer writeElementXmlName:x_element_total content:m_total];
    [writer writeElementXmlName:x_element_triglycerides content:m_triglycerides];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDateTime class]];
    m_ldl = [reader readElementWithXmlName:x_element_ldl asClass:[MHVConcentrationValue class]];
    m_hdl = [reader readElementWithXmlName:x_element_hdl asClass:[MHVConcentrationValue class]];
    m_total = [reader readElementWithXmlName:x_element_total asClass:[MHVConcentrationValue class]];
    m_triglycerides = [reader readElementWithXmlName:x_element_triglycerides asClass:[MHVConcentrationValue class]];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVCholesterolV2 typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Cholesterol", @"Cholesterol Type Name");
}

@end
