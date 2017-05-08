//
//  MHVEmotionalState.m
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
#import "MHVEmotionalState.h"


NSString* stringFromMood(enum MHVMood mood)
{
    switch (mood) 
    {
        case MHVMoodDepressed:
            return @"Depressed";
        
        case MHVMoodSad:
            return @"Sad";
        
        case MHVMoodNeutral:
            return @"Neutral";
        
        case MHVMoodHappy:
            return @"Happy";
        
        case MHVMoodElated:
            return @"Elated";
            
        default:
            break;
    }
    
    return c_emptyString;
}

NSString* stringFromWellBeing(enum MHVWellBeing wellBeing)
{
    switch (wellBeing) 
    {
        case MHVWellBeingSick:
            return @"Sick";
        
        case MHVWellBeingImpaired:
            return @"Impaired";
        
        case MHVWellBeingAble:
            return @"Able";
        
        case MHVWellBeingHealthy:
            return @"Healthy";
        
        case MHVWellBeingVigorous:
            return @"Vigorous";
            
        default:
            break;
    }
    
    return c_emptyString;
}

static NSString* const c_typeid = @"4b7971d6-e427-427d-bf2c-2fbcf76606b3";
static NSString* const c_typename = @"emotion";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_mood = XMLSTRINGCONST("mood");
static const xmlChar* x_element_stress = XMLSTRINGCONST("stress");
static const xmlChar* x_element_wellbeing = XMLSTRINGCONST("wellbeing");

@implementation MHVEmotionalState

@synthesize when = m_when;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(enum MHVMood)mood
{
    return (m_mood) ? (enum MHVMood) m_mood.value : MHVMoodUnknown;
}

-(void)setMood:(enum MHVMood)mood
{
    if (mood == MHVMoodUnknown)
    {
        m_mood = nil;
    }
    else
    {
        MHVENSURE(m_mood, MHVOneToFive);
        m_mood.value = (int) mood;
    }
}


-(enum MHVRelativeRating)stress
{
    return (m_stress) ? (enum MHVRelativeRating) m_stress.value : MHVRelativeRating_None;
}

-(void)setStress:(enum MHVRelativeRating)stress
{
    if (stress == MHVRelativeRating_None)
    {
        m_stress = nil;
    }
    else
    {
        MHVENSURE(m_stress, MHVOneToFive);
        m_stress.value = (int) stress;
    }
}

-(enum MHVWellBeing)wellbeing
{
    return (m_wellbeing) ? (enum MHVWellBeing) m_wellbeing.value : MHVWellBeingUnknown;    
}

-(void)setWellbeing:(enum MHVWellBeing)wellbeing
{
    if (wellbeing == MHVWellBeingUnknown)
    {
        m_wellbeing = nil;
    }
    else
    {
        MHVENSURE(m_wellbeing, MHVOneToFive);
        m_wellbeing.value = (int) wellbeing;
    }    
}


-(NSString *)moodAsString
{
    return stringFromMood(self.mood);
}

-(NSString *)wellBeingAsString
{
    return stringFromWellBeing(self.wellbeing);
}

-(NSString *)stressAsString
{
    return stringFromRating(self.stress);
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [self toStringWithFormat:@"Mood=%@, Stress=%@, Wellbeing=%@"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, [self moodAsString], [self stressAsString], [self wellBeingAsString]];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_when);
    MHVVALIDATE_OPTIONAL(m_mood);
    MHVVALIDATE_OPTIONAL(m_stress);
    MHVVALIDATE_OPTIONAL(m_wellbeing);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_mood content:m_mood];
    [writer writeElementXmlName:x_element_stress content:m_stress];
    [writer writeElementXmlName:x_element_wellbeing content:m_wellbeing];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDateTime class]];
    m_mood = [reader readElementWithXmlName:x_element_mood asClass:[MHVOneToFive class]];
    m_stress = [reader readElementWithXmlName:x_element_stress asClass:[MHVOneToFive class]];
    m_wellbeing = [reader readElementWithXmlName:x_element_wellbeing asClass:[MHVOneToFive class]];
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
    return [[MHVItem alloc] initWithType:[MHVEmotionalState typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Emotional state", @"Emotional state Type Name");
}

@end
