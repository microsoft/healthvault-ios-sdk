//
//  MHVContact.m
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
#import "MHVContact.h"

static NSString* const c_element_address = @"address";
static NSString* const c_element_phone = @"phone";
static NSString* const c_element_email = @"email";

@implementation MHVContact

@synthesize phone = m_phone;
@synthesize email = m_email;

-(BOOL)hasAddress
{
    return ![MHVCollection isNilOrEmpty:m_address];
}

-(MHVAddressCollection *)address
{
    MHVENSURE(m_address, MHVAddressCollection);
    return m_address;
}

-(void)setAddress:(MHVAddressCollection *)address
{
    m_address = address;
}

-(BOOL)hasPhone
{
    return ![MHVCollection isNilOrEmpty:m_phone];
}

-(MHVPhoneCollection *)phone
{
    MHVENSURE(m_phone, MHVPhoneCollection);
    return m_phone;
}

-(void)setPhone:(MHVPhoneCollection *)phone
{
    m_phone = phone;
}

-(BOOL)hasEmail
{
    return ![MHVCollection isNilOrEmpty:m_email];
}

-(MHVEmailCollection *)email
{
    MHVENSURE(m_email, MHVEmailCollection);
    return m_email;
}

-(void)setEmail:(MHVEmailCollection *)email
{
    m_email = email;
}

-(MHVAddress *)firstAddress
{
    return (self.hasAddress) ? [m_address itemAtIndex:0] : nil;
}

-(MHVEmail *) firstEmail
{
    return (self.hasEmail) ? [m_email itemAtIndex:0] : nil;
}

-(MHVPhone *)firstPhone
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
    MHVCHECK_SELF;
    
    if (phone)
    {
        MHVPhone* phoneObj = [[MHVPhone alloc] initWithNumber:phone];
        MHVCHECK_NOTNULL(phoneObj);
        
        [self.phone addObject:phoneObj];
        
        MHVCHECK_NOTNULL(m_phone);
    }
    
    if (email)
    {
        MHVEmail* emailObj = [[MHVEmail alloc] initWithEmailAddress:email];
        MHVCHECK_NOTNULL(emailObj);
        [self.email addObject:emailObj];
        
        MHVCHECK_NOTNULL(m_email);
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAYOPTIONAL(m_address, MHVClientError_InvalidContact);
    MHVVALIDATE_ARRAYOPTIONAL(m_phone, MHVClientError_InvalidContact);
    MHVVALIDATE_ARRAYOPTIONAL(m_email, MHVClientError_InvalidContact);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_address elements:m_address.toArray];
    [writer writeElementArray:c_element_phone elements:m_phone.toArray];
    [writer writeElementArray:c_element_email elements:m_email.toArray];
}

-(void)deserialize:(XReader *)reader
{
    m_address = (MHVAddressCollection *)[reader readElementArray:c_element_address asClass:[MHVAddress class] andArrayClass:[MHVAddressCollection class]];
    m_phone = (MHVPhoneCollection *)[reader readElementArray:c_element_phone asClass:[MHVPhone class] andArrayClass:[MHVPhoneCollection class]];
    m_email = (MHVEmailCollection *)[reader readElementArray:c_element_email asClass:[MHVEmail class] andArrayClass:[MHVEmailCollection class]];
}

@end
