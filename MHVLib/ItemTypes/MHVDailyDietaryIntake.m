//
//  MHVDietaryIntake.m
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
#import "MHVDailyDietaryIntake.h"

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

@implementation MHVDailyDietaryIntake

@synthesize when = m_when;
@synthesize calories = m_calories;
@synthesize totalFat = m_totalFat;
@synthesize saturatedFat = m_saturatedFat;
@synthesize transFat = m_transFat;
@synthesize protein = m_protein;
@synthesize totalCarbs = m_carbs;
@synthesize sugar = m_sugar;
@synthesize dietaryFiber = m_fiber;
@synthesize sodium = m_sodium;
@synthesize cholesterol = m_cholesterol;

-(int)caloriesValue
{
    return (m_calories) ? m_calories.value : -1;
}

-(void)setCaloriesValue:(int)caloriesValue
{
    HVENSURE(m_calories, MHVPositiveInt);
    m_calories.value = caloriesValue;
}

-(double)totalFatGrams
{
    return (m_totalFat) ? m_totalFat.inGrams : NAN;
}

-(void)setTotalFatGrams:(double)totalFatGrams
{
    HVENSURE(m_totalFat, MHVWeightMeasurement);
    m_totalFat.inGrams = totalFatGrams;
}

-(double)saturatedFatGrams
{
    return (m_saturatedFat) ? m_saturatedFat.inGrams : NAN;
}

-(void)setSaturatedFatGrams:(double)saturatedFatGrams
{
    HVENSURE(m_saturatedFat, MHVWeightMeasurement);
    m_saturatedFat.inGrams = saturatedFatGrams;   
}

-(double)transFatGrams
{
    return (m_transFat) ? m_transFat.inGrams : NAN;
}

-(void)setTransFatGrams:(double)transFatGrams
{
    HVENSURE(m_transFat, MHVWeightMeasurement);
    m_transFat.inGrams = transFatGrams;   
}

-(double)proteinGrams
{
    return (m_protein) ? m_protein.inGrams : NAN;
}

-(void)setProteinGrams:(double)proteinGrams
{
    HVENSURE(m_protein, MHVWeightMeasurement);
    m_protein.inGrams = proteinGrams;       
}

-(double)totalCarbGrams
{
    return (m_carbs) ? m_carbs.inGrams : NAN;
}

-(void)setTotalCarbGrams:(double)totalCarbGrams
{
    HVENSURE(m_carbs, MHVWeightMeasurement);
    m_carbs.inGrams = totalCarbGrams;   
}

-(double)sugarGrams
{
    return (m_sugar) ? m_sugar.inGrams : NAN;
}

-(void)setSugarGrams:(double)sugarGrams
{
    HVENSURE(m_sugar, MHVWeightMeasurement);
    m_sugar.inGrams = sugarGrams;   
}

-(double)dietaryFiberGrams
{
    return (m_fiber) ? m_fiber.inGrams : NAN;
}

-(void)setDietaryFiberGrams:(double)dietaryFiberGrams
{
    HVENSURE(m_fiber, MHVWeightMeasurement);
    m_fiber.inGrams = dietaryFiberGrams;       
}

-(double)sodiumMillgrams
{
    return (m_sodium) ? m_sodium.inMilligrams : NAN;
}

-(void)setSodiumMillgrams:(double)sodiumMillgrams
{
    HVENSURE(m_sodium, MHVWeightMeasurement);
    m_sodium.inMilligrams = sodiumMillgrams;       
}

-(double)cholesterolMilligrams
{
    return (m_cholesterol) ? m_cholesterol.inMilligrams : NAN;
}

-(void)setCholesterolMilligrams:(double)cholesterolMilligrams
{
    HVENSURE(m_cholesterol, MHVWeightMeasurement);
    m_cholesterol.inMilligrams = cholesterolMilligrams;          
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(MHVClientResult *)validate
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
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_calories content:m_calories];
    [writer writeElement:c_element_totalFat content:m_totalFat];
    [writer writeElement:c_element_saturatedFat content:m_saturatedFat];
    [writer writeElement:c_element_transFat content:m_transFat];
    [writer writeElement:c_element_protein content:m_protein];
    [writer writeElement:c_element_carbs content:m_carbs];
    [writer writeElement:c_element_fiber content:m_fiber];
    [writer writeElement:c_element_sugar content:m_sugar];
    [writer writeElement:c_element_sodium content:m_sodium];
    [writer writeElement:c_element_cholesterol content:m_cholesterol];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVDate class]];
    m_calories = [reader readElement:c_element_calories asClass:[MHVPositiveInt class]];
    m_totalFat = [reader readElement:c_element_totalFat asClass:[MHVWeightMeasurement class]];
    m_saturatedFat = [reader readElement:c_element_saturatedFat asClass:[MHVWeightMeasurement class]];
    m_transFat = [reader readElement:c_element_transFat asClass:[MHVWeightMeasurement class]];
    m_protein = [reader readElement:c_element_protein asClass:[MHVWeightMeasurement class]];
    m_carbs = [reader readElement:c_element_carbs asClass:[MHVWeightMeasurement class]];
    m_fiber = [reader readElement:c_element_fiber asClass:[MHVWeightMeasurement class]];
    m_sugar = [reader readElement:c_element_sugar asClass:[MHVWeightMeasurement class]];
    m_sodium = [reader readElement:c_element_sodium asClass:[MHVWeightMeasurement class]];
    m_cholesterol = [reader readElement:c_element_cholesterol asClass:[MHVWeightMeasurement class]];    
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVDailyDietaryIntake typeID]];
}

@end
