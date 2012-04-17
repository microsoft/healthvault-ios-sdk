//
//  HVDailyMedicationUsage.h
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

@interface HVDailyMedicationUsage : HVItemDataTyped
{
    HVDate* m_when;
    HVCodableValue* m_drugName;
    HVInt* m_dosesConsumed;
    HVCodableValue* m_purpose;
    HVInt* m_dosesIntended;
    HVCodableValue* m_usageSchedule;
    HVCodableValue* m_drugForm;
    HVCodableValue* m_prescriptionType;
    HVCodableValue* m_singleDoseDescription;
}

@property (readwrite, nonatomic, retain) HVDate* when;
@property (readwrite, nonatomic, retain) HVCodableValue* drugName;
@property (readwrite, nonatomic, retain) HVInt* dosesConsumed;
@property (readwrite, nonatomic, retain) HVCodableValue* purpose;
@property (readwrite, nonatomic, retain) HVInt* dosesIntended;
@property (readwrite, nonatomic, retain) HVCodableValue* usageSchedule;
@property (readwrite, nonatomic, retain) HVCodableValue* drugForm;
@property (readwrite, nonatomic, retain) HVCodableValue* prescriptionType;
@property (readwrite, nonatomic, retain) HVCodableValue* singleDoseDescription;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
