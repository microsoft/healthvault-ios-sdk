//
//  ItemDataTyped.m
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
#import "HVItemDataTyped.h"
#import "HVItemTypes.h"

@implementation HVItemDataTyped

-(NSString *)type
{
    return [[self class] typeID];
}

-(NSString *) rootElement
{
    return [[self class] XRootElement];
}

-(BOOL)hasRawData
{
    return FALSE;
}

-(BOOL)isSingleton
{
    return [[self class] isSingletonType];
}

-(NSDate *)getDate
{
    return nil;
}

+(NSString *) typeID
{
    return c_emptyString;    
}

+(NSString *) XRootElement
{
    return c_emptyString;
}

-(NSString *)typeName
{
    return c_emptyString;
}

+(BOOL)isSingletonType
{
    return FALSE;
}

@end


static HVTypeSystem* s_typeRegistry;

@implementation HVTypeSystem

+(void) initialize
{
    s_typeRegistry = [[HVTypeSystem alloc] init];

    [s_typeRegistry addClass:[HVWeight class] forTypeID:[HVWeight typeID]];
    [s_typeRegistry addClass:[HVBloodPressure class] forTypeID:[HVBloodPressure typeID]];
    [s_typeRegistry addClass:[HVCholesterol class] forTypeID:[HVCholesterol typeID]];
    [s_typeRegistry addClass:[HVCholesterolV2 class] forTypeID:[HVCholesterolV2 typeID]];
    [s_typeRegistry addClass:[HVBloodGlucose class] forTypeID:[HVBloodGlucose typeID]];
    [s_typeRegistry addClass:[HVHeight class] forTypeID:[HVHeight typeID]];
    [s_typeRegistry addClass:[HVExercise class] forTypeID:[HVExercise typeID]];
    [s_typeRegistry addClass:[HVDailyMedicationUsage class] forTypeID:[HVDailyMedicationUsage typeID]];
    [s_typeRegistry addClass:[HVEmotionalState class] forTypeID:[HVEmotionalState typeID]];
    [s_typeRegistry addClass:[HVDailyDietaryIntake class] forTypeID:[HVDailyDietaryIntake typeID]]; 
    [s_typeRegistry addClass:[HVDietaryIntake class] forTypeID:[HVDietaryIntake typeID]]; 
    [s_typeRegistry addClass:[HVSleepJournalAM class] forTypeID:[HVSleepJournalAM typeID]];
    [s_typeRegistry addClass:[HVSleepJournalPM class] forTypeID:[HVSleepJournalPM typeID]];

    [s_typeRegistry addClass:[HVAllergy class] forTypeID:[HVAllergy typeID]];
    [s_typeRegistry addClass:[HVCondition class] forTypeID:[HVCondition typeID]];
    [s_typeRegistry addClass:[HVMedication class] forTypeID:[HVMedication typeID]];    
    [s_typeRegistry addClass:[HVImmunization class] forTypeID:[HVImmunization typeID]];   
    [s_typeRegistry addClass:[HVProcedure class] forTypeID:[HVProcedure typeID]];
    [s_typeRegistry addClass:[HVVitalSigns class] forTypeID:[HVVitalSigns typeID]];
    [s_typeRegistry addClass:[HVEncounter class] forTypeID:[HVEncounter typeID]];
    [s_typeRegistry addClass:[HVFamilyHistory class] forTypeID:[HVFamilyHistory typeID]];
    [s_typeRegistry addClass:[HVCCD class] forTypeID:[HVCCD typeID]];
    [s_typeRegistry addClass:[HVCCR class] forTypeID:[HVCCR typeID]];
    [s_typeRegistry addClass:[HVInsurance class] forTypeID:[HVInsurance typeID]];

    [s_typeRegistry addClass:[HVEmergencyOrProviderContact class] forTypeID:[HVEmergencyOrProviderContact typeID]];
    [s_typeRegistry addClass:[HVPersonalContactInfo class] forTypeID:[HVPersonalContactInfo typeID]];
    [s_typeRegistry addClass:[HVBasicDemographics class] forTypeID:[HVBasicDemographics typeID]];
    [s_typeRegistry addClass:[HVPersonalDemographics class] forTypeID:[HVPersonalDemographics typeID]];
    [s_typeRegistry addClass:[HVPersonalImage class] forTypeID:[HVPersonalImage typeID]];
    
    [s_typeRegistry addClass:[HVAssessment class] forTypeID:[HVAssessment typeID]];
    [s_typeRegistry addClass:[HVQuestionAnswer class] forTypeID:[HVQuestionAnswer typeID]];

    [s_typeRegistry addClass:[HVFile class] forTypeID:[HVFile typeID]];
}

+(HVTypeSystem *) current
{
    return s_typeRegistry;
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_types = [[NSMutableDictionary alloc] init];
    m_ids = [[NSMutableDictionary alloc] init];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_types release];
    [super dealloc];
}

-(HVItemDataTyped *) newFromTypeID:(NSString *)typeID
{
    Class class = nil;
    if (typeID != nil)
    {
        class = [self getClassForTypeID:typeID];
    }
    
    if (class == nil)
    {
        return nil;
    }
    
    return [[class alloc] init];
}

-(Class) getClassForTypeID:(NSString *)type
{
    HVCHECK_STRING(type);
    
    @synchronized(m_types)
    {
        Class cls = [m_types objectForKey:type];
        if (!cls)
        {
            // Try forcing lower case
            cls = [m_types objectForKey:[type lowercaseString]];
        }
        
        return cls;
    }
    
LError:
    return nil;
}

-(NSString *)getTypeIDForClassName:(NSString *) name
{
    return [m_ids objectForKey:name];
}

-(BOOL) addClass:(Class)class forTypeID:(NSString *)typeID
{
    HVCHECK_NOTNULL(typeID);
    HVCHECK_NOTNULL(class);
    
    @synchronized(m_types)
    {
        typeID = [typeID lowercaseString];
        
        [m_types setObject:class forKey:typeID];
        
        NSString* name = NSStringFromClass(class);
        [m_ids setObject:typeID forKey:name];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

@end