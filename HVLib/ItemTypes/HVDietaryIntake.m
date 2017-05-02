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
    m_foodItem = [[reader readElementWithXmlName:x_element_foodItem asClass:[HVCodableValue class]] retain];
    m_servingSize = [[reader readElementWithXmlName:x_element_servingSize asClass:[HVCodableValue class]] retain];
    m_servingsConsumed = [[reader readElementWithXmlName:x_element_servingsConsumed asClass:[HVNonNegativeDouble class]] retain];
    m_meal = [[reader readElementWithXmlName:x_element_meal asClass:[HVCodableValue class]] retain];
    
    m_when = [[reader readElementWithXmlName:x_element_when asClass:[HVDateTime class]] retain];
    
    m_calories = [[reader readElementWithXmlName:x_element_calories asClass:[HVFoodEnergyValue class]] retain];
    m_caloriesFromFat = [[reader readElementWithXmlName:x_element_energyFat asClass:[HVFoodEnergyValue class]] retain];
    m_totalFat = [[reader readElementWithXmlName:x_element_totalFat asClass:[HVWeightMeasurement class]] retain];
    m_saturatedFat = [[reader readElementWithXmlName:x_element_saturatedFat asClass:[HVWeightMeasurement class]] retain];
    m_transFat = [[reader readElementWithXmlName:x_element_transFat asClass:[HVWeightMeasurement class]] retain];
    m_monoUnsaturatedFat = [[reader readElementWithXmlName:x_element_monounsaturatedFat asClass:[HVWeightMeasurement class]] retain];
    m_polyUnsaturatedFat = [[reader readElementWithXmlName:x_element_polyunsaturatedFat asClass:[HVWeightMeasurement class]] retain];
    
    m_protein = [[reader readElementWithXmlName:x_element_protein asClass:[HVWeightMeasurement class]] retain];
    m_carbs = [[reader readElementWithXmlName:x_element_carbs asClass:[HVWeightMeasurement class]] retain];
    m_fiber = [[reader readElementWithXmlName:x_element_fiber asClass:[HVWeightMeasurement class]] retain];
    m_sugar = [[reader readElementWithXmlName:x_element_sugars asClass:[HVWeightMeasurement class]] retain];
    m_sodium = [[reader readElementWithXmlName:x_element_sodium asClass:[HVWeightMeasurement class]] retain];
    m_cholesterol = [[reader readElementWithXmlName:x_element_cholesterol asClass:[HVWeightMeasurement class]] retain];
    
    m_calcium = [[reader readElementWithXmlName:x_element_calcium asClass:[HVWeightMeasurement class]] retain];
    m_iron = [[reader readElementWithXmlName:x_element_iron asClass:[HVWeightMeasurement class]] retain];
    m_magnesium = [[reader readElementWithXmlName:x_element_magnesium asClass:[HVWeightMeasurement class]] retain];
    m_phosphorus = [[reader readElementWithXmlName:x_element_phosphorus asClass:[HVWeightMeasurement class]] retain];
    m_potassium = [[reader readElementWithXmlName:x_element_potassium asClass:[HVWeightMeasurement class]] retain];
    m_zinc = [[reader readElementWithXmlName:x_element_zinc asClass:[HVWeightMeasurement class]] retain];
    
    m_vitaminA = [[reader readElementWithXmlName:x_element_vitaminA asClass:[HVWeightMeasurement class]] retain];
    m_vitaminE = [[reader readElementWithXmlName:x_element_vitaminE asClass:[HVWeightMeasurement class]] retain];
    m_vitaminD = [[reader readElementWithXmlName:x_element_vitaminD asClass:[HVWeightMeasurement class]] retain];
    m_vitaminC = [[reader readElementWithXmlName:x_element_vitaminC asClass:[HVWeightMeasurement class]] retain];
    m_thiamin = [[reader readElementWithXmlName:x_element_thiamin asClass:[HVWeightMeasurement class]] retain];
    m_riboflavin = [[reader readElementWithXmlName:x_element_riboflavin asClass:[HVWeightMeasurement class]] retain];
    m_niacin = [[reader readElementWithXmlName:x_element_niacin asClass:[HVWeightMeasurement class]] retain];
    m_vitaminB6 = [[reader readElementWithXmlName:x_element_vitaminB6 asClass:[HVWeightMeasurement class]] retain];
    m_folate = [[reader readElementWithXmlName:x_element_folate asClass:[HVWeightMeasurement class]] retain];
    m_vitaminB12 = [[reader readElementWithXmlName:x_element_vitaminB12 asClass:[HVWeightMeasurement class]] retain];
    m_vitaminK = [[reader readElementWithXmlName:x_element_vitaminK asClass:[HVWeightMeasurement class]] retain];
    
    m_additionalFacts = [[reader readElement:c_element_additionalFacts asClass:[HVAdditionalNutritionFacts class]] retain];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_foodItem content:m_foodItem];
    [writer writeElementXmlName:x_element_servingSize content:m_servingSize];
    [writer writeElementXmlName:x_element_servingsConsumed content:m_servingsConsumed];
    [writer writeElementXmlName:x_element_meal content:m_meal];
    
    [writer writeElementXmlName:x_element_when content:m_when];
    
    [writer writeElementXmlName:x_element_calories content:m_calories];
    [writer writeElementXmlName:x_element_energyFat content:m_caloriesFromFat];
    [writer writeElementXmlName:x_element_totalFat content:m_totalFat];
    [writer writeElementXmlName:x_element_saturatedFat content:m_saturatedFat];
    [writer writeElementXmlName:x_element_transFat content:m_transFat];
    [writer writeElementXmlName:x_element_monounsaturatedFat content:m_monoUnsaturatedFat];
    [writer writeElementXmlName:x_element_polyunsaturatedFat content:m_polyUnsaturatedFat];
    
    [writer writeElementXmlName:x_element_protein content:m_protein];
    [writer writeElementXmlName:x_element_carbs content:m_carbs];
    [writer writeElementXmlName:x_element_fiber content:m_fiber];
    [writer writeElementXmlName:x_element_sugars content:m_sugar];
    [writer writeElementXmlName:x_element_sodium content:m_sodium];
    [writer writeElementXmlName:x_element_cholesterol content:m_cholesterol];
    
    [writer writeElementXmlName:x_element_calcium content:m_calcium];
    [writer writeElementXmlName:x_element_iron content:m_iron];
    [writer writeElementXmlName:x_element_magnesium content:m_magnesium];
    [writer writeElementXmlName:x_element_phosphorus content:m_phosphorus];
    [writer writeElementXmlName:x_element_potassium content:m_potassium];
    [writer writeElementXmlName:x_element_zinc content:m_zinc];
    
    [writer writeElementXmlName:x_element_vitaminA content:m_vitaminA];
    [writer writeElementXmlName:x_element_vitaminE content:m_vitaminE];
    [writer writeElementXmlName:x_element_vitaminD content:m_vitaminD];
    [writer writeElementXmlName:x_element_vitaminC content:m_vitaminC];
    [writer writeElementXmlName:x_element_thiamin content:m_thiamin];
    [writer writeElementXmlName:x_element_riboflavin content:m_riboflavin];
    [writer writeElementXmlName:x_element_niacin content:m_niacin];
    [writer writeElementXmlName:x_element_vitaminB6 content:m_vitaminB6];
    [writer writeElementXmlName:x_element_folate content:m_folate];
    [writer writeElementXmlName:x_element_vitaminB12 content:m_vitaminB12];
    [writer writeElementXmlName:x_element_vitaminK content:m_vitaminK];
    
    [writer writeElement:c_element_additionalFacts content:m_additionalFacts];
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
