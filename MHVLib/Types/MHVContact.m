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
    return ![NSArray isNilOrEmpty:m_address];
}

-(MHVAddressCollection *)address
{
    HVENSURE(m_address, MHVAddressCollection);
    return m_address;
}

-(void)setAddress:(MHVAddressCollection *)address
{
    m_address = address;
}

-(BOOL)hasPhone
{
    return ![NSArray isNilOrEmpty:m_phone];
}

-(MHVPhoneCollection *)phone
{
    HVENSURE(m_phone, MHVPhoneCollection);
    return m_phone;
}

-(void)setPhone:(MHVPhoneCollection *)phone
{
    m_phone = phone;
}

-(BOOL)hasEmail
{
    return ![NSArray isNilOrEmpty:m_email];
}

-(MHVEmailCollection *)email
{
    HVENSURE(m_email, MHVEmailCollection);
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
    HVCHECK_SELF;
    
    if (phone)
    {
        MHVPhone* phoneObj = [[MHVPhone alloc] initWithNumber:phone];
        HVCHECK_NOTNULL(phoneObj);
        
        [self.phone addObject:phoneObj];
        
        HVCHECK_NOTNULL(m_phone);
    }
    
    if (email)
    {
        MHVEmail* emailObj = [[MHVEmail alloc] initWithEmailAddress:email];
        HVCHECK_NOTNULL(emailObj);
        [self.email addObject:emailObj];
        
        HVCHECK_NOTNULL(m_email);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(MHVClientResult *)validate
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
    m_address = (MHVAddressCollection *)[reader readElementArray:c_element_address asClass:[MHVAddress class] andArrayClass:[MHVAddressCollection class]];
    m_phone = (MHVPhoneCollection *)[reader readElementArray:c_element_phone asClass:[MHVPhone class] andArrayClass:[MHVPhoneCollection class]];
    m_email = (MHVEmailCollection *)[reader readElementArray:c_element_email asClass:[MHVEmail class] andArrayClass:[MHVEmailCollection class]];
}

@end
