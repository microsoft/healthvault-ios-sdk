//
//  MHVApplicationCreationInfo.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/10/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVApplicationCreationInfo.h"

static NSString *const c_element_appId = @"app-id";
static NSString *const c_element_sharedSecret = @"shared-secret";
static NSString *const c_element_appToken = @"app-token";

@implementation MHVApplicationCreationInfo

- (void)deserialize:(XReader *)reader
{
    
}

- (void)deserializeAttributes:(XReader *)reader
{
    _appInstanceId = [[NSUUID alloc] initWithUUIDString:[reader readStringElement:c_element_appId]];
    _sharedSecret = [reader readStringElement:c_element_sharedSecret];
    _appCreationToken = [reader readStringElement:c_element_appToken];
}

- (void)serialize:(XWriter *)writer
{
    
}

- (void)serializeAttributes:(XWriter *)writer
{
    
}

@end
