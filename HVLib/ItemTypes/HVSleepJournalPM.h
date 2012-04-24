//
//  HVSleepJournalPM.h
//  HVLib
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

enum HVSleepiness
{
    HVSleepiness_Unknown,
    HVSleepiness_VerySleepy,
    HVSleepiness_Tired,
    HVSleepiness_Alert,
    HVSleepiness_WideAwake
};

NSString* stringFromSleepiness(enum HVSleepiness sleepiness);

@interface HVSleepJournalPM : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVTimeCollection* m_caffeine;
    HVTimeCollection* m_alcohol;
    HVOccurenceCollection* m_naps;
    HVOccurenceCollection* m_exercise;
    HVPositiveInt* m_sleepiness;
}

//-------------------------
//
// Data
//
//-------------------------
///
// Required
//
@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic) enum HVSleepiness sleepiness;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVTimeCollection* caffeineIntakeTimes;
@property (readwrite, nonatomic, retain) HVTimeCollection* alcoholIntakeTimes;
@property (readwrite, nonatomic, retain) HVOccurenceCollection* naps;
@property (readwrite, nonatomic, retain) HVOccurenceCollection* exercise;

@property (readonly, nonatomic) BOOL hasCaffeineIntakeTimes;
@property (readonly, nonatomic) BOOL hasAlcoholIntakeTimes;
@property (readonly, nonatomic) BOOL hasNaps;
@property (readonly, nonatomic) BOOL hasExercise;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;

-(NSString *) sleepinessAsString;

//-------------------------
//
// Type info
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
