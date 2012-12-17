//
//  HVLengthMeasurement.h
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

//-------------------------
//
// Length measurements - in meters
//
//-------------------------

@interface HVLengthMeasurement : HVType
{
    HVPositiveDouble* m_meters;
    HVDisplayValue* m_display;    
}

//-------------------------
//
// Length Data
//
//-------------------------
//
// (Required) length value, in meters
//
@property (readwrite, nonatomic, retain) HVPositiveDouble* value;
//
// (Optional) Length data - exactly as entered by the user - before converting to standard units
//
@property (readwrite, nonatomic, retain) HVDisplayValue* display;

//
// Convenience properties
//
@property (readwrite, nonatomic) double inMeters;
@property (readwrite, nonatomic) double inCentimeters;
@property (readwrite, nonatomic) double inKilometers;
@property (readwrite, nonatomic) double inInches;
@property (readwrite, nonatomic) double inFeet;
@property (readwrite, nonatomic) double inMiles;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithInches:(double) inches;
-(id) initWithMeters:(double) meters;

//-------------------------
//
// Methods
//
//-------------------------
//
// Vocabulary for Units & codes: distance-units
//
-(BOOL) updateDisplayValue:(double) displayValue units:(NSString *) unitValue andUnitsCode:(NSString *)code;

+(double) centimetersToInches:(double) cm;
+(double) inchesToCentimeters:(double) cm;
+(double) metersToInches:(double) meters;
+(double) inchesToMeters:(double) inches;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

//
// These methods expect a string in format @%f...[you can set your own precision]
//
-(NSString *) stringInCentimeters:(NSString *) format;
-(NSString *) stringInMeters:(NSString *) format;
-(NSString *) stringInKilometers:(NSString *) format;
-(NSString *) stringInInches:(NSString *) format;
//
// Feet/Inches are rounded, so pass in a string with %@d...
//
-(NSString *) stringInFeetAndInches:(NSString *) format;
-(NSString *) stringInMiles:(NSString *) format;

+(HVLengthMeasurement *) fromMiles:(double) value;
+(HVLengthMeasurement *) fromInches:(double) value;
+(HVLengthMeasurement *) fromKilometers:(double) value;
+(HVLengthMeasurement *) fromMeters:(double) value;
+(HVLengthMeasurement *) fromCentimeters:(double) value;

@end
