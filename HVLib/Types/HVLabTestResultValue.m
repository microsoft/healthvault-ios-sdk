//
//  HVLabTestResultValue.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
//
#import "HVCommon.h"
#import "HVLabTestResultValue.h"

static const xmlChar* x_element_measurement = XMLSTRINGCONST("measurement");
static NSString* const c_element_ranges = @"ranges";
static const xmlChar* x_element_ranges = XMLSTRINGCONST("ranges");
static const xmlChar* x_element_flag = XMLSTRINGCONST("flag");

@implementation HVLabTestResultValue

@synthesize measurement = m_measurement;
@synthesize ranges = m_ranges;
@synthesize flag = m_flag;
-(BOOL)hasRanges
{
    return ![NSArray isNilOrEmpty:m_ranges];
}

-(void)dealloc
{
    [m_measurement release];
    [m_ranges release];
    [m_flag release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_measurement, HVClientError_InvalidLabTestResultValue);
    HVVALIDATE_ARRAYOPTIONAL(m_ranges, HVClientError_InvalidLabTestResultValue);
    HVVALIDATE_OPTIONAL(m_flag);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_measurement content:m_measurement];
    [writer writeElementArray:c_element_ranges elements:m_ranges];
    [writer writeElementXmlName:x_element_flag content:m_flag];
}

-(void)deserialize:(XReader *)reader
{
    m_measurement = [[reader readElementWithXmlName:x_element_measurement asClass:[HVApproxMeasurement class]] retain];
    m_ranges = (HVTestResultRangeCollection *)[[reader readElementArrayWithXmlName:x_element_ranges asClass:[HVTestResultRange class] andArrayClass:[HVTestResultRangeCollection class]] retain];
    m_flag = [[reader readElementWithXmlName:x_element_flag asClass:[HVCodableValue class]] retain];
}

@end
