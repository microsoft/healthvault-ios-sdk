//
//  MHVSleepJournalPM.m
//  MHVLib
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

#import "MHVCommon.h"
#import "MHVSleepJournalPM.h"

static NSString* const c_typeid = @"031f5706-7f1a-11db-ad56-7bd355d89593";
static NSString* const c_typename = @"sleep-pm";

static NSString* const c_element_when = @"when";
static NSString* const c_element_caffeine = @"caffeine";
static NSString* const c_element_alcohol = @"alcohol";
static NSString* const c_element_nap = @"nap";
static NSString* const c_element_exercise = @"exercise";
static NSString* const c_element_sleepiness = @"sleepiness";

NSString* stringFromSleepiness(enum MHVSleepiness sleepiness)
{
    switch (sleepiness)
    {
        case MHVSleepiness_VerySleepy:
            return @"Very Sleepy";
        
        case MHVSleepiness_Tired:
            return @"Tired";
            
        case MHVSleepiness_Alert:
            return @"Alert";
        
        case MHVSleepiness_WideAwake:
            return @"Wide Awake";
        
        default:
            break;
    }
    
    return c_emptyString;
}

@implementation MHVSleepJournalPM

@synthesize when = m_when;

-(MHVTimeCollection *)caffeineIntakeTimes
{
    MHVENSURE(m_caffeine, MHVTimeCollection);
    return m_caffeine;
}

-(void)setCaffeineIntakeTimes:(MHVTimeCollection *)caffeineIntakeTimes
{
    m_caffeine = caffeineIntakeTimes;
}

-(BOOL)hasCaffeineIntakeTimes
{
    return ![MHVCollection isNilOrEmpty:m_caffeine];
}

-(MHVTimeCollection *)alcoholIntakeTimes
{
    MHVENSURE(m_alcohol, MHVTimeCollection);
    return m_alcohol;
}

-(void)setAlcoholIntakeTimes:(MHVTimeCollection *)alcoholIntakeTimes
{
    m_alcohol = alcoholIntakeTimes;
}

-(BOOL)hasAlcoholIntakeTimes
{
    return ![MHVCollection isNilOrEmpty:m_alcohol];
}

-(MHVOccurenceCollection *)naps
{
    MHVENSURE(m_naps, MHVOccurenceCollection);
    return m_naps;
}

-(void)setNaps:(MHVOccurenceCollection *)naps
{
    m_naps = naps;
}

-(BOOL)hasNaps
{
    return ![MHVCollection isNilOrEmpty:m_naps];
}

-(MHVOccurenceCollection *)exercise
{
    MHVENSURE(m_exercise, MHVOccurenceCollection);
    return m_exercise;
}

-(void)setExercise:(MHVOccurenceCollection *)exercise
{
    m_exercise = exercise;
}

-(BOOL)hasExercise
{
    return ![MHVCollection isNilOrEmpty:m_exercise];
}

-(enum MHVSleepiness)sleepiness
{
    return (m_sleepiness) ? (enum MHVSleepiness) (m_sleepiness.value) : MHVSleepiness_Unknown;
}

-(void) setSleepiness:(enum MHVSleepiness)sleepiness
{
    if (sleepiness == MHVSleepiness_Unknown)
    {
        m_sleepiness = nil;
    }
    else 
    {
        MHVENSURE(m_sleepiness, MHVPositiveInt);
        m_sleepiness.value = sleepiness;
    }
}

-(NSString *)sleepinessAsString
{
    return stringFromSleepiness(self.sleepiness);
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_when, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE(m_sleepiness, MHVClientError_InvalidSleepJournal);
    
    MHVVALIDATE_ARRAYOPTIONAL(m_caffeine, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE_ARRAYOPTIONAL(m_alcohol, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE_ARRAYOPTIONAL(m_naps, MHVClientError_InvalidSleepJournal);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElementArray:c_element_caffeine elements:m_caffeine.toArray];
    [writer writeElementArray:c_element_alcohol elements:m_alcohol.toArray];
    [writer writeElementArray:c_element_nap elements:m_naps.toArray];
    [writer writeElementArray:c_element_exercise elements:m_exercise.toArray];
    [writer writeElement:c_element_sleepiness content:m_sleepiness];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVDateTime class]];
    m_caffeine = (MHVTimeCollection *)[reader readElementArray:c_element_caffeine asClass:[MHVTime class] andArrayClass:[MHVTimeCollection class]];
    m_alcohol = (MHVTimeCollection *)[reader readElementArray:c_element_alcohol asClass:[MHVTime class] andArrayClass:[MHVTimeCollection class]];
    m_naps = (MHVOccurenceCollection *)[reader readElementArray:c_element_nap asClass:[MHVOccurence class] andArrayClass:[MHVOccurenceCollection class]];
    m_exercise = (MHVOccurenceCollection *)[reader readElementArray:c_element_exercise asClass:[MHVOccurence class] andArrayClass:[MHVOccurenceCollection class]];
    m_sleepiness = [reader readElement:c_element_sleepiness asClass:[MHVPositiveInt class]];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVSleepJournalPM typeID]];
}


@end
