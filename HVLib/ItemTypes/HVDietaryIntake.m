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

static NSString* const c_element_additionalFacts = @"additional-nutrition-facts";

static const xmlChar* x_element_foodItem = XMLSTRINGCONST("food-item");
static const xmlChar* x_element_servingSize = XMLSTRINGCONST("serving-size");
static const xmlChar* x_element_servingsConsumed = XMLSTRINGCONST("servings-consumed");
static const xmlChar* x_element_meal = XMLSTRINGCONST("meal");
static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_calories = XMLSTRINGCONST("energy");
static const xmlChar* x_element_energyFat = XMLSTRINGCONST("energy-from-fat");
static const xmlChar* x_element_totalFat = XMLSTRINGCONST("total-fat");
static const xmlChar* x_element_saturatedFat = XMLSTRINGCONST("saturated-fat");
static const xmlChar* x_element_transFat = XMLSTRINGCONST("trans-fat");
static const xmlChar* x_element_monounsaturatedFat = XMLSTRINGCONST("monounsaturated-fat");
static const xmlChar* x_element_polyunsaturatedFat = XMLSTRINGCONST("polyunsaturated-fat");

static const xmlChar* x_element_protein = XMLSTRINGCONST("protein");
static const xmlChar* x_element_carbs = XMLSTRINGCONST("carbohydrates");
static const xmlChar* x_element_fiber = XMLSTRINGCONST("dietary-fiber");
static const xmlChar* x_element_sugars = XMLSTRINGCONST("sugars");
static const xmlChar* x_element_sodium = XMLSTRINGCONST("sodium");
static const xmlChar* x_element_cholesterol = XMLSTRINGCONST("cholesterol");

static const xmlChar* x_element_calcium = XMLSTRINGCONST("calcium");
static const xmlChar* x_element_iron = XMLSTRINGCONST("iron");
static const xmlChar* x_element_magnesium = XMLSTRINGCONST("magnesium");
static const xmlChar* x_element_phosphorus = XMLSTRINGCONST("phosphorus");
static const xmlChar* x_element_potassium = XMLSTRINGCONST("potassium");
static const xmlChar* x_element_zinc = XMLSTRINGCONST("zinc");

static const xmlChar* x_element_vitaminA = XMLSTRINGCONST("vitamin-A-RAE");
static const xmlChar* x_element_vitaminE = XMLSTRINGCONST("vitamin-E");
static const xmlChar* x_element_vitaminD = XMLSTRINGCONST("vitamin-D");
static const xmlChar* x_element_vitaminC = XMLSTRINGCONST("vitamin-C");
static const xmlChar* x_element_thiamin = XMLSTRINGCONST("thiamin");
static const xmlChar* x_element_riboflavin = XMLSTRINGCONST("riboflavin");
static const xmlChar* x_element_niacin = XMLSTRINGCONST("niacin");
static const xmlChar* x_element_vitaminB6 = XMLSTRINGCONST("vitamin-B-6");
static const xmlChar* x_element_folate = XMLSTRINGCONST("folate-DFE");
static const xmlChar* x_element_vitaminB12 = XMLSTRINGCONST("vitamin-B-12");
static const xmlChar* x_element_vitaminK = XMLSTRINGCONST("vitamin-K");

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

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return (m_when) ? [m_when toDateForCalendar:calendar] : nil;
}

+(HVVocabIdentifier *)vocabForFood
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_usdaFamily andName:@"food-description"] autorelease];    
}

+(HVVocabIdentifier *)vocabForMeals
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"dietary-intake-meals"] autorelease];    
}

+(HVCodableValue *)mealCodeForBreakfast
{
    return [[HVDietaryIntake vocabForMeals] codableValueForText:@"Breakfast" andCode:@"B"];
}

+(HVCodableValue *)mealCodeForLunch
{
    return [[HVDietaryIntake vocabForMeals] codableValueForText:@"Lunch" andCode:@"L"];    
}

+(HVCodableValue *)mealCodeForDinner
{
    return [[HVDietaryIntake vocabForMeals] codableValueForText:@"Dinner" andCode:@"D"];    
}

