//
// MHVContact.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString *const c_element_address = @"address";
static NSString *const c_element_phone = @"phone";
static NSString *const c_element_email = @"email";

@implementation MHVContact

- (BOOL)hasAddress
{
    return ![MHVCollection isNilOrEmpty:self.address];
}

- (MHVAddressCollection *)address
{
    MHVENSURE(_address, MHVAddressCollection);
    return _address;
}

- (BOOL)hasPhone
{
    return ![MHVCollection isNilOrEmpty:self.phone];
}

- (MHVPhoneCollection *)phone
{
    MHVENSURE(_phone, MHVPhoneCollection);
    return _phone;
}

- (BOOL)hasEmail
{
    return ![MHVCollection isNilOrEmpty:self.email];
}

- (MHVEmailCollection *)email
{
    MHVENSURE(_email, MHVEmailCollection);
    return _email;
}

- (MHVAddress *)firstAddress
{
    return (self.hasAddress) ? [self.address objectAtIndex:0] : nil;
}

- (MHVEmail *)firstEmail
{
    return (self.hasEmail) ? [self.email objectAtIndex:0] : nil;
}

- (MHVPhone *)firstPhone
{
    return (self.hasPhone) ? [self.phone objectAtIndex:0] : nil;
}

- (instancetype)initWithEmail:(NSString *)email
{
    return [self initWithPhone:nil andEmail:email];
}

- (instancetype)initWithPhone:(NSString *)phone
{
    return [self initWithPhone:phone andEmail:nil];
}

- (instancetype)initWithPhone:(NSString *)phone andEmail:(NSString *)email
{
    self = [super init];
    if (self)
    {
        if (phone)
        {
            MHVPhone *phoneObj = [[MHVPhone alloc] initWithNumber:phone];
            MHVCHECK_NOTNULL(phoneObj);
            
            [self.phone addObject:phoneObj];
            
            MHVCHECK_NOTNULL(self.phone);
        }
        
        if (email)
        {
            MHVEmail *emailObj = [[MHVEmail alloc] initWithEmailAddress:email];
            MHVCHECK_NOTNULL(emailObj);
            [self.email addObject:emailObj];
            
            MHVCHECK_NOTNULL(self.email);
        }
    }
    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_ARRAYOPTIONAL(self.address, MHVClientError_InvalidContact);
    MHVVALIDATE_ARRAYOPTIONAL(self.phone, MHVClientError_InvalidContact);
    MHVVALIDATE_ARRAYOPTIONAL(self.email, MHVClientError_InvalidContact);

    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_address elements:self.address.toArray];
    [writer writeElementArray:c_element_phone elements:self.phone.toArray];
    [writer writeElementArray:c_element_email elements:self.email.toArray];
}

- (void)deserialize:(XReader *)reader
{
    self.address = (MHVAddressCollection *)[reader readElementArray:c_element_address
                                                            asClass:[MHVAddress class]
                                                      andArrayClass:[MHVAddressCollection class]];
    self.phone = (MHVPhoneCollection *)[reader readElementArray:c_element_phone
                                                        asClass:[MHVPhone class]
                                                  andArrayClass:[MHVPhoneCollection class]];
    self.email = (MHVEmailCollection *)[reader readElementArray:c_element_email
                                                        asClass:[MHVEmail class]
                                                  andArrayClass:[MHVEmailCollection class]];
}

@end
