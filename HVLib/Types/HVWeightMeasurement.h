//
//  HVWeightMeasurement.h
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
#import "HVType.h"
#import "HVPositiveDouble.h"
#import "HVDisplayValue.h"

@interface HVWeightMeasurement : HVType
{
@private
    HVPositiveDouble* m_kg;
    HVDisplayValue* m_display;
}

@property (readwrite, nonatomic, retain) HVPositiveDouble* value;
//
// Required - either KG or Pounds
//
@property (readwrite, nonatomic) double kg;
@property (readwrite, nonatomic) double pounds;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVDisplayValue *display;


-(id) initWithKg:(double) value;
-(id) initwithPounds:(double) value;

-(BOOL) updateDisplayValue:(double) displayValue andUnits:(NSString *) unitValue;

-(NSString *) toString;
//
// These methods expect a format string with one %f in it.
//
-(NSString *) toStringWithFormat:(NSString *) format;
-(NSString *) stringInPounds:(NSString *) format;
-(NSString *) stringInOunces:(NSString *) format;
-(NSString *) stringInKg:(NSString *) format;
-(NSString *) stringInGrams:(NSString *) format;

+(double) kgToPounds:(double) kg;
+(double) poundsToKg:(double) pounds;
+(double) roundKg:(double) kg;
+(double) roundPounds:(double) pounds;

@end
