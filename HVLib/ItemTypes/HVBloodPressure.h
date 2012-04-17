//
//  HVBloodPressure.h
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

@interface HVBloodPressure : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVNonNegativeInt* m_systolic;
    HVNonNegativeInt* m_diastolic;
    HVNonNegativeInt* m_pulse;
    HVBool* m_heartbeat;
}

//
// Required
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVNonNegativeInt* systolic;
@property (readwrite, nonatomic, retain) HVNonNegativeInt* diastolic;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVNonNegativeInt* pulse;
@property (readwrite, nonatomic, retain) HVBool *irregularHeartbeat;
//
// Convenience properties
//
@property (readwrite, nonatomic) int systolicValue;
@property (readwrite, nonatomic) int diastolicValue;
@property (readwrite, nonatomic) int pulseValue;


-(id) initWithSystolic:(int) sVal diastolic:(int) dVal;
-(id) initWithSystolic:(int) sVal diastolic:(int) dVal andDate:(NSDate*) date;
-(id) initWithSystolic:(int) sVal diastolic:(int) dVal pulse:(int) pVal;

//
// Generates string for systolic OVER diastolic
//
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
