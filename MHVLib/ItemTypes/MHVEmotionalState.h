//
//  MHVEmotionalState.h
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

enum MHVMood 
{
    MHVMoodUnknown = 0,
    MHVMoodDepressed,
    MHVMoodSad,
    MHVMoodNeutral,
    MHVMoodHappy,
    MHVMoodElated
};

NSString* stringFromMood(enum MHVMood mood);

enum MHVWellBeing 
{
    MHVWellBeingUnknown = 0,
    MHVWellBeingSick,
    MHVWellBeingImpaired,
    MHVWellBeingAble,
    MHVWellBeingHealthy,
    MHVWellBeingVigorous
};

NSString* stringFromWellBeing(enum MHVWellBeing wellBeing);

@interface MHVEmotionalState : MHVItemDataTyped
{
@private
    MHVDateTime* m_when;
    MHVOneToFive* m_mood;
    MHVOneToFive* m_stress;
    MHVOneToFive* m_wellbeing;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Optional) Emotional state this THIS time
//
@property (readwrite, nonatomic, strong) MHVDateTime* when;
//
// (Optional) Mood rating - happy, depressed, sad..
//
@property (readwrite, nonatomic) enum MHVMood mood;
//
// (Optional) A relative stress level
//
@property (readwrite, nonatomic) enum MHVRelativeRating stress;
//
// (Optional) Sick, Healthy etc
//
@property (readwrite, nonatomic) enum MHVWellBeing wellbeing;

//-------------------------
//
// Initializers
//
//-------------------------
+(MHVItem *) newItem;

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
