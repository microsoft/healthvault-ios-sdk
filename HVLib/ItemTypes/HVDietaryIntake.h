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

@interface HVDietaryIntake : HVItemDataTyped
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

@property (readwrite, nonatomic, retain) HVDate* when;
@property (readwrite, nonatomic, retain) HVPositiveInt* calories;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* totalFat;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* saturatedFat;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* transFat;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* protein;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* carbs;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* fiber;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* sodium;
@property (readwrite, nonatomic, retain) HVWeightMeasurement* cholesterol;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
