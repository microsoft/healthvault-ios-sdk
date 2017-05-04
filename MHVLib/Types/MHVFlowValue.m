//
//  MHVFlowValue.m
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
#import "MHVFlowValue.h"

static const xmlChar* x_element_litersPerSecond = XMLSTRINGCONST("liters-per-second");
static const xmlChar* x_element_displayValue = XMLSTRINGCONST("display");

@implementation MHVFlowValue

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
        m_litersPerSecond = nil;
    }
    else
    {
        MHVENSURE(m_litersPerSecond, MHVPositiveDouble);
        m_litersPerSecond.value = litersPerSecondValue;
    }
    
    [self updateDisplayText];
}

-(id)initWithLitersPerSecond:(double)value
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.litersPerSecondValue = value;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL) updateDisplayText
{
    m_display = nil;
    if (!m_litersPerSecond)
    {
        return FALSE;
    }
    
    m_display = [[MHVDisplayValue alloc] initWithValue:m_litersPerSecond.value andUnits:[MHVFlowValue flowUnits]];
    
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

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_litersPerSecond, MHVClientError_InvalidFlow);
    MHVVALIDATE_OPTIONAL(m_display);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_litersPerSecond content:m_litersPerSecond];
    [writer writeElementXmlName:x_element_displayValue content:m_display];
}

-(void)deserialize:(XReader *)reader
{
    m_litersPerSecond = [reader readElementWithXmlName:x_element_litersPerSecond asClass:[MHVPositiveDouble class]];
    m_display = [reader readElementWithXmlName:x_element_displayValue asClass:[MHVDisplayValue class]];
}

+(NSString *)flowUnits
{
    return NSLocalizedString(@"L/s", @"Liters per second");
}

@end
