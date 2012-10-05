//
//  HVFoodEnergyValue.h
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
#import "HVType.h"
#import "HVNonNegativeDouble.h"
#import "HVDisplayValue.h"

@interface HVFoodEnergyValue : HVType
{
@private
    HVNonNegativeDouble* m_calories;
    HVDisplayValue* m_display;
}
//
// Required
// Note: these are dietary calories - or "large" calories. 
// The amount of energy needed to raise the temperature of 1Kg of water by 1 degree Celsius
// Or approx 4.2 kilojoules
//
@property (readwrite, nonatomic, retain) HVNonNegativeDouble* calories;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVDisplayValue* displayValue;

@property (readwrite, nonatomic) double caloriesValue;

-(id) initWithCalories:(double) value;

-(BOOL) updateDisplayText;

-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

+(HVFoodEnergyValue *) fromCalories:(double) value;

+(NSString *) calorieUnits;


@end
