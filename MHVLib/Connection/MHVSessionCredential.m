//
//  MHVSessionCredential.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVSessionCredential.h"
#import "MHVValidator.h"

@implementation MHVSessionCredential

- (instancetype)initWithToken:(NSString *)token sharedSecret:(NSString *)sharedSecret
{
    MHVASSERT_PARAMETER(token);
    MHVASSERT_PARAMETER(sharedSecret);
    
    self = [super init];
    
    if (self)
    {
        _token = token;
        _sharedSecret = sharedSecret;
    }
    
    return self;
}

@end
