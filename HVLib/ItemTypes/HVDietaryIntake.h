//
//  HVDietaryIntake.h
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
@property (readwrite, nonatomic, retain) HVCodableValue* foodItem;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* servingSize;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVNonNegativeDouble* servingsConsumed;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* meal;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVDateTime* when;

//--------------------
//
// ALL OPTIONAL
//
//--------------------

@property (readwrite, nonatomic, retain) HVFoodEnergyValue* calories;           // Cal
@property (readwrite, nonatomic, retain) HVFoodEnergyValue* caloriesFromFat;    // Cal

@property (readwrite, nonatomic, retain) HVWeightMeasurement* totalFat;         // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* saturatedFat;     // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* transFat;         // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* monounsaturatedFat; //g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* polyunsaturatedFat; //g

@property (readwrite, nonatomic, retain) HVWeightMeasurement* protein;      // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* carbs;        // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* dietaryFiber; // g
@property (readwrite, nonatomic, retain) HVWeightMeasurement* sugar;        // g

@property (readwrite, nonatomic, retain) HVWeightMeasurement* sodium;       // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* cholesterol;  // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* calcium;      // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* iron;         // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* magnesium;    // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* phosphorus;   // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* potassium;    // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* zinc;         // mg

@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminA;     // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminE;     // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminD;     // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminC;     // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* thiamin;      // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* riboflavin;   // mg
@property (readwrite, nonatomic, retain) HVWeightMeasurement* niacin;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminB6;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* folate;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminB12;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* vitaminK;

@property (readwrite, nonatomic, retain) HVAdditionalNutritionFacts* additionalFacts;

//---------------------
//
// HVVocab
//
//---------------------
+(HVVocabIdentifier *) vocabForFood;
+(HVVocabIdentifier *) vocabForMeals;

//--------------------
//
// TypeInfo
//
//--------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
