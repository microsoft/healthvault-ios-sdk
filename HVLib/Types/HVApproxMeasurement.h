//
//  HVApproxMeasurement.h
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

#import "HVType.h"
#import "HVMeasurement.h"

//-------------------------
//
// Sometimes it is not possible to get a precise numeric measurement. 
// Descriptive (approx) measurements can include: "A lot", "Strong", "Weak", "Big", "Small"...
//
//-------------------------
@interface HVApproxMeasurement : HVType
{
@private
    NSString* m_display;
    HVMeasurement* m_measurement;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - You must supply at least a descriptive display text
//
@property (readwrite, nonatomic, retain) NSString* displayText;
//
// (Optional) - A coded measurement value
//
@property (readwrite, nonatomic, retain) HVMeasurement* measurement;

//
// Convenience
//
@property (readonly, nonatomic) BOOL hasMeasurement;
//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithDisplayText:(NSString *) text;
-(id) initWithDisplayText:(NSString *)text andMeasurement:(HVMeasurement *) measurement;

+(HVApproxMeasurement *) fromDisplayText:(NSString *) text;
+(HVApproxMeasurement *) fromDisplayText:(NSString *) text andMeasurement:(HVMeasurement *) measurement;
+(HVApproxMeasurement *) fromValue:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)code unitsVocab:(NSString *) vocab;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

@end
