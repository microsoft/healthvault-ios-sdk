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

-(int)ldlValue
{
    return (m_ldl) ? m_ldl.value : -1;
}

-(void)setLdlValue:(int)ldl
{
    HVENSURE(m_ldl, HVInt);
    m_ldl.value = ldl;
}

-(int) hdlValue
{
    return (m_hdl) ? m_hdl.value : -1;
}

-(void)setHdlValue:(int)hdl
{
    HVENSURE(m_hdl, HVInt);
    m_hdl.value = hdl;        
}

-(int) triglyceridesValue
{
    return (m_triglycerides) ? m_triglycerides.value : -1;
}

-(void)setTriglyceridesValue:(int)triglycerides
{
    HVENSURE(m_triglycerides, HVInt);
    m_triglycerides.value = triglycerides;       
}

-(int)totalValue
{
    return (m_total) ? m_total.value : -1;
}

-(void)setTotalValue:(int)total
{
    HVENSURE(m_total, HVInt);
    m_total.value = total;
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
    return [NSString stringWithFormat:format, self.ldlValue, self.hdlValue];
}

-(void)dealloc
{
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
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_date, c_element_when);
    HVSERIALIZE(m_ldl, c_element_ldl);
    HVSERIALIZE(m_hdl, c_element_hdl);
    HVSERIALIZE(m_total, c_element_total);
    HVSERIALIZE(m_triglycerides, c_element_triglycerides);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_date, c_element_when, HVDate);
    HVDESERIALIZE(m_ldl, c_element_ldl, HVInt);
    HVDESERIALIZE(m_hdl, c_element_hdl, HVInt);
    HVDESERIALIZE(m_total, c_element_total, HVInt);
    HVDESERIALIZE(m_triglycerides, c_element_triglycerides, HVInt);    
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
