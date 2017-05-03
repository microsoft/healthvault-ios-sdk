//
//  HVContact.m
//  HVLib
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

#import "HVCommon.h"
#import "HVContact.h"

static NSString* const c_element_address = @"address";
static NSString* const c_element_phone = @"phone";
static NSString* const c_element_email = @"email";

@implementation HVContact

@synthesize phone = m_phone;
@synthesize email = m_email;

-(BOOL)hasAddress
{
    return ![NSArray isNilOrEmpty:m_address];
}

-(HVAddressCollection *)address
{
    HVENSURE(m_address, HVAddressCollection);
    return m_address;
}

-(void)setAddress:(HVAddressCollection *)address
{
    m_address = address;
}

-(BOOL)hasPhone
{
    return ![NSArray isNilOrEmpty:m_phone];
}

-(HVPhoneCollection *)phone
{
    HVENSURE(m_phone, HVPhoneCollection);
    return m_phone;
}

-(void)setPhone:(HVPhoneCollection *)phone
{
    m_phone = phone;
}

-(BOOL)hasEmail
{
    return ![NSArray isNilOrEmpty:m_email];
}

-(HVEmailCollection *)email
{
    HVENSURE(m_email, HVEmailCollection);
    return m_email;
}

-(void)setEmail:(HVEmailCollection *)email
{
    m_email = email;
}

-(HVAddress *)firstAddress
{
    return (self.hasAddress) ? [m_address itemAtIndex:0] : nil;
}

-(HVEmail *) firstEmail
{
    return (self.hasEmail) ? [m_email itemAtIndex:0] : nil;
}

-(HVPhone *)firstPhone
{
    return (self.hasPhone) ? [m_phone itemAtIndex:0] : nil;
}

-(id)initWithEmail:(NSString *)email
{
    return [self initWithPhone:nil andEmail:email];
}

-(id)initWithPhone:(NSString *)phone
{
    return [self initWithPhone:phone andEmail:nil];
}

-(id)initWithPhone:(NSString *)phone andEmail:(NSString *)email
{
    self = [super init];
    HVCHECK_SELF;
    
    if (phone)
    {
        HVPhone* phoneObj = [[HVPhone alloc] initWithNumber:phone];
        HVCHECK_NOTNULL(phoneObj);
        
        [self.phone addObject:phoneObj];
        
        HVCHECK_NOTNULL(m_phone);
    }
    
    if (email)
    {
        HVEmail* emailObj = [[HVEmail alloc] initWithEmailAddress:email];
        HVCHECK_NOTNULL(emailObj);
        [self.email addObject:emailObj];
        
        HVCHECK_NOTNULL(m_email);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAYOPTIONAL(m_address, HVClientError_InvalidContact);
    HVVALIDATE_ARRAYOPTIONAL(m_phone, HVClientError_InvalidContact);
    HVVALIDATE_ARRAYOPTIONAL(m_email, HVClientError_InvalidContact);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_address elements:m_address];
    [writer writeElementArray:c_element_phone elements:m_phone];
    [writer writeElementArray:c_element_email elements:m_email];
}

-(void)deserialize:(XReader *)reader
{
    m_address = (HVAddressCollection *)[reader readElementArray:c_element_address asClass:[HVAddress class] andArrayClass:[HVAddressCollection class]];
    m_phone = (HVPhoneCollection *)[reader readElementArray:c_element_phone asClass:[HVPhone class] andArrayClass:[HVPhoneCollection class]];
    m_email = (HVEmailCollection *)[reader readElementArray:c_element_email asClass:[HVEmail class] andArrayClass:[HVEmailCollection class]];
}

@end
