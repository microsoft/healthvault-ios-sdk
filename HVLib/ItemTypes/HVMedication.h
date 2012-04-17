//
//  HVMedication.h
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

@interface HVMedication : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVCodableValue* m_genericName;
    HVApproxMeasurement* m_dose;
    HVApproxMeasurement* m_strength;
    HVApproxMeasurement* m_freq;
    HVCodableValue* m_route;
    HVCodableValue* m_indication;
    HVApproxDateTime* m_startDate;
    HVApproxDateTime* m_stopDate;
    HVCodableValue* m_prescribed;
    HVPrescription* m_prescription;
}

@property (readwrite, nonatomic, retain) HVCodableValue* name;
@property (readwrite, nonatomic, retain) HVCodableValue* genericName;
@property (readwrite, nonatomic, retain) HVApproxMeasurement* dose;
@property (readwrite, nonatomic, retain) HVApproxMeasurement* strength;
@property (readwrite, nonatomic, retain) HVApproxMeasurement* frequency;
@property (readwrite, nonatomic, retain) HVCodableValue* route;
@property (readwrite, nonatomic, retain) HVCodableValue* indication;
@property (readwrite, nonatomic, retain) HVApproxDateTime* startDate;
@property (readwrite, nonatomic, retain) HVApproxDateTime* stopDate;
@property (readwrite, nonatomic, retain) HVCodableValue* prescribed;
@property (readwrite, nonatomic, retain) HVPrescription* prescription;

@property (readonly, nonatomic) HVPerson* prescriber;

-(id) initWithName:(NSString *) name;

-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
