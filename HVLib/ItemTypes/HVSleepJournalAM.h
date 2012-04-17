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

//
// Required
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVTime* bedTime;
@property (readwrite, nonatomic, retain) HVTime* wakeTime;
@property (readwrite, nonatomic, retain) HVNonNegativeInt* sleepMinutes;
@property (readwrite, nonatomic, retain) HVNonNegativeInt* settlingMinutes;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVOccurenceCollection* awakenings;
@property (readwrite, nonatomic, retain) HVCodableValue* medicationsBeforeBed;
@property (readwrite, nonatomic) enum HVWakeState wakeState;

@property (readonly, nonatomic) BOOL hasAwakenings;

-(id)initWithBedtime:(NSDate *)bedtime onDate :(NSDate *)date settlingMinutes:(int) settlingMinutes sleepingMinutes:(int) sleepingMinutes wokeupAt:(NSDate *) wakeTime;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
