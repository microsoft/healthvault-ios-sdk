//
//  HVEmergencyOrProviderContact.m
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
#import "HVEmergencyOrProviderContact.h"

static NSString* const c_typeid = @"25c94a9f-9d3d-4576-96dc-6791178a8143";
static NSString* const c_typename = @"person";

@implementation HVEmergencyOrProviderContact

@synthesize person = m_person;

-(id)initWithPerson:(HVPerson *)person
{
    HVCHECK_NOTNULL(person);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.person = person;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_person release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_person, HVClientError_InvalidEmergencyContact);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    if (m_person)
    {
        [m_person serialize:writer];
    }
}

-(void)deserialize:(XReader *)reader
{
    HVPerson* person = [[HVPerson alloc] init];
    
    HVCHECK_OOM(person);
    HVASSIGN(m_person, person);
   
    [person deserialize:reader];
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
    return [[HVItem alloc] initWithType:[HVEmergencyOrProviderContact typeID]];
}

@end
