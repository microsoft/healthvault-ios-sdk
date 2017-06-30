//
//  MHVConnectionFactoryInternal.m
//  MHVLib
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

#import "MHVConnectionFactoryInternal.h"
#import "MHVValidator.h"
#import "NSError+MHVError.h"
#import "MHVSodaConnection.h"
#import "MHVHttpService.h"
#import "MHVKeychainService.h"
#import "MHVShellAuthService.h"
#import "MHVBrowserAuthBroker.h"
#import "MHVClientFactory.h"
#import "MHVThingCacheConfiguration.h"

@interface MHVConnectionFactoryInternal ()

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;
@property (nonatomic, strong) NSObject *lockObject;

@end

@implementation MHVConnectionFactoryInternal

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _lockObject = [NSObject new];
    }
    
    return self;
}

- (id<MHVSodaConnectionProtocol>)getOrCreateSodaConnectionWithConfiguration:(MHVConfiguration *)configuration
{
    MHVASSERT_PARAMETER(configuration);
    
    @synchronized (self.lockObject)
    {
        // The configuration parameter is required.
        if (!configuration)
        {
            return nil;
        }
        
        if (!self.connection)
        {
            self.connection = [[MHVSodaConnection alloc] initWithConfiguration:configuration
                                                            cacheConfiguration:[MHVThingCacheConfiguration new]
                                                                 clientFactory:[MHVClientFactory new]
                                                                   httpService:[[MHVHttpService alloc] initWithConfiguration:configuration]
                                                               keychainService:[MHVKeychainService new]
                                                              shellAuthService:[[MHVShellAuthService alloc] initWithConfiguration:configuration authBroker:[MHVBrowserAuthBroker new]]];
        }
        
        return self.connection;
    }
}

@end
