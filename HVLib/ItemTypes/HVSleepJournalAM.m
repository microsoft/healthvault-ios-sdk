//
//  HVMorningSleepJournal.m
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

#import "HVCommon.h"
#import "HVSleepJournalAM.h"

static NSString* const c_typeid = @"11c52484-7f1a-11db-aeac-87d355d89593";
static NSString* const c_typename = @"sleep-am";

static NSString* const c_element_when = @"when";
static NSString* const c_element_bedtime = @"bed-time";
static NSString* const c_element_waketime = @"wake-time";
static NSString* const c_element_sleepMins = @"sleep-minutes";
static NSString* const c_element_settlingMins = @"settling-minutes";
static NSString* const c_element_awakening = @"awakening";
static NSString* const c_element_medications = @"medications";
static NSString* const c_element_state = @"wake-state";

@implementation HVSleepJournalAM

@synthesize when = m_when;
@synthesize bedTime = m_bedTime;
@synthesize wakeTime = m_wakeTime;
@synthesize sleepMinutes = m_sleepMinutes;
@synthesize settlingMinutes = m_settlingMinutes;
@synthesize medicationsBeforeBed = m_medications;

-(enum HVWakeState)wakeState
{
    return (m_wakeState) ? (enum HVWakeState) (m_wakeState.value) : HVWakeState_Unknown;
}

-(void)setWakeState:(enum HVWakeState)wakeState
{
    if (wakeState == HVWakeState_Unknown)
    {
        HVCLEAR(m_wakeState);
    }
    else
    {
        HVENSURE(m_wakeState, HVPositiveInt);
        m_wakeState.value = (int) wakeState;
    }
}

-(HVOccurenceCollection *)awakenings
{
    HVENSURE(m_awakenings, HVOccurenceCollection);
    return m_awakenings;
}

-(void)setAwakenings:(HVOccurenceCollection *)awakenings
{
    HVRETAIN(m_awakenings, awakenings);
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
    HVENSURE(m_sleepMinutes, HVNonNegativeInt);
    m_sleepMinutes.value = sleepMinutesValue;
}

-(int)settlingMinutesValue
{
    return m_settlingMinutes ? m_settlingMinutes.value : -1;
}

-(void)setSettlingMinutesValue:(int)settlingMinutesValue
{
    HVENSURE(m_settlingMinutes, HVNonNegativeInt);
    m_settlingMinutes.value = settlingMinutesValue;
}

-(void)dealloc
{
    [m_when release];
    [m_bedTime release];
    [m_wakeTime release];
    [m_sleepMinutes release];
    [m_settlingMinutes release];
    [m_awakenings release];
    [m_medications release];
    [m_wakeState release];

    [super dealloc];
}

-(id)initWithBedtime:(NSDate *)bedtime onDate:(NSDate *)date settlingMinutes:(int)settlingMinutes sleepingMinutes:(int)sleepingMinutes wokeupAt:(NSDate *)wakeTime
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    m_bedTime = [[HVTime alloc] initWithDate:bedtime];
    HVCHECK_NOTNULL(m_bedTime);
    
    m_settlingMinutes = [[HVNonNegativeInt alloc] initWith:settlingMinutes];
    HVCHECK_NOTNULL(m_settlingMinutes);
    
    m_sleepMinutes = [[HVNonNegativeInt alloc] initWith:sleepingMinutes];
    HVCHECK_NOTNULL(m_sleepMinutes);
    
    m_wakeTime = [[HVTime alloc] initWithDate:wakeTime];
    HVCHECK_NOTNULL(m_wakeTime);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_bedTime, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_settlingMinutes, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_sleepMinutes, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_wakeTime, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_wakeState, HVClientError_InvalidSleepJournal);
    HVVALIDATE_ARRAYOPTIONAL(m_awakenings, HVClientError_InvalidSleepJournal);
    HVVALIDATE_OPTIONAL(m_medications);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_bedTime, c_element_bedtime);
    HVSERIALIZE(m_wakeTime, c_element_waketime);
    HVSERIALIZE(m_sleepMinutes, c_element_sleepMins);
    HVSERIALIZE(m_settlingMinutes, c_element_settlingMins);  
    HVSERIALIZE_ARRAY(m_awakenings, c_element_awakening);
    HVSERIALIZE(m_medications, c_element_medications);
    HVSERIALIZE(m_wakeState, c_element_state);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_bedTime, c_element_bedtime, HVTime);
    HVDESERIALIZE(m_wakeTime, c_element_waketime, HVTime);
    HVDESERIALIZE(m_sleepMinutes, c_element_sleepMins, HVNonNegativeInt);
    HVDESERIALIZE(m_settlingMinutes, c_element_settlingMins, HVNonNegativeInt);  
    HVDESERIALIZE_TYPEDARRAY(m_awakenings, c_element_awakening, HVOccurence, HVOccurenceCollection);
    HVDESERIALIZE(m_medications, c_element_medications, HVCodableValue);
    HVDESERIALIZE(m_wakeState, c_element_state, HVPositiveInt);    
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
    return [[HVItem alloc] initWithType:[HVSleepJournalAM typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Sleep Journal", @"Daily sleep journal");
}

@end