+(HVCodableValue *)mealCodeForSnack
{
    return [[HVDietaryIntake vocabForMeals] codableValueForText:@"Snack" andCode:@"S"];    
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
    HVDESERIALIZE_X(m_foodItem, x_element_foodItem, HVCodableValue);
    HVDESERIALIZE_X(m_servingSize, x_element_servingSize, HVCodableValue);
    HVDESERIALIZE_X(m_servingsConsumed, x_element_servingsConsumed, HVNonNegativeDouble);
    HVDESERIALIZE_X(m_meal, x_element_meal, HVCodableValue);
    
    HVDESERIALIZE_X(m_when, x_element_when, HVDateTime);
    
    HVDESERIALIZE_X(m_calories, x_element_calories, HVFoodEnergyValue);
    HVDESERIALIZE_X(m_caloriesFromFat, x_element_energyFat, HVFoodEnergyValue);
    HVDESERIALIZE_X(m_totalFat, x_element_totalFat, HVWeightMeasurement);
    HVDESERIALIZE_X(m_saturatedFat, x_element_saturatedFat, HVWeightMeasurement);
    HVDESERIALIZE_X(m_transFat, x_element_transFat, HVWeightMeasurement);
    HVDESERIALIZE_X(m_monoUnsaturatedFat, x_element_monounsaturatedFat, HVWeightMeasurement);
    HVDESERIALIZE_X(m_polyUnsaturatedFat, x_element_polyunsaturatedFat, HVWeightMeasurement);
    
    HVDESERIALIZE_X(m_protein, x_element_protein, HVWeightMeasurement);
    HVDESERIALIZE_X(m_carbs, x_element_carbs, HVWeightMeasurement);
    HVDESERIALIZE_X(m_fiber, x_element_fiber, HVWeightMeasurement);
    HVDESERIALIZE_X(m_sugar, x_element_sugars, HVWeightMeasurement);
    HVDESERIALIZE_X(m_sodium, x_element_sodium, HVWeightMeasurement);
    HVDESERIALIZE_X(m_cholesterol, x_element_cholesterol, HVWeightMeasurement);
    
    HVDESERIALIZE_X(m_calcium, x_element_calcium, HVWeightMeasurement);
    HVDESERIALIZE_X(m_iron, x_element_iron, HVWeightMeasurement);
    HVDESERIALIZE_X(m_magnesium, x_element_magnesium, HVWeightMeasurement);
    HVDESERIALIZE_X(m_phosphorus, x_element_phosphorus, HVWeightMeasurement);
    HVDESERIALIZE_X(m_potassium, x_element_potassium, HVWeightMeasurement);
    HVDESERIALIZE_X(m_zinc, x_element_zinc, HVWeightMeasurement);
    
    HVDESERIALIZE_X(m_vitaminA, x_element_vitaminA, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminE, x_element_vitaminE, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminD, x_element_vitaminD, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminC, x_element_vitaminC, HVWeightMeasurement);
    HVDESERIALIZE_X(m_thiamin, x_element_thiamin, HVWeightMeasurement);
    HVDESERIALIZE_X(m_riboflavin, x_element_riboflavin, HVWeightMeasurement);
    HVDESERIALIZE_X(m_niacin, x_element_niacin, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminB6, x_element_vitaminB6, HVWeightMeasurement);
    HVDESERIALIZE_X(m_folate, x_element_folate, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminB12, x_element_vitaminB12, HVWeightMeasurement);
    HVDESERIALIZE_X(m_vitaminK, x_element_vitaminK, HVWeightMeasurement);
    
    HVDESERIALIZE(m_additionalFacts, c_element_additionalFacts, HVAdditionalNutritionFacts);
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_foodItem, x_element_foodItem);
    HVSERIALIZE_X(m_servingSize, x_element_servingSize);
    HVSERIALIZE_X(m_servingsConsumed, x_element_servingsConsumed);
    HVSERIALIZE_X(m_meal, x_element_meal);
    
    HVSERIALIZE_X(m_when, x_element_when);
    
    HVSERIALIZE_X(m_calories, x_element_calories);
    HVSERIALIZE_X(m_caloriesFromFat, x_element_energyFat);
    HVSERIALIZE_X(m_totalFat, x_element_totalFat);
    HVSERIALIZE_X(m_saturatedFat, x_element_saturatedFat);
    HVSERIALIZE_X(m_transFat, x_element_transFat);
    HVSERIALIZE_X(m_monoUnsaturatedFat, x_element_monounsaturatedFat);
    HVSERIALIZE_X(m_polyUnsaturatedFat, x_element_polyunsaturatedFat);
    
    HVSERIALIZE_X(m_protein, x_element_protein);
    HVSERIALIZE_X(m_carbs, x_element_carbs);
    HVSERIALIZE_X(m_fiber, x_element_fiber);
    HVSERIALIZE_X(m_sugar, x_element_sugars);
    HVSERIALIZE_X(m_sodium, x_element_sodium);
    HVSERIALIZE_X(m_cholesterol, x_element_cholesterol);
    
    HVSERIALIZE_X(m_calcium, x_element_calcium);
    HVSERIALIZE_X(m_iron, x_element_iron);
    HVSERIALIZE_X(m_magnesium, x_element_magnesium);
    HVSERIALIZE_X(m_phosphorus, x_element_phosphorus);
    HVSERIALIZE_X(m_potassium, x_element_potassium);
    HVSERIALIZE_X(m_zinc, x_element_zinc);
    
    HVSERIALIZE_X(m_vitaminA, x_element_vitaminA);
    HVSERIALIZE_X(m_vitaminE, x_element_vitaminE);
    HVSERIALIZE_X(m_vitaminD, x_element_vitaminD);
    HVSERIALIZE_X(m_vitaminC, x_element_vitaminC);
    HVSERIALIZE_X(m_thiamin, x_element_thiamin);
    HVSERIALIZE_X(m_riboflavin, x_element_riboflavin);
    HVSERIALIZE_X(m_niacin, x_element_niacin);
    HVSERIALIZE_X(m_vitaminB6, x_element_vitaminB6);
    HVSERIALIZE_X(m_folate, x_element_folate);
    HVSERIALIZE_X(m_vitaminB12, x_element_vitaminB12);
    HVSERIALIZE_X(m_vitaminK, x_element_vitaminK);
    
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
