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
//
#import "HVCommon.h"
#import "HVDietaryIntake.h"

static NSString* const c_typeid = @"089646a6-7e25-4495-ad15-3e28d4c1a71d";
static NSString* const c_typename = @"dietary-intake";

static NSString* const c_element_foodItem = @"food-item";
static NSString* const c_element_servingSize = @"serving-size";
static NSString* const c_element_servingsConsumed = @"servings-consumed";
static NSString* const c_element_meal = @"meal";
static NSString* const c_element_when = @"when";

static NSString* const c_element_calories = @"energy";

static NSString* const c_element_energyFat = @"energy-from-fat";
static NSString* const c_element_totalFat = @"total-fat";
static NSString* const c_element_saturatedFat = @"saturated-fat";
static NSString* const c_element_transFat = @"trans-fat";
static NSString* const c_element_monounsaturatedFat = @"monounsaturated-fat";
static NSString* const c_element_polyunsaturatedFat = @"polyunsaturated-fat";

static NSString* const c_element_protein = @"protein";
static NSString* const c_element_carbs = @"carbohydrates";
static NSString* const c_element_fiber = @"dietary-fiber";
static NSString* const c_element_sugars = @"sugars";
static NSString* const c_element_sodium = @"sodium";
static NSString* const c_element_cholesterol = @"cholesterol";

static NSString* const c_element_calcium = @"calcium";
static NSString* const c_element_iron = @"iron";
static NSString* const c_element_magnesium = @"magnesium";
static NSString* const c_element_phosphorus = @"phosphorus";
static NSString* const c_element_potassium = @"potassium";
static NSString* const c_element_zinc = @"zinc";

static NSString* const c_element_vitaminA = @"vitamin-A-RAE";
static NSString* const c_element_vitaminE = @"vitamin-E";
static NSString* const c_element_vitaminD = @"vitamin-D";
static NSString* const c_element_vitaminC = @"vitamin-C";
static NSString* const c_element_thiamin = @"thiamin";
static NSString* const c_element_riboflavin = @"riboflavin";
static NSString* const c_element_niacin = @"niacin";
static NSString* const c_element_vitaminB6 = @"vitamin-B-6";
static NSString* const c_element_folate = @"folate-DFE";
static NSString* const c_element_vitaminB12 = @"vitamin-B-12";
static NSString* const c_element_vitaminK = @"vitamin-K";

static NSString* const c_element_additionalFacts = @"additional-nutrition-facts";

@implementation HVDietaryIntake

@synthesize foodItem = m_foodItem;
@synthesize servingSize = m_servingSize;
@synthesize servingsConsumed = m_servingsConsumed;
@synthesize meal = m_meal;
@synthesize when = m_when;

@synthesize calories = m_calories;
@synthesize caloriesFromFat = m_caloriesFromFat;
@synthesize totalFat = m_totalFat;
@synthesize saturatedFat = m_saturatedFat;
@synthesize transFat = m_transFat;
@synthesize monounsaturatedFat = m_monoUnsaturatedFat;
@synthesize polyunsaturatedFat = m_polyUnsaturatedFat;

@synthesize protein = m_protein;
@synthesize carbs = m_carbs;
@synthesize dietaryFiber = m_fiber;
@synthesize sugar = m_sugar;
@synthesize sodium = m_sodium;
@synthesize cholesterol = m_cholesterol;

@synthesize calcium = m_calcium;
@synthesize iron = m_iron;
@synthesize magnesium = m_magnesium;
@synthesize phosphorus = m_phosphorus;
@synthesize potassium = m_potassium;
@synthesize zinc = m_zinc;

@synthesize vitaminA = m_vitaminA;
@synthesize vitaminE = m_vitaminE;
@synthesize vitaminD = m_vitaminD;
@synthesize vitaminC = m_vitaminC;
@synthesize thiamin = m_thiamin;
@synthesize riboflavin = m_riboflavin;
@synthesize niacin = m_niacin;
@synthesize vitaminB6 = m_vitaminB6;
@synthesize folate = m_folate;
@synthesize vitaminB12 = m_vitaminB12;
@synthesize vitaminK = m_vitaminK;

@synthesize additionalFacts = m_additionalFacts;

