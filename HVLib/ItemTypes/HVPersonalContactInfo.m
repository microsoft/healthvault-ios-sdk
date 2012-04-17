//
//  HVPersonalContactInfo.m
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
#import "HVPersonalContactInfo.h"

static NSString* const c_typeid = @"162dd12d-9859-4a66-b75f-96760d67072b";
static NSString* const c_typename = @"contact";

@implementation HVPersonalContactInfo

@synthesize contact = m_contact;

-(void)dealloc
{
    [m_contact release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_contact, HVClientError_InvalidPersonalContactInfo);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    if (m_contact)
    {
        [m_contact serialize:writer];
    }
}

-(void)deserialize:(XReader *)reader
{
    HVContact* contact = [[HVContact alloc] init];
    
    HVCHECK_OOM(contact);
    HVASSIGN(m_contact, contact);
    
    [contact deserialize:reader];
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
    return [[HVItem alloc] initWithType:[HVPersonalContactInfo typeID]];
}

@end
