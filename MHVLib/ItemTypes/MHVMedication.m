//
//  MHVMedication.m
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
#import "MHVMedication.h"

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

@implementation MHVMedication

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

-(MHVPerson *)prescriber
{
    return (m_prescription) ? m_prescription.prescriber : nil;
}

-(id)initWithName:(NSString *)name
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

+(MHVVocabIdentifier *) vocabForName
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_rxNormFamily andName:@"RxNorm Active Medicines"];
}

+(MHVVocabIdentifier *) vocabForDoseUnits
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-dose-units"];
}

+(MHVVocabIdentifier *)vocabForStrengthUnits
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-strength-unit"];    
}

+(MHVVocabIdentifier *)vocabForRoute
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-routes"];
}

+(MHVVocabIdentifier *)vocabForIsPrescribed
{    
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"medication-prescribed"];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE(m_name, MHVClientError_InvalidMedication);
    MHVVALIDATE_OPTIONAL(m_genericName);
    MHVVALIDATE_OPTIONAL(m_dose);
    MHVVALIDATE_OPTIONAL(m_strength);
    MHVVALIDATE_OPTIONAL(m_freq);
    MHVVALIDATE_OPTIONAL(m_route);
    MHVVALIDATE_OPTIONAL(m_indication);
    MHVVALIDATE_OPTIONAL(m_startDate);
    MHVVALIDATE_OPTIONAL(m_stopDate);
    MHVVALIDATE_OPTIONAL(m_prescribed);
    MHVVALIDATE_OPTIONAL(m_prescription);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_genericName content:m_genericName];
    [writer writeElement:c_element_dose content:m_dose];
    [writer writeElement:c_element_strength content:m_strength];
    [writer writeElement:c_element_frequency content:m_freq];
    [writer writeElement:c_element_route content:m_route];
    [writer writeElement:c_element_indication content:m_indication];
    [writer writeElement:c_element_startDate content:m_startDate];
    [writer writeElement:c_element_stopDate content:m_stopDate];
    [writer writeElement:c_element_prescribed content:m_prescribed];
    [writer writeElement:c_element_prescription content:m_prescription];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_genericName = [reader readElement:c_element_genericName asClass:[MHVCodableValue class]];
    m_dose = [reader readElement:c_element_dose asClass:[MHVApproxMeasurement class]];
    m_strength = [reader readElement:c_element_strength asClass:[MHVApproxMeasurement class]];
    m_freq = [reader readElement:c_element_frequency asClass:[MHVApproxMeasurement class]];
    m_route = [reader readElement:c_element_route asClass:[MHVCodableValue class]];
    m_indication = [reader readElement:c_element_indication asClass:[MHVCodableValue class]];
    m_startDate = [reader readElement:c_element_startDate asClass:[MHVApproxDateTime class]];
    m_stopDate = [reader readElement:c_element_stopDate asClass:[MHVApproxDateTime class]];
    m_prescribed = [reader readElement:c_element_prescribed asClass:[MHVCodableValue class]];
    m_prescription = [reader readElement:c_element_prescription asClass:[MHVPrescription class]];
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

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVMedication typeID]];
}

@end