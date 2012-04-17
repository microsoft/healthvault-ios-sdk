//
//  HVDietaryIntake.m
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

#import "HVCommon.h"
#import "HVDietaryIntake.h"

static NSString* const c_typeid = @"9c29c6b9-f40e-44ff-b24e-fba6f3074638";
static NSString* const c_typename = @"dietary-intake-daily";

static NSString* const c_element_when = @"when";
static NSString* const c_element_calories = @"calories";
static NSString* const c_element_totalFat = @"total-fat";
static NSString* const c_element_saturatedFat = @"saturated-fat";
static NSString* const c_element_transFat = @"trans-fat";
static NSString* const c_element_protein = @"protein";
static NSString* const c_element_carbs = @"total-carbohydrates";
static NSString* const c_element_fiber = @"dietary-fiber";
static NSString* const c_element_sugar = @"sugars";
static NSString* const c_element_sodium = @"sodium";
static NSString* const c_element_cholesterol = @"cholesterol";

@implementation HVDietaryIntake

@synthesize when = m_when;
@synthesize calories = m_calories;
@synthesize totalFat = m_totalFat;
@synthesize saturatedFat = m_saturatedFat;
@synthesize transFat = m_transFat;
@synthesize protein = m_protein;
@synthesize carbs = m_carbs;
@synthesize fiber = m_fiber;
@synthesize sodium = m_sodium;
@synthesize cholesterol = m_cholesterol;

-(void)dealloc
{
    [m_when release];
    [m_calories release];
    [m_totalFat release];
    [m_saturatedFat release];
    [m_transFat release];
    [m_protein release];
    [m_carbs release];
    [m_fiber release];
    [m_sugar release];
    [m_sodium release];
    [m_cholesterol release];

    [super dealloc];
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidDietaryIntake);
    HVVALIDATE_OPTIONAL(m_calories);
    HVVALIDATE_OPTIONAL(m_totalFat);
    HVVALIDATE_OPTIONAL(m_saturatedFat);
    HVVALIDATE_OPTIONAL(m_transFat);
    HVVALIDATE_OPTIONAL(m_protein);
    HVVALIDATE_OPTIONAL(m_carbs);
    HVVALIDATE_OPTIONAL(m_fiber);
    HVVALIDATE_OPTIONAL(m_sugar);
    HVVALIDATE_OPTIONAL(m_sodium);
    HVVALIDATE_OPTIONAL(m_cholesterol);

    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_calories, c_element_calories);
    HVSERIALIZE(m_totalFat, c_element_totalFat);
    HVSERIALIZE(m_saturatedFat, c_element_saturatedFat);
    HVSERIALIZE(m_transFat, c_element_transFat);
    HVSERIALIZE(m_protein, c_element_protein);
    HVSERIALIZE(m_carbs, c_element_carbs);
    HVSERIALIZE(m_fiber, c_element_fiber);
    HVSERIALIZE(m_sugar, c_element_sugar);
    HVSERIALIZE(m_sodium, c_element_sodium);
    HVSERIALIZE(m_cholesterol, c_element_cholesterol);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDate);
    HVDESERIALIZE(m_calories, c_element_calories, HVPositiveInt);
    HVDESERIALIZE(m_totalFat, c_element_totalFat, HVWeightMeasurement);
    HVDESERIALIZE(m_saturatedFat, c_element_saturatedFat, HVWeightMeasurement);
    HVDESERIALIZE(m_transFat, c_element_transFat, HVWeightMeasurement);
    HVDESERIALIZE(m_protein, c_element_protein, HVWeightMeasurement);
    HVDESERIALIZE(m_carbs, c_element_carbs, HVWeightMeasurement);
    HVDESERIALIZE(m_fiber, c_element_fiber, HVWeightMeasurement);
    HVDESERIALIZE(m_sugar, c_element_sugar, HVWeightMeasurement);
    HVDESERIALIZE(m_sodium, c_element_sodium, HVWeightMeasurement);
    HVDESERIALIZE(m_cholesterol, c_element_cholesterol, HVWeightMeasurement);    
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
    return [[HVItem alloc] initWithType:[HVDietaryIntake typeID]];
}

@end
