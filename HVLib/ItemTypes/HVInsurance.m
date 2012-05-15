//
//  HVInsurance.m
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
#import "HVInsurance.h"

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

@implementation HVInsurance

@synthesize planName = m_planName;
@synthesize coverageType = m_coverageType;
@synthesize carrierID = m_carrierID;
@synthesize groupNum = m_groupNum;
@synthesize planCode = m_planCode;
@synthesize subscriberID = m_subscriberID;
@synthesize personCode = m_personCode;
@synthesize subsriberName = m_subscriberName;
@synthesize subscriberDOB = m_subsriberDOB;
@synthesize isPrimary = m_isPrimary;
@synthesize expirationDate = m_expirationDate;
@synthesize contact = m_contact;

-(void)dealloc
{
    [m_planName release];
    [m_coverageType release];
    [m_carrierID release];
    [m_groupNum release];
    [m_planCode release];
    [m_subscriberID release];
    [m_personCode release];
    [m_subscriberName release];
    [m_subsriberDOB release];
    [m_isPrimary release];
    [m_expirationDate release];
    [m_contact release];

    [super dealloc];
}

-(NSString *)toString
{
    return (m_planName) ? m_planName : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRINGOPTIONAL(m_planName, HVClientError_InvalidInsurance);
    HVVALIDATE_OPTIONAL(m_coverageType);
    HVVALIDATE_STRINGOPTIONAL(m_carrierID, HVClientError_InvalidInsurance);
    HVVALIDATE_STRINGOPTIONAL(m_groupNum, HVClientError_InvalidInsurance);
    HVVALIDATE_STRINGOPTIONAL(m_planCode, HVClientError_InvalidInsurance);
    HVVALIDATE_STRINGOPTIONAL(m_subscriberID, HVClientError_InvalidInsurance);
    HVVALIDATE_STRINGOPTIONAL(m_personCode, HVClientError_InvalidInsurance);
    HVVALIDATE_STRINGOPTIONAL(m_subscriberName, HVClientError_InvalidInsurance);
    HVVALIDATE_OPTIONAL(m_subsriberDOB);
    HVVALIDATE_OPTIONAL(m_isPrimary);
    HVVALIDATE_OPTIONAL(m_expirationDate);
    HVVALIDATE_OPTIONAL(m_contact);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL 
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_planName, c_element_planName);
    HVSERIALIZE(m_coverageType, c_element_coverage);
    HVSERIALIZE_STRING(m_carrierID, c_element_carrierID);
    HVSERIALIZE_STRING(m_groupNum, c_element_groupNum);
    HVSERIALIZE_STRING(m_planCode, c_element_planCode);
    HVSERIALIZE_STRING(m_subscriberID, c_element_subscriberID);
    HVSERIALIZE_STRING(m_personCode, c_element_personCode);
    HVSERIALIZE_STRING(m_subscriberName, c_element_subscriberName);
    HVSERIALIZE(m_subsriberDOB, c_element_subsriberDOB);
    HVSERIALIZE(m_isPrimary, c_element_isPrimary);
    HVSERIALIZE(m_expirationDate, c_element_expirationDate);
    HVSERIALIZE(m_contact, c_element_contact);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_planName, c_element_planName);
    HVDESERIALIZE(m_coverageType, c_element_coverage, HVCodableValue);
    HVDESERIALIZE_STRING(m_carrierID, c_element_carrierID);
    HVDESERIALIZE_STRING(m_groupNum, c_element_groupNum);
    HVDESERIALIZE_STRING(m_planCode, c_element_planCode);
    HVDESERIALIZE_STRING(m_subscriberID, c_element_subscriberID);
    HVDESERIALIZE_STRING(m_personCode, c_element_personCode);
    HVDESERIALIZE_STRING(m_subscriberName, c_element_subscriberName);
    HVDESERIALIZE(m_subsriberDOB, c_element_subsriberDOB, HVDateTime);
    HVDESERIALIZE(m_isPrimary, c_element_isPrimary, HVBool);
    HVDESERIALIZE(m_expirationDate, c_element_expirationDate, HVDateTime);
    HVDESERIALIZE(m_contact, c_element_contact, HVContact);
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
    return [[HVItem alloc] initWithType:[HVInsurance typeID]];
}

@end
