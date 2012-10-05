//
//  HVFoodEnergyValue.m
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
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "HVCommon.h"
#import "HVFoodEnergyValue.h"

static NSString* const c_element_calories = @"calories";
static NSString* const c_element_displayValue = @"display";

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
        HVCLEAR(m_calories);
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

-(void)dealloc
{
    [m_calories release];
    [m_display release];
    
    [super dealloc];
}

-(BOOL) updateDisplayText
{
    HVCLEAR(m_display);
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
    
    return [NSString stringWithFormat:format, self.caloriesValue];
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
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_calories, c_element_calories);
    HVSERIALIZE(m_display, c_element_displayValue);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_calories, c_element_calories, HVNonNegativeDouble);
    HVDESERIALIZE(m_display, c_element_displayValue, HVDisplayValue);
}

+(HVFoodEnergyValue *)fromCalories:(double)value
{
    return [[[HVFoodEnergyValue alloc] initWithCalories:value] autorelease];
}

@end
