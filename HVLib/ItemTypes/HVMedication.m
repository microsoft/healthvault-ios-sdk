//
//  HVMedication.m
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
#import "HVMedication.h"

static NSString* const c_typeid = @"30cafccc-047d-4288-94ef-643571f7919d";
static NSString* const c_typename = @"medication";

static NSString* const c_element_name = @"name";
static NSString* const c_element_genericName = @"generic-name";
static NSString* const c_element_dose = @"dose";
static NSString* const c_element_strength = @"strength";
static NSString* const c_element_frequency = @"frequency";
static NSString* const c_element_route = @"route";
static NSString* const c_element_indication = @"indication";
static NSString* const c_element_startDate = @"date-started";
static NSString* const c_element_stopDate = @"date-discontinued";
static NSString* const c_element_prescribed = @"prescribed";
static NSString* const c_element_prescription = @"prescription";

@implementation HVMedication

@synthesize name = m_name;
@synthesize genericName = m_genericName;
@synthesize dose = m_dose;
@synthesize strength = m_strength;
@synthesize frequency = m_freq;
@synthesize route = m_route;
@synthesize indication = m_indication;
@synthesize startDate = m_startDate;
@synthesize stopDate = m_stopDate;
@synthesize prescribed = m_prescribed;
@synthesize prescription = m_prescription;

-(HVPerson *)prescriber
{
    return (m_prescription) ? m_prescription.prescriber : nil;
}

-(id)initWithName:(NSString *)name
{
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[HVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_genericName release];
    [m_dose release];
    [m_strength release];
    [m_freq release];
    [m_route release];
    [m_indication release];
    [m_startDate release];
    [m_stopDate release];
    [m_prescribed release];
    [m_prescription release];
    
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

-(NSDate *)getDate
{
    return m_startDate ? [m_startDate toDate] : nil;
}

+(HVVocabIdentifier *) vocabForName
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_rxNormFamily andName:@"RxNorm Active Medicines"] autorelease];
}

+(HVVocabIdentifier *) vocabForDoseUnits
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-dose-units"] autorelease];
}

+(HVVocabIdentifier *)vocabForStrengthUnits
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-strength-unit"] autorelease];    
}

+(HVVocabIdentifier *)vocabForRoute
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-routes"] autorelease];
}

+(HVVocabIdentifier *)vocabForIsPrescribed
{    
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-prescribed"] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE(m_name, HVClientError_InvalidMedication);
    HVVALIDATE_OPTIONAL(m_genericName);
    HVVALIDATE_OPTIONAL(m_dose);
    HVVALIDATE_OPTIONAL(m_strength);
    HVVALIDATE_OPTIONAL(m_freq);
    HVVALIDATE_OPTIONAL(m_route);
    HVVALIDATE_OPTIONAL(m_indication);
    HVVALIDATE_OPTIONAL(m_startDate);
    HVVALIDATE_OPTIONAL(m_stopDate);
    HVVALIDATE_OPTIONAL(m_prescribed);
    HVVALIDATE_OPTIONAL(m_prescription);
    
    HVVALIDATE_SUCCESS
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_genericName, c_element_genericName);
    HVSERIALIZE(m_dose, c_element_dose);
    HVSERIALIZE(m_strength, c_element_strength);
    HVSERIALIZE(m_freq, c_element_frequency);
    HVSERIALIZE(m_route, c_element_route);
    HVSERIALIZE(m_indication, c_element_indication);
    HVSERIALIZE(m_startDate, c_element_startDate);
    HVSERIALIZE(m_stopDate, c_element_stopDate);
    HVSERIALIZE(m_prescribed, c_element_prescribed);
    HVSERIALIZE(m_prescription, c_element_prescription);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_genericName, c_element_genericName, HVCodableValue);
    HVDESERIALIZE(m_dose, c_element_dose, HVApproxMeasurement);
    HVDESERIALIZE(m_strength, c_element_strength, HVApproxMeasurement);
    HVDESERIALIZE(m_freq, c_element_frequency, HVApproxMeasurement);
    HVDESERIALIZE(m_route, c_element_route, HVCodableValue);
    HVDESERIALIZE(m_indication, c_element_indication, HVCodableValue);
    HVDESERIALIZE(m_startDate, c_element_startDate, HVApproxDateTime);
    HVDESERIALIZE(m_stopDate, c_element_stopDate, HVApproxDateTime);
    HVDESERIALIZE(m_prescribed, c_element_prescribed, HVCodableValue);
    HVDESERIALIZE(m_prescription, c_element_prescription, HVPrescription);
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Medication", @"Medication Type Name");
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVMedication typeID]];
}

@end
