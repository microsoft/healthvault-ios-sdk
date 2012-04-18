//
//  HVHeight.h
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

@interface HVHeight : HVItemDataTyped
{
    HVDateTime* m_when;
    HVLengthMeasurement* m_height;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) When the measurement was taken
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
//
// (Required) Length measurement (meters)
// You can also use the convenience inMeters/inInches properties
//
@property (readwrite, nonatomic, retain) HVLengthMeasurement* value;
//
// Convenience properties
//
@property (readwrite, nonatomic) double inMeters;
@property (readwrite, nonatomic) double inInches;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithInches:(double) inches andDate:(NSDate *) date;
-(id) initWithMeters:(double) meters andDate:(NSDate *) date;
+(HVItem *) newItem;

//-------------------------
//
// Text
// These methods expect a format string containing a single %f
//
//-------------------------
-(NSString *) stringInMeters:(NSString *) format;
-(NSString *) stringInInches:(NSString *) format;
-(NSString *) stringInFeetAndInches:(NSString *) format;
-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

@end