-(void)dealloc
{
    [m_foodItem release];
    [m_servingSize release];
    [m_servingsConsumed release];
    [m_meal release];
    [m_when release];
    
    [m_calories release];
    [m_caloriesFromFat release];
    [m_totalFat release];
    [m_saturatedFat release];
    [m_transFat release];
    [m_monoUnsaturatedFat release];
    [m_polyUnsaturatedFat release];
    
    [m_protein release];
    [m_carbs release];
    [m_fiber release];
    [m_sugar release];
    [m_sodium release];
    [m_cholesterol release];
    
    [m_calcium release];
    [m_iron release];
    [m_magnesium release];
    [m_phosphorus release];
    [m_potassium release];
    [m_zinc release];
    
    [m_vitaminA release];
    [m_vitaminE release];
    [m_vitaminD release];
    [m_vitaminC release];
    [m_thiamin release];
    [m_riboflavin release];
    [m_niacin release];
    [m_vitaminB6 release];
    [m_folate release];
    [m_vitaminB12 release];
    [m_vitaminK release];
    
    [m_additionalFacts release];
    
    [super dealloc];
}

-(NSDate *)getDate
{
    return (m_when) ? [m_when toDate] : nil;
}

+(HVVocabIdentifier *)vocabForFood
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_usdaFamily andName:@"food-description"] autorelease];    
}

