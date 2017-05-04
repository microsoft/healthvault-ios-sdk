//
//  MHVMorningSleepJournal.m
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

#import "MHVCommon.h"
#import "MHVSleepJournalAM.h"

static NSString* const c_typeid = @"11c52484-7f1a-11db-aeac-87d355d89593";
static NSString* const c_typename = @"sleep-am";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_bedtime = XMLSTRINGCONST("bed-time");
static const xmlChar* x_element_waketime = XMLSTRINGCONST("wake-time");
static const xmlChar* x_element_sleepMins = XMLSTRINGCONST("sleep-minutes");
static const xmlChar* x_element_settlingMins = XMLSTRINGCONST("settling-minutes");
static NSString* const c_element_awakening = @"awakening";
static const xmlChar* x_element_medications = XMLSTRINGCONST("medications");
static const xmlChar* x_element_state = XMLSTRINGCONST("wake-state");

@implementation MHVSleepJournalAM

@synthesize when = m_when;
@synthesize bedTime = m_bedTime;
@synthesize wakeTime = m_wakeTime;
@synthesize sleepMinutes = m_sleepMinutes;
@synthesize settlingMinutes = m_settlingMinutes;
@synthesize medicationsBeforeBed = m_medications;

-(enum MHVWakeState)wakeState
{
    return (m_wakeState) ? (enum MHVWakeState) (m_wakeState.value) : MHVWakeState_Unknown;
}

-(void)setWakeState:(enum MHVWakeState)wakeState
{
    if (wakeState == MHVWakeState_Unknown)
    {
        m_wakeState = nil;
    }
    else
    {
        MHVENSURE(m_wakeState, MHVPositiveInt);
        m_wakeState.value = (int) wakeState;
    }
}

-(MHVOccurenceCollection *)awakenings
{
    MHVENSURE(m_awakenings, MHVOccurenceCollection);
    return m_awakenings;
}

-(void)setAwakenings:(MHVOccurenceCollection *)awakenings
{
    m_awakenings = awakenings;
}

-(BOOL)hasAwakenings
{
    return ![NSArray isNilOrEmpty:m_awakenings];
}

-(int)sleepMinutesValue
{
    return (m_sleepMinutes) ? m_sleepMinutes.value : -1;
}

-(void)setSleepMinutesValue:(int)sleepMinutesValue
{
    MHVENSURE(m_sleepMinutes, MHVNonNegativeInt);
    m_sleepMinutes.value = sleepMinutesValue;
}

-(int)settlingMinutesValue
{
    return m_settlingMinutes ? m_settlingMinutes.value : -1;
}

-(void)setSettlingMinutesValue:(int)settlingMinutesValue
{
    MHVENSURE(m_settlingMinutes, MHVNonNegativeInt);
    m_settlingMinutes.value = settlingMinutesValue;
}


-(id)initWithBedtime:(NSDate *)bedtime onDate:(NSDate *)date settlingMinutes:(int)settlingMinutes sleepingMinutes:(int)sleepingMinutes wokeupAt:(NSDate *)wakeTime
{
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(m_when);
    
    m_bedTime = [[MHVTime alloc] initWithDate:bedtime];
    MHVCHECK_NOTNULL(m_bedTime);
    
    m_settlingMinutes = [[MHVNonNegativeInt alloc] initWith:settlingMinutes];
    MHVCHECK_NOTNULL(m_settlingMinutes);
    
    m_sleepMinutes = [[MHVNonNegativeInt alloc] initWith:sleepingMinutes];
    MHVCHECK_NOTNULL(m_sleepMinutes);
    
    m_wakeTime = [[MHVTime alloc] initWithDate:wakeTime];
    MHVCHECK_NOTNULL(m_wakeTime);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
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
    MHVVALIDATE(m_bedTime, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE(m_settlingMinutes, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE(m_sleepMinutes, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE(m_wakeTime, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE(m_wakeState, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE_ARRAYOPTIONAL(m_awakenings, MHVClientError_InvalidSleepJournal);
    MHVVALIDATE_OPTIONAL(m_medications);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_bedtime content:m_bedTime];
    [writer writeElementXmlName:x_element_waketime content:m_wakeTime];
    [writer writeElementXmlName:x_element_sleepMins content:m_sleepMinutes];
    [writer writeElementXmlName:x_element_settlingMins content:m_settlingMinutes];
    [writer writeElementArray:c_element_awakening elements:m_awakenings];
    [writer writeElementXmlName:x_element_medications content:m_medications];
    [writer writeElementXmlName:x_element_state content:m_wakeState];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDateTime class]];
    m_bedTime = [reader readElementWithXmlName:x_element_bedtime asClass:[MHVTime class]];
    m_wakeTime = [reader readElementWithXmlName:x_element_waketime asClass:[MHVTime class]];
    m_sleepMinutes = [reader readElementWithXmlName:x_element_sleepMins asClass:[MHVNonNegativeInt class]];
    m_settlingMinutes = [reader readElementWithXmlName:x_element_settlingMins asClass:[MHVNonNegativeInt class]];
    m_awakenings = (MHVOccurenceCollection *)[reader readElementArray:c_element_awakening asClass:[MHVOccurence class] andArrayClass:[MHVOccurenceCollection class]];
    m_medications = [reader readElementWithXmlName:x_element_medications asClass:[MHVCodableValue class]];
    m_wakeState = [reader readElementWithXmlName:x_element_state asClass:[MHVPositiveInt class]];
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
    return [[MHVItem alloc] initWithType:[MHVSleepJournalAM typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Sleep Journal", @"Daily sleep journal");
}

@end
