//
//  HVTestResultRangeValue.m
//  HVLib
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

#import "HVCommon.h"
#import "HVTestResultRangeValue.h"

static const xmlChar* x_element_minRange = XMLSTRINGCONST("minimum-range");
static const xmlChar* x_element_maxRange = XMLSTRINGCONST("maximum-range");

@implementation HVTestResultRangeValue

@synthesize minRange = m_minRange;
@synthesize maxRange = m_maxRange;

-(double)minRangeValue
{
    return m_minRange ? m_minRange.value : NAN;
}
-(void)setMinRangeValue:(double)minRangeValue
{
    if (isnan(minRangeValue))
    {
        m_minRange = nil;
    }
    else
    {
        HVENSURE(m_minRange, HVDouble);
        m_minRange.value = minRangeValue;
    }
}

-(double)maxRangeValue
{
    return m_maxRange ? m_maxRange.value : NAN;
}

-(void)setMaxRangeValue:(double)maxRangeValue
{
    if (isnan(maxRangeValue))
    {
        m_maxRange = nil;
    }
    else
    {
        HVENSURE(m_maxRange, HVDouble);
        m_maxRange.value = maxRangeValue;
    }
}


-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_minRange content:m_minRange];
    [writer writeElementXmlName:x_element_maxRange content:m_maxRange];
}

-(void)deserialize:(XReader *)reader
{
    m_minRange = [reader readElementWithXmlName:x_element_minRange asClass:[HVDouble class]];
    m_maxRange = [reader readElementWithXmlName:x_element_maxRange asClass:[HVDouble class]];
}

@end
