//
//  MHVMethodRequest.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/16/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVMethodRequest.h"
#import "MHVValidator.h"

@implementation MHVMethodRequest

- (instancetype)initWithMethod:(MHVMethod *)method completion:(MHVRequestCompletion _Nullable)completion
{
    MHVASSERT_PARAMETER(method);
    
    self = [super init];
    
    if (self)
    {
        _method = method;
        _completion = completion;
        _retryAttempts = 0;
    }
    
    return self;
}

@end
