//
//  MHVBloodPressure.h
//  MHVLib
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
#import "MHVTypes.h"

@interface MHVHeartRate : MHVItemDataTyped
{
@private
    MHVDateTime* m_when;
    MHVNonNegativeInt* m_bpm;
    MHVCodableValue* m_measurementMethod;
    MHVCodableValue* m_measurementConditions;
    MHVCodableValue* m_measurementFlags;
}

//
// (Required) - When the measurement was made
//
@property (readwrite, nonatomic, strong) MHVDateTime* when;
//
// (Required) - Heart rate in beats per minute
//
@property (readwrite, nonatomic, strong) MHVNonNegativeInt* bpm;

@property (readwrite, nonatomic, strong) MHVCodableValue* measurementMethod;
@property (readwrite, nonatomic, strong) MHVCodableValue* measurementConditions;
@property (readwrite, nonatomic, strong) MHVCodableValue* measurementFlags;

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

+(MHVItem *) newItem;

//-------------------------
//
// Methods
//
//-------------------------
+(MHVVocabIdentifier *) vocabForMeasurementMethod;
+(MHVVocabIdentifier *) vocabForMeasurementConditions;

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
