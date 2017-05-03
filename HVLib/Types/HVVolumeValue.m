//
//  HVVolumeValue.m
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

#import "HVCommon.h"
#import "HVVolumeValue.h"

static const xmlChar* x_element_liters = XMLSTRINGCONST("liters");
static const xmlChar* x_element_displayValue = XMLSTRINGCONST("display");

@implementation HVVolumeValue

@synthesize liters = m_liters;
@synthesize displayValue = m_display;

-(double)litersValue
{
    return m_liters ? m_liters.value : NAN;
}

-(void)setLitersValue:(double)litersValue
{
    if (isnan(litersValue))
    {
        m_liters = nil;
    }
    else
    {
        HVENSURE(m_liters, HVPositiveDouble);
        m_liters.value = litersValue;
    }
    
    [self updateDisplayText];
}

-(id)initWithLiters:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.litersValue = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(BOOL) updateDisplayText
{
    m_display = nil;
    if (!m_liters)
    {
        return FALSE;
    }
    
    m_display = [[HVDisplayValue alloc] initWithValue:m_liters.value andUnits:[HVVolumeValue volumeUnits]];
    
    return (m_display != nil);
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.1f L"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (!m_liters)
    {
        return c_emptyString;
    }
    
    return [NSString localizedStringWithFormat:format, self.litersValue];
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_liters, HVClientError_InvalidVolume);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_liters content:m_liters];
    [writer writeElementXmlName:x_element_displayValue content:m_display];
}

-(void)deserialize:(XReader *)reader
{
    m_liters = [reader readElementWithXmlName:x_element_liters asClass:[HVPositiveDouble class]];
    m_display = [reader readElementWithXmlName:x_element_displayValue asClass:[HVDisplayValue class]];
}

+(NSString *)volumeUnits
{
    return NSLocalizedString(@"L", @"Liters");
}

@end
