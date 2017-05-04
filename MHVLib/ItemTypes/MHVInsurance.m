//
//  MHVInsurance.m
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
#import "MHVInsurance.h"

static NSString* const c_typeid = @"9366440c-ec81-4b89-b231-308a4c4d70ed";
static NSString* const c_typename = @"payer";

static NSString* const c_element_planName = @"plan-name";
static NSString* const c_element_coverage = @"coverage-type";
static NSString* const c_element_carrierID = @"carrier-id";
static NSString* const c_element_groupNum = @"group-num";
static NSString* const c_element_planCode = @"plan-code";
static NSString* const c_element_subscriberID = @"subscriber-id";
static NSString* const c_element_personCode = @"person-code";
static NSString* const c_element_subscriberName = @"subscriber-name";
static NSString* const c_element_subsriberDOB = @"subscriber-dob";
static NSString* const c_element_isPrimary = @"is-primary";
static NSString* const c_element_expirationDate = @"expiration-date";
static NSString* const c_element_contact = @"contact";

@implementation MHVInsurance

@synthesize planName = m_planName;
@synthesize coverageType = m_coverageType;
@synthesize carrierID = m_carrierID;
@synthesize groupNum = m_groupNum;
@synthesize planCode = m_planCode;
@synthesize subscriberID = m_subscriberID;
@synthesize personCode = m_personCode;
@synthesize subscriberName = m_subscriberName;
@synthesize subscriberDOB = m_subsriberDOB;
@synthesize isPrimary = m_isPrimary;
@synthesize expirationDate = m_expirationDate;
@synthesize contact = m_contact;


-(NSString *)toString
{
    return (m_planName) ? m_planName : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

+(MHVVocabIdentifier *)vocabForCoverage
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"coverage-types"];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_STRINGOPTIONAL(m_planName, MHVClientError_InvalidInsurance);
    MHVVALIDATE_OPTIONAL(m_coverageType);
    MHVVALIDATE_STRINGOPTIONAL(m_carrierID, MHVClientError_InvalidInsurance);
    MHVVALIDATE_STRINGOPTIONAL(m_groupNum, MHVClientError_InvalidInsurance);
    MHVVALIDATE_STRINGOPTIONAL(m_planCode, MHVClientError_InvalidInsurance);
    MHVVALIDATE_STRINGOPTIONAL(m_subscriberID, MHVClientError_InvalidInsurance);
    MHVVALIDATE_STRINGOPTIONAL(m_personCode, MHVClientError_InvalidInsurance);
    MHVVALIDATE_STRINGOPTIONAL(m_subscriberName, MHVClientError_InvalidInsurance);
    MHVVALIDATE_OPTIONAL(m_subsriberDOB);
    MHVVALIDATE_OPTIONAL(m_isPrimary);
    MHVVALIDATE_OPTIONAL(m_expirationDate);
    MHVVALIDATE_OPTIONAL(m_contact);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_planName value:m_planName];
    [writer writeElement:c_element_coverage content:m_coverageType];
    [writer writeElement:c_element_carrierID value:m_carrierID];
    [writer writeElement:c_element_groupNum value:m_groupNum];
    [writer writeElement:c_element_planCode value:m_planCode];
    [writer writeElement:c_element_subscriberID value:m_subscriberID];
    [writer writeElement:c_element_personCode value:m_personCode];
    [writer writeElement:c_element_subscriberName value:m_subscriberName];
    [writer writeElement:c_element_subsriberDOB content:m_subsriberDOB];
    [writer writeElement:c_element_isPrimary content:m_isPrimary];
    [writer writeElement:c_element_expirationDate content:m_expirationDate];
    [writer writeElement:c_element_contact content:m_contact];
}

-(void)deserialize:(XReader *)reader
{
    m_planName = [reader readStringElement:c_element_planName];
    m_coverageType = [reader readElement:c_element_coverage asClass:[MHVCodableValue class]];
    m_carrierID = [reader readStringElement:c_element_carrierID];
    m_groupNum = [reader readStringElement:c_element_groupNum];
    m_planCode = [reader readStringElement:c_element_planCode];
    m_subscriberID = [reader readStringElement:c_element_subscriberID];
    m_personCode = [reader readStringElement:c_element_personCode];
    m_subscriberName = [reader readStringElement:c_element_subscriberName];
    m_subsriberDOB = [reader readElement:c_element_subsriberDOB asClass:[MHVDateTime class]];
    m_isPrimary = [reader readElement:c_element_isPrimary asClass:[MHVBool class]];
    m_expirationDate = [reader readElement:c_element_expirationDate asClass:[MHVDateTime class]];
    m_contact = [reader readElement:c_element_contact asClass:[MHVContact class]];
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
    return [[MHVItem alloc] initWithType:[MHVInsurance typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Insurance", @"Insurance Type Name");
}

@end
