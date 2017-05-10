//
//  MHVSodaConnection.m
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

#import "MHVSodaConnection.h"
#import "NSError+MHVError.h"
#import "MHVKeychainServiceProtocol.h"

static NSString *const kServiceInstanceKey = @"ServiceInstance";
static NSString *const kApplicationCreationInfoKey = @"ApplicationCreationInfo";
static NSString *const kSessionCredentialKey = @"SessionCredential";
static NSString *const kPersonInfoKey = @"PersonInfo";

@interface MHVSodaConnection ()

@property (nonatomic, assign) BOOL isAuthUpdating;
@property (nonatomic, strong) dispatch_queue_t authQueue;
@property (nonatomic, strong) MHVPersonInfo *personInfo;

// Dependencies
@property (nonatomic, strong) id<MHVKeychainServiceProtocol> keychainService;
@property (nonatomic, strong) id<MHVShellAuthServiceProtocol> shellAuthService;

@end

@implementation MHVSodaConnection

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                     credentialClient:(id<MHVClientSessionCredentialClientProtocol>)credentialClient
                          httpService:(id<MHVHttpServiceProtocol>)httpService
                      keychainService:(id<MHVKeychainServiceProtocol>)keychainService
                     shellAuthService:(id<MHVShellAuthServiceProtocol>)shellAuthService
{
    self = [super initWithConfiguration:configuration
                       credentialClient:credentialClient
                            httpService:httpService];
    
    if (self)
    {
        _keychainService = keychainService;
        _shellAuthService = shellAuthService;
        _authQueue = dispatch_queue_create("MHVSodaConnection.authQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)authorizeAdditionalRecordsWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    
}

- (void)deauthorizeApplicationWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    dispatch_async(self.authQueue, ^
    {
        if (self.isAuthUpdating)
        {
            if (completion)
            {
                completion([NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Another authentication operation is currenlty running."]);
            }
            
            return;
        }
        
        self.isAuthUpdating = YES;
        
        BOOL success =
            [self.keychainService removeStringForKey:kServiceInstanceKey] &&
            [self.keychainService removeStringForKey:kApplicationCreationInfoKey] &&
            [self.keychainService removeStringForKey:kSessionCredentialKey] &&
            [self.keychainService removeStringForKey:kPersonInfoKey];
    
        if (!success)
        {
            if (completion)
            {
                completion([NSError error:[NSError MHVIOError] withDescription:@"One or more values could not be deleted from the keychain."]);
            }
        }
        
        if (self.personInfo) {
            
        }
        
        
    });
}

@end
