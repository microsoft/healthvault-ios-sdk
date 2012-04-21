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

static NSString* const c_element_contact = @"contact";

@implementation HVPersonalContactInfo

@synthesize contact = m_contact;

-(id)initWithContact:(HVContact *)contact
{
    HVCHECK_NOTNULL(contact);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.contact = contact;
    
    return self;

LError:
    HVALLOC_FAIL;
}

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
    HVSERIALIZE(m_contact, c_element_contact);
}

-(void)deserialize:(XReader *)reader
{
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
    return [[HVItem alloc] initWithType:[HVPersonalContactInfo typeID]];
}

@end
