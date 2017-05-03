//
//  HVDailyMedicationUsage.h
//  HVLib
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
#import "HVTypes.h"

@interface HVDailyMedicationUsage : HVItemDataTyped
{
@private
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

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) The day when the medication was consumed
//
@property (readwrite, nonatomic, strong) HVDate* when;
//
// (Required) The drug/substance/supplement used
// Vocabulary: RxNorm
//
@property (readwrite, nonatomic, strong) HVCodableValue* drugName;
//
// (Required) number of doses. 
// 
@property (readwrite, nonatomic, strong) HVInt* dosesConsumed;
//
// (Optional) why the medication was taken
//
@property (readwrite, nonatomic, strong) HVCodableValue* purpose;
//
// (Optional) How many doses were meant to be taken 
//
@property (readwrite, nonatomic, strong) HVInt* dosesIntended;
//
// All Optional
//
@property (readwrite, nonatomic, strong) HVCodableValue* usageSchedule;
@property (readwrite, nonatomic, strong) HVCodableValue* drugForm;
@property (readwrite, nonatomic, strong) HVCodableValue* prescriptionType;
@property (readwrite, nonatomic, strong) HVCodableValue* singleDoseDescription;

//
// Convenience
//
@property (readwrite, nonatomic) int dosesConsumedValue;
@property (readwrite, nonatomic) int dosesIntendedValue;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithDoses:(int) doses forDrug:(HVCodableValue *) drug onDay:(NSDate *) day;
-(id) initWithDoses:(int)doses forDrug:(HVCodableValue *)drug onDate:(HVDate *)date;

+(HVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

//-------------------------
//
// Type Info
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
