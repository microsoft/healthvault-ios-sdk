//
//  HVSleepJournal.h
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

enum HVWakeState 
{
    HVWakeState_Unknown = 0,
    HVWakeState_WideAwake = 1,
    HVWakeState_Awake,
    HVWakeState_Sleepy
};

//-------------------------
//
// Journal entries you make when you wake up in the morning
//
//-------------------------
@interface HVSleepJournalAM : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVTime* m_bedTime;
    HVTime* m_wakeTime;
    HVNonNegativeInt* m_sleepMinutes;
    HVNonNegativeInt* m_settlingMinutes;
    HVOccurenceCollection* m_awakenings;
    HVCodableValue* m_medications;
    HVPositiveInt* m_wakeState;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - Journal Entry is for this date/time
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
//
// (Required) - time you went to bed
//
@property (readwrite, nonatomic, retain) HVTime* bedTime;
//
// (Required) - time you finally woke up and got out of bed
//
@property (readwrite, nonatomic, retain) HVTime* wakeTime;
//
// (Required) - how long you slept for
//
@property (readwrite, nonatomic, retain) HVNonNegativeInt* sleepMinutes;
//
// (Required) - how long it took you to fall asleep
//
@property (readwrite, nonatomic, retain) HVNonNegativeInt* settlingMinutes;
//
// (Required) - how you felt when you woke up
//
@property (readwrite, nonatomic) enum HVWakeState wakeState;
//
// (Optional) - how many times you woke up or had your sleep interrupted
//
@property (readwrite, nonatomic, retain) HVOccurenceCollection* awakenings;
//
// (Optional) - medications you took before going to bed
//
@property (readwrite, nonatomic, retain) HVCodableValue* medicationsBeforeBed;

//
// Convenience
//
@property (readonly, nonatomic) BOOL hasAwakenings;
@property (readwrite, nonatomic) int sleepMinutesValue;
@property (readwrite, nonatomic) int settlingMinutesValue;

//-------------------------
//
// Initializers
//
//-------------------------

-(id)initWithBedtime:(NSDate *)bedtime onDate :(NSDate *)date settlingMinutes:(int) settlingMinutes sleepingMinutes:(int) sleepingMinutes wokeupAt:(NSDate *) wakeTime;

+(HVItem *) newItem;

//-------------------------
//
// Type info
//
//-------------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

@end
