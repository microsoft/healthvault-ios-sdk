//
//  Weight.h
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"

@interface HVWeight : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVWeightMeasurement* m_value;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) When the measurement was made
//
@property (readwrite, nonatomic, strong) HVDateTime* when;
//
// (Required) The weight measurement
// You can also use the inPounds and inKg properties to set the weight value
//
@property (readwrite, nonatomic, strong) HVWeightMeasurement* value;

//
// Helper properties for manipulating weight
//
@property (readwrite, nonatomic) double inPounds;
@property (readwrite, nonatomic) double inKg;

//-------------------------
//
// Initializers 
//
//-------------------------
-(id) initWithKg:(double) kg andDate:(NSDate*) date;
-(id) initWithPounds:(double) pounds andDate:(NSDate *) date;

+(HVItem *) newItem;
+(HVItem *) newItemWithKg:(double) kg andDate:(NSDate*) date;
+(HVItem *) newItemWithPounds:(double) pounds andDate:(NSDate *) date;

//-------------------------
//
// Text 
//
//-------------------------
-(NSString *) toString;  // Returns weight in kg
-(NSString *) stringInPounds;
-(NSString *) stringInKg;
//
// These methods expect a format string with a %f in it, surrounded with other decorative text of your choice
//
-(NSString *) stringInPoundsWithFormat:(NSString *) format;
-(NSString *) stringInKgWithFormat:(NSString *) format;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