+(HVVocabIdentifier *)vocabForMeals
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"dietary-intake-meals"] autorelease];    
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_foodItem, HVClientError_InvalidDietaryIntake);
    HVVALIDATE_OPTIONAL(m_servingSize);
    HVVALIDATE_OPTIONAL(m_servingsConsumed);
    HVVALIDATE_OPTIONAL(m_meal);
    HVVALIDATE_OPTIONAL(m_when);
    
    HVVALIDATE_OPTIONAL(m_calories);
    HVVALIDATE_OPTIONAL(m_caloriesFromFat);
    HVVALIDATE_OPTIONAL(m_totalFat);
    HVVALIDATE_OPTIONAL(m_saturatedFat);
    HVVALIDATE_OPTIONAL(m_transFat);
    HVVALIDATE_OPTIONAL(m_monoUnsaturatedFat);
    HVVALIDATE_OPTIONAL(m_polyUnsaturatedFat);
    
    HVVALIDATE_OPTIONAL(m_protein);
    HVVALIDATE_OPTIONAL(m_carbs);
    HVVALIDATE_OPTIONAL(m_fiber);
    HVVALIDATE_OPTIONAL(m_sugar);
    HVVALIDATE_OPTIONAL(m_sodium);
    HVVALIDATE_OPTIONAL(m_cholesterol);
    
    HVVALIDATE_OPTIONAL(m_calcium);
    HVVALIDATE_OPTIONAL(m_iron);
    HVVALIDATE_OPTIONAL(m_magnesium);
    HVVALIDATE_OPTIONAL(m_phosphorus);
    HVVALIDATE_OPTIONAL(m_potassium);
    HVVALIDATE_OPTIONAL(m_zinc);
    
    HVVALIDATE_OPTIONAL(m_vitaminA);
    HVVALIDATE_OPTIONAL(m_vitaminE);
    HVVALIDATE_OPTIONAL(m_vitaminD);
    HVVALIDATE_OPTIONAL(m_vitaminC);
    HVVALIDATE_OPTIONAL(m_thiamin);
    HVVALIDATE_OPTIONAL(m_riboflavin);
    HVVALIDATE_OPTIONAL(m_niacin);
    HVVALIDATE_OPTIONAL(m_vitaminB6);
    HVVALIDATE_OPTIONAL(m_folate);
    HVVALIDATE_OPTIONAL(m_vitaminB12);
    HVVALIDATE_OPTIONAL(m_vitaminK);
    
    HVVALIDATE_OPTIONAL(m_additionalFacts);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_foodItem, c_element_foodItem, HVCodableValue);
    HVDESERIALIZE(m_servingSize, c_element_servingSize, HVCodableValue);
    HVDESERIALIZE(m_servingsConsumed, c_element_servingsConsumed, HVNonNegativeDouble);
    HVDESERIALIZE(m_meal, c_element_meal, HVCodableValue);
    
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    
    HVDESERIALIZE(m_calories, c_element_calories, HVFoodEnergyValue);
    HVDESERIALIZE(m_caloriesFromFat, c_element_energyFat, HVFoodEnergyValue);
    HVDESERIALIZE(m_totalFat, c_element_totalFat, HVWeightMeasurement);
    HVDESERIALIZE(m_saturatedFat, c_element_saturatedFat, HVWeightMeasurement);
    HVDESERIALIZE(m_transFat, c_element_transFat, HVWeightMeasurement);
    HVDESERIALIZE(m_monoUnsaturatedFat, c_element_monounsaturatedFat, HVWeightMeasurement);
    HVDESERIALIZE(m_polyUnsaturatedFat, c_element_polyunsaturatedFat, HVWeightMeasurement);
    
    HVDESERIALIZE(m_protein, c_element_protein, HVWeightMeasurement);
    HVDESERIALIZE(m_carbs, c_element_carbs, HVWeightMeasurement);
    HVDESERIALIZE(m_fiber, c_element_fiber, HVWeightMeasurement);
    HVDESERIALIZE(m_sugar, c_element_sugars, HVWeightMeasurement);
    HVDESERIALIZE(m_sodium, c_element_sodium, HVWeightMeasurement);
    HVDESERIALIZE(m_cholesterol, c_element_cholesterol, HVWeightMeasurement);
    
    HVDESERIALIZE(m_calcium, c_element_calcium, HVWeightMeasurement);
    HVDESERIALIZE(m_iron, c_element_iron, HVWeightMeasurement);
    HVDESERIALIZE(m_magnesium, c_element_magnesium, HVWeightMeasurement);
    HVDESERIALIZE(m_phosphorus, c_element_phosphorus, HVWeightMeasurement);
    HVDESERIALIZE(m_potassium, c_element_potassium, HVWeightMeasurement);
    HVDESERIALIZE(m_zinc, c_element_zinc, HVWeightMeasurement);
    
    HVDESERIALIZE(m_vitaminA, c_element_vitaminA, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminE, c_element_vitaminE, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminD, c_element_vitaminD, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminC, c_element_vitaminC, HVWeightMeasurement);
    HVDESERIALIZE(m_thiamin, c_element_thiamin, HVWeightMeasurement);
    HVDESERIALIZE(m_riboflavin, c_element_riboflavin, HVWeightMeasurement);
    HVDESERIALIZE(m_niacin, c_element_niacin, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminB6, c_element_vitaminB6, HVWeightMeasurement);
    HVDESERIALIZE(m_folate, c_element_folate, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminB12, c_element_vitaminB12, HVWeightMeasurement);
    HVDESERIALIZE(m_vitaminK, c_element_vitaminK, HVWeightMeasurement);
    
    HVDESERIALIZE(m_additionalFacts, c_element_additionalFacts, HVAdditionalNutritionFacts);
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_foodItem, c_element_foodItem);
    HVSERIALIZE(m_servingSize, c_element_servingSize);
    HVSERIALIZE(m_servingsConsumed, c_element_servingsConsumed);
    HVSERIALIZE(m_meal, c_element_meal);
    
    HVSERIALIZE(m_when, c_element_when);
    
    HVSERIALIZE(m_calories, c_element_calories);
    HVSERIALIZE(m_caloriesFromFat, c_element_energyFat);
    HVSERIALIZE(m_totalFat, c_element_totalFat);
    HVSERIALIZE(m_saturatedFat, c_element_saturatedFat);
    HVSERIALIZE(m_transFat, c_element_transFat);
    HVSERIALIZE(m_monoUnsaturatedFat, c_element_monounsaturatedFat);
    HVSERIALIZE(m_polyUnsaturatedFat, c_element_polyunsaturatedFat);
    
    HVSERIALIZE(m_protein, c_element_protein);
    HVSERIALIZE(m_carbs, c_element_carbs);
    HVSERIALIZE(m_fiber, c_element_fiber);
    HVSERIALIZE(m_sugar, c_element_sugars);
    HVSERIALIZE(m_sodium, c_element_sodium);
    HVSERIALIZE(m_cholesterol, c_element_cholesterol);
    
    HVSERIALIZE(m_calcium, c_element_calcium);
    HVSERIALIZE(m_iron, c_element_iron);
    HVSERIALIZE(m_magnesium, c_element_magnesium);
    HVSERIALIZE(m_phosphorus, c_element_phosphorus);
    HVSERIALIZE(m_potassium, c_element_potassium);
    HVSERIALIZE(m_zinc, c_element_zinc);
    
    HVSERIALIZE(m_vitaminA, c_element_vitaminA);
    HVSERIALIZE(m_vitaminE, c_element_vitaminE);
    HVSERIALIZE(m_vitaminD, c_element_vitaminD);
    HVSERIALIZE(m_vitaminC, c_element_vitaminC);
    HVSERIALIZE(m_thiamin, c_element_thiamin);
    HVSERIALIZE(m_riboflavin, c_element_riboflavin);
    HVSERIALIZE(m_niacin, c_element_niacin);
    HVSERIALIZE(m_vitaminB6, c_element_vitaminB6);
    HVSERIALIZE(m_folate, c_element_folate);
    HVSERIALIZE(m_vitaminB12, c_element_vitaminB12);
    HVSERIALIZE(m_vitaminK, c_element_vitaminK);
    
    HVSERIALIZE(m_additionalFacts, c_element_additionalFacts);
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

-(NSString *)typeName
{
    return NSLocalizedString(@"Dietary intake", @"Dietary intake type Name");
}

+(void)registerType
{
    [[HVTypeSystem current] addClass:[HVDietaryIntake class] forTypeID:[HVDietaryIntake typeID]];    
}

@end
