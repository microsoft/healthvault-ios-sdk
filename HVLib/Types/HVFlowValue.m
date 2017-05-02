//
//  HVFlowValue.m
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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
#import "HVFlowValue.h"

static const xmlChar* x_element_litersPerSecond = XMLSTRINGCONST("liters-per-second");
static const xmlChar* x_element_displayValue = XMLSTRINGCONST("display");

@implementation HVFlowValue

@synthesize litersPerSecond = m_litersPerSecond;
@synthesize displayValue = m_display;

-(double)litersPerSecondValue
{
    return m_litersPerSecond ? m_litersPerSecond.value : NAN;
}

-(void)setLitersPerSecondValue:(double)litersPerSecondValue
{
    if (isnan(litersPerSecondValue))
    {
        HVCLEAR(m_litersPerSecond);
    }
    else
    {
        HVENSURE(m_litersPerSecond, HVPositiveDouble);
        m_litersPerSecond.value = litersPerSecondValue;
    }
    
    [self updateDisplayText];
}

-(id)initWithLitersPerSecond:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.litersPerSecondValue = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_litersPerSecond release];
    [m_display release];
    [super dealloc];
}

-(BOOL) updateDisplayText
{
    HVCLEAR(m_display);
    if (!m_litersPerSecond)
    {
        return FALSE;
    }
    
    m_display = [[HVDisplayValue alloc] initWithValue:m_litersPerSecond.value andUnits:[HVFlowValue flowUnits]];
    
    return (m_display != nil);
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.1f L/s"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (!m_litersPerSecond)
    {
        return c_emptyString;
    }
    
    return [NSString localizedStringWithFormat:format, self.litersPerSecondValue];
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_litersPerSecond, HVClientError_InvalidFlow);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_litersPerSecond content:m_litersPerSecond];
    [writer writeElementXmlName:x_element_displayValue content:m_display];
}

-(void)deserialize:(XReader *)reader
{
    m_litersPerSecond = [[reader readElementWithXmlName:x_element_litersPerSecond asClass:[HVPositiveDouble class]] retain];
    m_display = [[reader readElementWithXmlName:x_element_displayValue asClass:[HVDisplayValue class]] retain];
}

+(NSString *)flowUnits
{
    return NSLocalizedString(@"L/s", @"Liters per second");
}

@end
