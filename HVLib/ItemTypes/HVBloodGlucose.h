//
//  HVBloodGlucose.h
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

@interface HVBloodGlucose : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVBloodGlucoseMeasurement* m_value;
    HVCodableValue* m_measurementType;
    HVBool* m_outsideOperatingTemp;
    HVBool* m_controlTest;
    HVOneToFive* m_normalcy;
    HVCodableValue* m_context;
}
//
// Required
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVBloodGlucoseMeasurement* value;
@property (readwrite, nonatomic, retain) HVCodableValue* measurementType;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVBool* isOutsideOperatingTemp;
@property (readwrite, nonatomic, retain) HVBool* isControlTest;
@property (readwrite, nonatomic) enum HVRelativeRating normalcy;
@property (readwrite, nonatomic, retain) HVCodableValue* context;

@property (readwrite, nonatomic) double inMmolPerLiter;
@property (readwrite, nonatomic) double inMgPerDL;

-(id) initWithMmolPerLiter:(double) value andDate:(NSDate *) date;

-(NSString *) stringInMmolPerLiter:(NSString *) format;
-(NSString *) stringInMgPerDL:(NSString *) format;
-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
