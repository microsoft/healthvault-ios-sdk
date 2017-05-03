//
//  HVFoodEnergyValue.m
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
#import "HVFoodEnergyValue.h"

static const xmlChar* x_element_calories = XMLSTRINGCONST("calories");
static const xmlChar* x_element_displayValue = XMLSTRINGCONST("display");

@implementation HVFoodEnergyValue

@synthesize calories = m_calories;
@synthesize displayValue = m_display;

-(double)caloriesValue
{
    return (m_calories) ? m_calories.value : NAN;
}

-(void)setCaloriesValue:(double)caloriesValue
{
    if (isnan(caloriesValue))
    {
        m_calories = nil;
    }
    else 
    {
        HVENSURE(m_calories, HVNonNegativeDouble);
        m_calories.value = caloriesValue;
    }
    
    [self updateDisplayText];
}

-(id)initWithCalories:(double)value
{
    self = [super init];
    HVCHECK_SELF;
    
    self.caloriesValue = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(BOOL) updateDisplayText
{
    m_display = nil;
    if (!m_calories)
    {
        return FALSE;
    }
    
    m_display = [[HVDisplayValue alloc] initWithValue:m_calories.value andUnits:[HVFoodEnergyValue calorieUnits]];
    
    return (m_display != nil);
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"%.0f cal"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    if (!m_calories)
    {
        return c_emptyString;
    }
    
    return [NSString localizedStringWithFormat:format, self.caloriesValue];
}

+(NSString *)calorieUnits
{
    return NSLocalizedString(@"cal", @"Calorie units");
}

-(NSString *)description
{
    return [self toString];
}


-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_calories, HVClientError_InvalidDietaryIntake);
    HVVALIDATE_OPTIONAL(m_display);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_calories content:m_calories];
    [writer writeElementXmlName:x_element_displayValue content:m_display];
}

-(void)deserialize:(XReader *)reader
{
    m_calories = [reader readElementWithXmlName:x_element_calories asClass:[HVNonNegativeDouble class]];
    m_display = [reader readElementWithXmlName:x_element_displayValue asClass:[HVDisplayValue class]];
}

+(HVFoodEnergyValue *)fromCalories:(double)value
{
    return [[HVFoodEnergyValue alloc] initWithCalories:value];
}

@end
