//
//  HVDietaryIntake.h
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"
#import "HVVocab.h"

@interface HVDietaryIntake : HVItemDataTyped
{
@private
    HVCodableValue* m_foodItem;
    HVCodableValue* m_servingSize;
    HVNonNegativeDouble* m_servingsConsumed;
    HVCodableValue* m_meal;
    HVDateTime* m_when;
    
    HVFoodEnergyValue* m_calories;
    HVFoodEnergyValue* m_caloriesFromFat;
    HVWeightMeasurement* m_totalFat;
    HVWeightMeasurement* m_saturatedFat;
    HVWeightMeasurement* m_transFat;
    HVWeightMeasurement* m_monoUnsaturatedFat;
    HVWeightMeasurement* m_polyUnsaturatedFat;
    
    HVWeightMeasurement* m_protein;
    HVWeightMeasurement* m_carbs;
    HVWeightMeasurement* m_fiber;
    HVWeightMeasurement* m_sugar;
    HVWeightMeasurement* m_sodium;
    HVWeightMeasurement* m_cholesterol;
    
    HVWeightMeasurement* m_calcium;
    HVWeightMeasurement* m_iron;
    HVWeightMeasurement* m_magnesium;
    HVWeightMeasurement* m_phosphorus;
    HVWeightMeasurement* m_potassium;
    HVWeightMeasurement* m_zinc;
    
    HVWeightMeasurement* m_vitaminA;
    HVWeightMeasurement* m_vitaminE;
    HVWeightMeasurement* m_vitaminD;
    HVWeightMeasurement* m_vitaminC;
    HVWeightMeasurement* m_thiamin;
    HVWeightMeasurement* m_riboflavin;
    HVWeightMeasurement* m_niacin;
    HVWeightMeasurement* m_vitaminB6;
    HVWeightMeasurement* m_folate;
    HVWeightMeasurement* m_vitaminB12;
    HVWeightMeasurement* m_vitaminK;
    
    HVAdditionalNutritionFacts* m_additionalFacts;
}

//
// (Required)
//
@property (readwrite, nonatomic, strong) HVCodableValue* foodItem;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVCodableValue* servingSize;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVNonNegativeDouble* servingsConsumed;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVCodableValue* meal;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVDateTime* when;

//--------------------
//
// ALL OPTIONAL
//
//--------------------

@property (readwrite, nonatomic, strong) HVFoodEnergyValue* calories;           // Cal
@property (readwrite, nonatomic, strong) HVFoodEnergyValue* caloriesFromFat;    // Cal

@property (readwrite, nonatomic, strong) HVWeightMeasurement* totalFat;         // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* saturatedFat;     // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* transFat;         // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* monounsaturatedFat; //g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* polyunsaturatedFat; //g

@property (readwrite, nonatomic, strong) HVWeightMeasurement* protein;      // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* carbs;        // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* dietaryFiber; // g
@property (readwrite, nonatomic, strong) HVWeightMeasurement* sugar;        // g

@property (readwrite, nonatomic, strong) HVWeightMeasurement* sodium;       // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* cholesterol;  // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* calcium;      // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* iron;         // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* magnesium;    // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* phosphorus;   // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* potassium;    // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* zinc;         // mg

@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminA;     // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminE;     // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminD;     // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminC;     // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* thiamin;      // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* riboflavin;   // mg
@property (readwrite, nonatomic, strong) HVWeightMeasurement* niacin;
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminB6;
@property (readwrite, nonatomic, strong) HVWeightMeasurement* folate;
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminB12;
@property (readwrite, nonatomic, strong) HVWeightMeasurement* vitaminK;

@property (readwrite, nonatomic, strong) HVAdditionalNutritionFacts* additionalFacts;

//---------------------
//
// HVVocab
//
//---------------------
+(HVVocabIdentifier *) vocabForFood;
+(HVVocabIdentifier *) vocabForMeals;

//---------------------
//
// Some standard codes
//
//---------------------
+(HVCodableValue *) mealCodeForBreakfast;
+(HVCodableValue *) mealCodeForLunch;
+(HVCodableValue *) mealCodeForDinner;
+(HVCodableValue *) mealCodeForSnack;

//--------------------
//
// TypeInfo
//
//--------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
