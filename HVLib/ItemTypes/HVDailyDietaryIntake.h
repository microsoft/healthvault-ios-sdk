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

#import <Foundation/Foundation.h>
#import "HVTypes.h"

//------------------------
//
// DAILY Dietary Intake
// DEPRECATED.
// This type is obsolete.
// Use HVDietaryIntake
//
//------------------------
@interface HVDailyDietaryIntake : HVItemDataTyped
{
@private
    HVDate* m_when;
    HVPositiveInt* m_calories;
    HVWeightMeasurement* m_totalFat;
    HVWeightMeasurement* m_saturatedFat;
    HVWeightMeasurement* m_transFat;
    HVWeightMeasurement* m_protein;
    HVWeightMeasurement* m_carbs;
    HVWeightMeasurement* m_fiber;
    HVWeightMeasurement* m_sugar;
    HVWeightMeasurement* m_sodium;
    HVWeightMeasurement* m_cholesterol;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - the day for this intake
//
@property (readwrite, nonatomic, retain) HVDate* when;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVPositiveInt* calories;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* totalFat;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* saturatedFat;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* transFat;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* protein;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* totalCarbs;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* sugar;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* dietaryFiber;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* sodium;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVWeightMeasurement* cholesterol;

//
// Convenience properties
//
@property (readwrite, nonatomic) int caloriesValue;
@property (readwrite, nonatomic) double totalFatGrams;
@property (readwrite, nonatomic) double saturatedFatGrams;
@property (readwrite, nonatomic) double transFatGrams;
@property (readwrite, nonatomic) double proteinGrams;
@property (readwrite, nonatomic) double totalCarbGrams;
@property (readwrite, nonatomic) double sugarGrams;
@property (readwrite, nonatomic) double dietaryFiberGrams;
@property (readwrite, nonatomic) double sodiumMillgrams;
@property (readwrite, nonatomic) double cholesterolMilligrams;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
