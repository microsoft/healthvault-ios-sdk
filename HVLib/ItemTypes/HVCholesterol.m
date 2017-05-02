//
//  HVCholesterol.m
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
// See the License for the specifi

#import "HVCommon.h"
#import "HVCholesterol.h"

static NSString* const c_typeid = @"796c186f-b874-471c-8468-3eeff73bf66e";
static NSString* const c_typename = @"cholesterol-profile";

static NSString* const c_element_when = @"when";
static NSString* const c_element_ldl = @"ldl";
static NSString* const c_element_hdl = @"hdl";
static NSString* const c_element_total = @"total-cholesterol";
static NSString* const c_element_triglycerides = @"triglyceride";

double const c_cholesterolMolarMass = 386.6;  // g/mol
double const c_triglyceridesMolarMass = 885.7; // g/mol

@interface HVCholesterol (HVPrivate)

-(double) cholesterolInMmolPerLiter:(HVPositiveInt *) value;
-(int) cholesterolMgDLFromMmolPerLiter:(double) value;

@end

@implementation HVCholesterol

@synthesize when = m_date;
@synthesize ldl = m_ldl;
@synthesize hdl = m_hdl;
@synthesize total = m_total;
@synthesize triglycerides = m_triglycerides;

-(NSDate *)getDate
{
    return [m_date toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_date toDateForCalendar:calendar];
}

-(int)ldlValue
{
    return (m_ldl) ? m_ldl.value : -1;
}

-(void)setLdlValue:(int)ldl
{
    HVENSURE(m_ldl, HVPositiveInt);
    m_ldl.value = ldl;
}

-(int) hdlValue
{
    return (m_hdl) ? m_hdl.value : -1;
}

-(void)setHdlValue:(int)hdl
{
    HVENSURE(m_hdl, HVPositiveInt);
    m_hdl.value = hdl;        
}

-(int) triglyceridesValue
{
    return (m_triglycerides) ? m_triglycerides.value : -1;
}

-(void)setTriglyceridesValue:(int)triglycerides
{
    HVENSURE(m_triglycerides, HVPositiveInt);
    m_triglycerides.value = triglycerides;       
}

-(int)totalValue
{
    return (m_total) ? m_total.value : -1;
}

-(void)setTotalValue:(int)total
{
    HVENSURE(m_total, HVPositiveInt);
    m_total.value = total;
}

-(double)ldlValueMmolPerLiter
{
    return [self cholesterolInMmolPerLiter:m_ldl];
}

-(void)setLdlValueMmolPerLiter:(double)ldlValueMmolPerLiter
{
    self.ldlValue = [self cholesterolMgDLFromMmolPerLiter:ldlValueMmolPerLiter];
}

-(double)hdlValueMmolPerLiter
{
    return [self cholesterolInMmolPerLiter:m_hdl];
}

-(void)setHdlValueMmolPerLiter:(double)hdlValueMmolPerLiter
{
    self.hdlValue = [self cholesterolMgDLFromMmolPerLiter:hdlValueMmolPerLiter];
}

-(double)totalValueMmolPerLiter
{
    return [self cholesterolInMmolPerLiter:m_total];
}

-(void)setTotalValueMmolPerLiter:(double)totalValueMmolPerLiter
{
    self.totalValue = [self cholesterolMgDLFromMmolPerLiter:totalValueMmolPerLiter];
}

-(double)triglyceridesValueMmolPerLiter
{
    return (m_triglycerides) ? (mgDLToMmolPerL(m_triglycerides.value, c_triglyceridesMolarMass)) : NAN;
}

-(void)setTriglyceridesValueMmolPerLiter:(double)triglyceridesValueMmolPerLiter
{
    self.triglyceridesValue = mmolPerLToMgDL(triglyceridesValueMmolPerLiter, c_triglyceridesMolarMass);
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%d/%d"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.ldlValue, self.hdlValue];
}

-(void)dealloc
{
    [m_date release];
    [m_ldl release];
    [m_hdl release];
    [m_total release];
    [m_triglycerides release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_date, HVClientError_InvalidCholesterol);
    HVVALIDATE_OPTIONAL(m_ldl);
    HVVALIDATE_OPTIONAL(m_hdl);
    HVVALIDATE_OPTIONAL(m_total);
    HVVALIDATE_OPTIONAL(m_triglycerides);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_date];
    [writer writeElement:c_element_ldl content:m_ldl];
    [writer writeElement:c_element_hdl content:m_hdl];
    [writer writeElement:c_element_total content:m_total];
    [writer writeElement:c_element_triglycerides content:m_triglycerides];
}

-(void)deserialize:(XReader *)reader
{
    m_date = [[reader readElement:c_element_when asClass:[HVDate class]] retain];
    m_ldl = [[reader readElement:c_element_ldl asClass:[HVPositiveInt class]] retain];
    m_hdl = [[reader readElement:c_element_hdl asClass:[HVPositiveInt class]] retain];
    m_total = [[reader readElement:c_element_total asClass:[HVPositiveInt class]] retain];
    m_triglycerides = [[reader readElement:c_element_triglycerides asClass:[HVPositiveInt class]] retain];    
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
    return [[HVItem alloc] initWithType:[HVCholesterol typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Cholesterol", @"Cholesterol Type Name");
}

@end

@implementation HVCholesterol (HVPrivate)

-(double)cholesterolInMmolPerLiter:(HVPositiveInt *)value
{
    if (!value)
    {
        return NAN;
    }
    
    return mgDLToMmolPerL(value.value, c_cholesterolMolarMass);
}

-(int)cholesterolMgDLFromMmolPerLiter:(double)value
{
    return round(mmolPerLToMgDL(value, c_cholesterolMolarMass));
}

@end
