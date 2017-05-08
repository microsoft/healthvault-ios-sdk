//
//  MHVLabTestResultValue.m
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
//
//
#import "MHVCommon.h"
#import "MHVLabTestResultValue.h"

static const xmlChar* x_element_measurement = XMLSTRINGCONST("measurement");
static NSString* const c_element_ranges = @"ranges";
static const xmlChar* x_element_ranges = XMLSTRINGCONST("ranges");
static const xmlChar* x_element_flag = XMLSTRINGCONST("flag");

@implementation MHVLabTestResultValue

@synthesize measurement = m_measurement;
@synthesize ranges = m_ranges;
@synthesize flag = m_flag;
-(BOOL)hasRanges
{
    return ![MHVCollection isNilOrEmpty:m_ranges];
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_measurement, MHVClientError_InvalidLabTestResultValue);
    MHVVALIDATE_ARRAYOPTIONAL(m_ranges, MHVClientError_InvalidLabTestResultValue);
    MHVVALIDATE_OPTIONAL(m_flag);
    
    MHVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_measurement content:m_measurement];
    [writer writeElementArray:c_element_ranges elements:m_ranges.toArray];
    [writer writeElementXmlName:x_element_flag content:m_flag];
}

-(void)deserialize:(XReader *)reader
{
    m_measurement = [reader readElementWithXmlName:x_element_measurement asClass:[MHVApproxMeasurement class]];
    m_ranges = (MHVTestResultRangeCollection *)[reader readElementArrayWithXmlName:x_element_ranges asClass:[MHVTestResultRange class] andArrayClass:[MHVTestResultRangeCollection class]];
    m_flag = [reader readElementWithXmlName:x_element_flag asClass:[MHVCodableValue class]];
}

@end
