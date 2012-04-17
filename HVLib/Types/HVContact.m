//
//  HVContact.m
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
#import "HVContact.h"

static NSString* const c_element_address = @"address";
static NSString* const c_element_phone = @"phone";
static NSString* const c_element_email = @"email";

@implementation HVContact

@synthesize address = m_address;
@synthesize phone = m_phone;
@synthesize email = m_email;

-(void)dealloc
{
    [m_address release];
    [m_phone release];
    [m_email release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAYOPTIONAL(m_address, HVClientError_InvalidContact);
    HVVALIDATE_ARRAYOPTIONAL(m_phone, HVClientError_InvalidContact);
    HVVALIDATE_ARRAYOPTIONAL(m_email, HVClientError_InvalidContact);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_address, c_element_address);
    HVSERIALIZE_ARRAY(m_phone, c_element_phone);
    HVSERIALIZE_ARRAY(m_email, c_element_email);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_address, c_element_address, HVAddress, HVAddressCollection);
    HVDESERIALIZE_TYPEDARRAY(m_phone, c_element_phone, HVPhone, HVPhoneCollection);
    HVDESERIALIZE_TYPEDARRAY(m_email, c_element_email, HVEmail, HVEmailCollection);    
}

@end
