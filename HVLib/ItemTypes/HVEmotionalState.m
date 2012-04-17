//
//  HVEmotionalState.m
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
#import "HVEmotionalState.h"

static NSString* const c_typeid = @"4b7971d6-e427-427d-bf2c-2fbcf76606b3";
static NSString* const c_typename = @"emotion";

static NSString* const c_element_when = @"when";
static NSString* const c_element_mood = @"mood";
static NSString* const c_element_stress = @"stress";
static NSString* const c_element_wellbeing = @"wellbeing";

@implementation HVEmotionalState

@synthesize when = m_when;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(enum HVMood)mood
{
    return (m_mood) ? (enum HVMood) m_mood.value : HVMood_Unknown;
}

-(void)setMood:(enum HVMood)mood
{
    if (mood == HVMood_Unknown)
    {
        HVCLEAR(m_mood);
    }
    else
    {
        HVENSURE(m_mood, HVOneToFive);
        m_mood.value = (int) mood;
    }
}


-(enum HVRelativeRating)stress
{
    return (m_stress) ? (enum HVRelativeRating) m_mood.value : HVRelativeRating_None;
}

-(void)setStress:(enum HVRelativeRating)stress
{
    if (stress == HVRelativeRating_None)
    {
        HVCLEAR(m_stress);
    }
    else
    {
        HVENSURE(m_stress, HVOneToFive);
        m_stress.value = (int) stress;
    }
}

-(enum HVWellBeing)wellbeing
{
    return (m_wellbeing) ? (enum HVWellBeing) m_wellbeing.value : HVWellBeing_Unknown;    
}

-(void)setWellbeing:(enum HVWellBeing)wellbeing
{
    if (wellbeing == HVWellBeing_Unknown)
    {
        HVCLEAR(m_wellbeing);
    }
    else
    {
        HVENSURE(m_wellbeing, HVOneToFive);
        m_wellbeing.value = (int) wellbeing;
    }    
}

-(void)dealloc
{
    [m_when release];
    [m_mood release];
    [m_stress release];
    [m_wellbeing release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_OPTIONAL(m_mood);
    HVVALIDATE_OPTIONAL(m_stress);
    HVVALIDATE_OPTIONAL(m_wellbeing);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_mood, c_element_mood);
    HVSERIALIZE(m_stress, c_element_stress);
    HVSERIALIZE(m_wellbeing, c_element_wellbeing);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_mood, c_element_mood, HVOneToFive);
    HVDESERIALIZE(m_stress, c_element_stress, HVOneToFive);
    HVDESERIALIZE(m_wellbeing, c_element_wellbeing, HVOneToFive);    
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
    return [[HVItem alloc] initWithType:[HVEmotionalState typeID]];
}

@end
