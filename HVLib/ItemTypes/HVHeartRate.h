//
//  HVBloodPressure.h
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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

@interface HVHeartRate : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVNonNegativeInt* m_bpm;
    HVCodableValue* m_measurementMethod;
    HVCodableValue* m_measurementConditions;
    HVCodableValue* m_measurementFlags;
}

//
// (Required) - When the measurement was made
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
//
// (Required) - Heart rate in beats per minute
//
@property (readwrite, nonatomic, retain) HVNonNegativeInt* bpm;

@property (readwrite, nonatomic, retain) HVCodableValue* measurementMethod;
@property (readwrite, nonatomic, retain) HVCodableValue* measurementConditions;
@property (readwrite, nonatomic, retain) HVCodableValue* measurementFlags;

//
// Convenience properties
//
@property (readwrite, nonatomic) int bpmValue;


//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithBpm:(int) bpm andDate:(NSDate*) date;

+(HVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
//
// Takes a format string with %@ in it, surrounded with other decorative text of your choice
//
-(NSString *) toStringWithFormat:(NSString *) format;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
