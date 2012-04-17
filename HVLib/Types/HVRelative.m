//
//  HVRelative.m
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
#import "HVRelative.h"

static NSString* const c_element_relationship = @"relationship";
static NSString* const c_element_name = @"relative-name";
static NSString* const c_element_dateOfBirth = @"date-of-birth";
static NSString* const c_element_dateOfDeath = @"date-of-death";
static NSString* const c_element_region = @"region-of-origin";

@implementation HVRelative

@synthesize relationship = m_relationship;
@synthesize person = m_person;
@synthesize dateOfBirth = m_dateOfBirth;
@synthesize dateOfDeath = m_dateOfDeath;
@synthesize regionOfOrigin = m_regionOfOrigin;

-(void)dealloc
{
    [m_relationship release];
    [m_person release];
    [m_dateOfBirth release];
    [m_dateOfDeath release];
    [m_regionOfOrigin release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_relationship, HVClientError_InvalidRelative);
    HVVALIDATE_OPTIONAL(m_person);
    HVVALIDATE_OPTIONAL(m_dateOfBirth);
    HVVALIDATE_OPTIONAL(m_dateOfDeath);
    HVVALIDATE_OPTIONAL(m_regionOfOrigin);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_relationship, c_element_relationship);
    HVSERIALIZE(m_person, c_element_name);
    HVSERIALIZE(m_dateOfBirth, c_element_dateOfBirth);
    HVSERIALIZE(m_dateOfDeath, c_element_dateOfDeath);
    HVSERIALIZE(m_regionOfOrigin, c_element_region);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_relationship, c_element_relationship, HVCodableValue);
    HVDESERIALIZE(m_person, c_element_name, HVPerson);
    HVDESERIALIZE(m_dateOfBirth, c_element_dateOfBirth, HVApproxDate);
    HVDESERIALIZE(m_dateOfDeath, c_element_dateOfDeath, HVApproxDate);
    HVDESERIALIZE(m_regionOfOrigin, c_element_region, HVApproxDate);    
}

@end
