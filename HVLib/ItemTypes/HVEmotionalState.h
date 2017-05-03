//
//  HVEmotionalState.h
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

enum HVMood 
{
    HVMoodUnknown = 0,
    HVMoodDepressed,
    HVMoodSad,
    HVMoodNeutral,
    HVMoodHappy,
    HVMoodElated
};

NSString* stringFromMood(enum HVMood mood);

enum HVWellBeing 
{
    HVWellBeingUnknown = 0,
    HVWellBeingSick,
    HVWellBeingImpaired,
    HVWellBeingAble,
    HVWellBeingHealthy,
    HVWellBeingVigorous
};

NSString* stringFromWellBeing(enum HVWellBeing wellBeing);

@interface HVEmotionalState : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVOneToFive* m_mood;
    HVOneToFive* m_stress;
    HVOneToFive* m_wellbeing;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Optional) Emotional state this THIS time
//
@property (readwrite, nonatomic, strong) HVDateTime* when;
//
// (Optional) Mood rating - happy, depressed, sad..
//
@property (readwrite, nonatomic) enum HVMood mood;
//
// (Optional) A relative stress level
//
@property (readwrite, nonatomic) enum HVRelativeRating stress;
//
// (Optional) Sick, Healthy etc
//
@property (readwrite, nonatomic) enum HVWellBeing wellbeing;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) moodAsString;
-(NSString *) stressAsString;
-(NSString *) wellBeingAsString;

-(NSString *) toString;
// @Mood @Stress @WellBeing
-(NSString *) toStringWithFormat:(NSString *) format;

//-------------------------
//
// Type Info
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
