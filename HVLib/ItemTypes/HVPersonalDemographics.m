//
//  HVPersonalDemographics.m
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
#import "HVPersonalDemographics.h"

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

@implementation HVPersonalDemographics

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

-(void)dealloc
{
    [m_name release];
    [m_birthdate release];
    [m_bloodType release];
    [m_ethnicity release];
    [m_ssn release];
    [m_maritalStatus release];
    [m_employmentStatus release];
    [m_isDeceased release];
    [m_dateOfDeath release];
    [m_religion release];
    [m_veteran release];
    [m_education release];
    [m_disabled release];
    [m_donor release];
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

+(HVVocabIdentifier *)vocabForBloodType
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"blood-types"] autorelease];
}

+(HVVocabIdentifier *)vocabForEthnicity
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"ethnicity-types"] autorelease];
}

+(HVVocabIdentifier *)vocabForMaritalStatus
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"marital-status"] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_name);
    HVVALIDATE_OPTIONAL(m_birthdate);
    HVVALIDATE_OPTIONAL(m_bloodType);
    HVVALIDATE_OPTIONAL(m_ethnicity);
    HVVALIDATE_STRINGOPTIONAL(m_ssn, HVClientError_InvalidPersonalDemographics);
    HVVALIDATE_OPTIONAL(m_maritalStatus);
    HVVALIDATE_OPTIONAL(m_isDeceased);
    HVVALIDATE_OPTIONAL(m_dateOfDeath);
    HVVALIDATE_OPTIONAL(m_religion);
    HVVALIDATE_OPTIONAL(m_veteran);
    HVVALIDATE_OPTIONAL(m_education);
    HVVALIDATE_OPTIONAL(m_disabled);
    HVVALIDATE_STRINGOPTIONAL(m_donor, HVClientError_InvalidPersonalDemographics);

    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_birthdate, c_element_birthdate);
    HVSERIALIZE(m_bloodType, c_element_bloodType);
    HVSERIALIZE(m_ethnicity, c_element_ethnicity);
    HVSERIALIZE_STRING(m_ssn, c_element_ssn);
    HVSERIALIZE(m_maritalStatus, c_element_marital);
    HVSERIALIZE_STRING(m_employmentStatus, c_element_employment);
    HVSERIALIZE(m_isDeceased, c_element_deceased);
    HVSERIALIZE(m_dateOfDeath, c_element_dateOfDeath);
    HVSERIALIZE(m_religion, c_element_religion);
    HVSERIALIZE(m_veteran, c_element_veteran);
    HVSERIALIZE(m_education, c_element_education);
    HVSERIALIZE(m_disabled, c_element_disabled);
    HVSERIALIZE_STRING(m_donor, c_element_donor);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVName);
    HVDESERIALIZE(m_birthdate, c_element_birthdate, HVDateTime);
    HVDESERIALIZE(m_bloodType, c_element_bloodType, HVCodableValue);
    HVDESERIALIZE(m_ethnicity, c_element_ethnicity, HVCodableValue);
    HVDESERIALIZE_STRING(m_ssn, c_element_ssn);
    HVDESERIALIZE(m_maritalStatus, c_element_marital, HVCodableValue);
    HVDESERIALIZE_STRING(m_employmentStatus, c_element_employment);
    HVDESERIALIZE(m_isDeceased, c_element_deceased, HVBool);
    HVDESERIALIZE(m_dateOfDeath, c_element_dateOfDeath, HVApproxDateTime);
    HVDESERIALIZE(m_religion, c_element_religion, HVCodableValue);
    HVDESERIALIZE(m_veteran, c_element_veteran, HVBool);
    HVDESERIALIZE(m_education, c_element_education, HVCodableValue);
    HVDESERIALIZE(m_disabled, c_element_disabled, HVBool);
    HVDESERIALIZE_STRING(m_donor, c_element_donor);
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
    return [[HVItem alloc] initWithType:[HVPersonalDemographics typeID]];
}

+(BOOL)isSingletonType
{
    return TRUE;
}

@end
