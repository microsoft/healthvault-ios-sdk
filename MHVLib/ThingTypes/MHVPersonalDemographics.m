//
//  MHVPersonalDemographics.m
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
#import "MHVPersonalDemographics.h"

static NSString* const c_typeid = @"92ba621e-66b3-4a01-bd73-74844aed4f5b";
static NSString* const c_typename = @"personal";

static NSString* const c_element_name = @"name";
static NSString* const c_element_birthdate = @"birthdate";
static NSString* const c_element_bloodType = @"blood-type";
static NSString* const c_element_ethnicity = @"ethnicity";
static NSString* const c_element_ssn = @"ssn";
static NSString* const c_element_marital = @"marital-status";
static NSString* const c_element_employment = @"employment-status";
static NSString* const c_element_deceased = @"is-deceased";
static NSString* const c_element_dateOfDeath = @"date-of-death";
static NSString* const c_element_religion = @"religion";
static NSString* const c_element_veteran = @"is-veteran";
static NSString* const c_element_education = @"highest-education-level";
static NSString* const c_element_disabled = @"is-disabled";
static NSString* const c_element_donor = @"organ-donor";

@implementation MHVPersonalDemographics

@synthesize name = m_name;
@synthesize birthDate = m_birthdate;
@synthesize bloodType = m_bloodType;
@synthesize ethnicity = m_ethnicity;
@synthesize ssn = m_ssn;
@synthesize maritalStatus = m_maritalStatus;
@synthesize employmentStatus = m_employmentStatus;
@synthesize isDeceased = m_isDeceased;
@synthesize dateOfDeath = m_dateOfDeath;
@synthesize religion = m_religion;
@synthesize isVeteran = m_veteran;
@synthesize education = m_education;
@synthesize isDisabled = m_disabled;
@synthesize organDonor = m_donor;


-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

+(MHVVocabIdentifier *)vocabForBloodType
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"blood-types"];
}

+(MHVVocabIdentifier *)vocabForEthnicity
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"ethnicity-types"];
}

+(MHVVocabIdentifier *)vocabForMaritalStatus
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"marital-status"];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_name);
    MHVVALIDATE_OPTIONAL(m_birthdate);
    MHVVALIDATE_OPTIONAL(m_bloodType);
    MHVVALIDATE_OPTIONAL(m_ethnicity);
    MHVVALIDATE_STRINGOPTIONAL(m_ssn, MHVClientError_InvalidPersonalDemographics);
    MHVVALIDATE_OPTIONAL(m_maritalStatus);
    MHVVALIDATE_OPTIONAL(m_isDeceased);
    MHVVALIDATE_OPTIONAL(m_dateOfDeath);
    MHVVALIDATE_OPTIONAL(m_religion);
    MHVVALIDATE_OPTIONAL(m_veteran);
    MHVVALIDATE_OPTIONAL(m_education);
    MHVVALIDATE_OPTIONAL(m_disabled);
    MHVVALIDATE_STRINGOPTIONAL(m_donor, MHVClientError_InvalidPersonalDemographics);

    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_birthdate content:m_birthdate];
    [writer writeElement:c_element_bloodType content:m_bloodType];
    [writer writeElement:c_element_ethnicity content:m_ethnicity];
    [writer writeElement:c_element_ssn value:m_ssn];
    [writer writeElement:c_element_marital content:m_maritalStatus];
    [writer writeElement:c_element_employment value:m_employmentStatus];
    [writer writeElement:c_element_deceased content:m_isDeceased];
    [writer writeElement:c_element_dateOfDeath content:m_dateOfDeath];
    [writer writeElement:c_element_religion content:m_religion];
    [writer writeElement:c_element_veteran content:m_veteran];
    [writer writeElement:c_element_education content:m_education];
    [writer writeElement:c_element_disabled content:m_disabled];
    [writer writeElement:c_element_donor value:m_donor];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVName class]];
    m_birthdate = [reader readElement:c_element_birthdate asClass:[MHVDateTime class]];
    m_bloodType = [reader readElement:c_element_bloodType asClass:[MHVCodableValue class]];
    m_ethnicity = [reader readElement:c_element_ethnicity asClass:[MHVCodableValue class]];
    m_ssn = [reader readStringElement:c_element_ssn];
    m_maritalStatus = [reader readElement:c_element_marital asClass:[MHVCodableValue class]];
    m_employmentStatus = [reader readStringElement:c_element_employment];
    m_isDeceased = [reader readElement:c_element_deceased asClass:[MHVBool class]];
    m_dateOfDeath = [reader readElement:c_element_dateOfDeath asClass:[MHVApproxDateTime class]];
    m_religion = [reader readElement:c_element_religion asClass:[MHVCodableValue class]];
    m_veteran = [reader readElement:c_element_veteran asClass:[MHVBool class]];
    m_education = [reader readElement:c_element_education asClass:[MHVCodableValue class]];
    m_disabled = [reader readElement:c_element_disabled asClass:[MHVBool class]];
    m_donor = [reader readStringElement:c_element_donor];
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
    return [[MHVItem alloc] initWithType:[MHVPersonalDemographics typeID]];
}

+(BOOL)isSingletonType
{
    return TRUE;
}

@end
