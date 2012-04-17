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

@interface HVLengthMeasurement : HVType
{
    HVPositiveDouble* m_meters;
    HVDisplayValue* m_display;    
}

@property (readwrite, nonatomic, retain) HVPositiveDouble* value;
@property (readwrite, nonatomic, retain) HVDisplayValue* display;

@property (readwrite, nonatomic) double meters;
@property (readwrite, nonatomic) double inches;

-(id) initWithInches:(double) inches;
-(id) initWithMeters:(double) meters;

-(BOOL) updateDisplayValue:(double) displayValue andUnits:(NSString *) unitValue;

-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

-(NSString *) stringInMeters:(NSString *) format;
-(NSString *) stringInInches:(NSString *) format;
-(NSString *) stringInFeetAndInches:(NSString *) format;

+(double) centimetersToInches:(double) cm;
+(double) inchesToCentimeters:(double) cm;
+(double) metersToInches:(double) meters;
+(double) inchesToMeters:(double) inches;

@end
