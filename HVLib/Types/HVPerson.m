//
//  HVPerson.m
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
#import "HVPerson.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_organization = @"organization";
static NSString* const c_element_training = @"professional-training";
static NSString* const c_element_idNumber = @"id";
static NSString* const c_element_contact = @"contact";
static NSString* const c_element_type = @"type";

@implementation HVPerson

@synthesize name = m_name;
@synthesize organization = m_organization;
@synthesize training = m_training;
@synthesize idNumber = m_id;
@synthesize contact = m_contact;
@synthesize type = m_type;

-(void)dealloc
{
    [m_name release];
    [m_organization release];
    [m_training release];
    [m_id release];
    [m_contact release];
    [m_type release];   
     
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

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidPerson);
    HVVALIDATE_OPTIONAL(m_contact);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE_STRING(m_organization, c_element_organization);
    HVSERIALIZE_STRING(m_training, c_element_training);
    HVSERIALIZE_STRING(m_id, c_element_idNumber);
    HVSERIALIZE(m_contact, c_element_contact);
    HVSERIALIZE(m_type, c_element_type);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVName);
    HVDESERIALIZE_STRING(m_organization, c_element_organization);
    HVDESERIALIZE_STRING(m_training, c_element_training);
    HVDESERIALIZE_STRING(m_id, c_element_idNumber);
    HVDESERIALIZE(m_contact, c_element_contact, HVContact);
    HVDESERIALIZE(m_type, c_element_type, HVCodableValue);
}

@end
