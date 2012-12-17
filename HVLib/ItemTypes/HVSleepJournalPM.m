//
//  HVSleepJournalPM.m
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

#import "HVCommon.h"
#import "HVSleepJournalPM.h"

static NSString* const c_typeid = @"031f5706-7f1a-11db-ad56-7bd355d89593";
static NSString* const c_typename = @"sleep-pm";

static NSString* const c_element_when = @"when";
static NSString* const c_element_caffeine = @"caffeine";
static NSString* const c_element_alcohol = @"alcohol";
static NSString* const c_element_nap = @"nap";
static NSString* const c_element_exercise = @"exercise";
static NSString* const c_element_sleepiness = @"sleepiness";

NSString* stringFromSleepiness(enum HVSleepiness sleepiness)
{
    switch (sleepiness)
    {
        case HVSleepiness_VerySleepy:
            return @"Very Sleepy";
        
        case HVSleepiness_Tired:
            return @"Tired";
            
        case HVSleepiness_Alert:
            return @"Alert";
        
        case HVSleepiness_WideAwake:
            return @"Wide Awake";
        
        default:
            break;
    }
    
    return c_emptyString;
}

@implementation HVSleepJournalPM

@synthesize when = m_when;

-(HVTimeCollection *)caffeineIntakeTimes
{
    HVENSURE(m_caffeine, HVTimeCollection);
    return m_caffeine;
}

-(void)setCaffeineIntakeTimes:(HVTimeCollection *)caffeineIntakeTimes
{
    HVRETAIN(m_caffeine, caffeineIntakeTimes);
}

-(BOOL)hasCaffeineIntakeTimes
{
    return ![NSArray isNilOrEmpty:m_caffeine];
}

-(HVTimeCollection *)alcoholIntakeTimes
{
    HVENSURE(m_alcohol, HVTimeCollection);
    return m_alcohol;
}

-(void)setAlcoholIntakeTimes:(HVTimeCollection *)alcoholIntakeTimes
{
    HVRETAIN(m_alcohol, alcoholIntakeTimes);
}

-(BOOL)hasAlcoholIntakeTimes
{
    return ![NSArray isNilOrEmpty:m_alcohol];
}

-(HVOccurenceCollection *)naps
{
    HVENSURE(m_naps, HVOccurenceCollection);
    return m_naps;
}

-(void)setNaps:(HVOccurenceCollection *)naps
{
    HVRETAIN(m_naps, naps);
}

-(BOOL)hasNaps
{
    return ![NSArray isNilOrEmpty:m_naps];
}

-(HVOccurenceCollection *)exercise
{
    HVENSURE(m_exercise, HVOccurenceCollection);
    return m_exercise;
}

-(void)setExercise:(HVOccurenceCollection *)exercise
{
    HVRETAIN(m_exercise, exercise);
}

-(BOOL)hasExercise
{
    return ![NSArray isNilOrEmpty:m_exercise];
}

-(enum HVSleepiness)sleepiness
{
    return (m_sleepiness) ? (enum HVSleepiness) (m_sleepiness.value) : HVSleepiness_Unknown;
}

-(void) setSleepiness:(enum HVSleepiness)sleepiness
{
    if (sleepiness == HVSleepiness_Unknown)
    {
        HVCLEAR(m_sleepiness);
    }
    else 
    {
        HVENSURE(m_sleepiness, HVPositiveInt);
        m_sleepiness.value = sleepiness;
    }
}

-(NSString *)sleepinessAsString
{
    return stringFromSleepiness(self.sleepiness);
}

-(void)dealloc
{
    [m_when release];
    [m_caffeine release];
    [m_alcohol release];
    [m_naps release];
    [m_exercise release];
    [m_sleepiness release];
    [super dealloc];
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_sleepiness, HVClientError_InvalidSleepJournal);
    
    HVVALIDATE_ARRAYOPTIONAL(m_caffeine, HVClientError_InvalidSleepJournal);
    HVVALIDATE_ARRAYOPTIONAL(m_alcohol, HVClientError_InvalidSleepJournal);
    HVVALIDATE_ARRAYOPTIONAL(m_naps, HVClientError_InvalidSleepJournal);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL 
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE_ARRAY(m_caffeine, c_element_caffeine);
    HVSERIALIZE_ARRAY(m_alcohol, c_element_alcohol);
    HVSERIALIZE_ARRAY(m_naps, c_element_nap);
    HVSERIALIZE_ARRAY(m_exercise, c_element_exercise);
    HVSERIALIZE(m_sleepiness, c_element_sleepiness);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE_TYPEDARRAY(m_caffeine, c_element_caffeine, HVTime, HVTimeCollection);
    HVDESERIALIZE_TYPEDARRAY(m_alcohol, c_element_alcohol, HVTime, HVTimeCollection);
    HVDESERIALIZE_TYPEDARRAY(m_naps, c_element_nap, HVOccurence, HVOccurenceCollection);
    HVDESERIALIZE_TYPEDARRAY(m_exercise, c_element_exercise, HVOccurence, HVOccurenceCollection);
    HVDESERIALIZE(m_sleepiness, c_element_sleepiness, HVPositiveInt);
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVSleepJournalPM typeID]];
}


@end
