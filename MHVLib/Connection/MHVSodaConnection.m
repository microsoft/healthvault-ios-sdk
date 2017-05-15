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
#import "MHVApplicationCreationInfo.h"
#import "MHVPersonInfo.h"
#import "MHVSessionCredential.h"
#import "MHVPlatformClientProtocol.h"
#import "MHVValidator.h"
#import "MHVShellAuthServiceProtocol.h"
#import "MHVInstance.h"
#import "MHVConfiguration.h"
#import "MHVPersonClientProtocol.h"

static NSString *const kServiceInstanceKey = @"ServiceInstance";
static NSString *const kApplicationCreationInfoKey = @"ApplicationCreationInfo";
static NSString *const kSessionCredentialKey = @"SessionCredential";
static NSString *const kPersonInfoKey = @"PersonInfo";

@interface MHVSodaConnection ()

@property (nonatomic, assign) BOOL isAuthUpdating;
@property (nonatomic, strong) dispatch_queue_t authQueue;
@property (nonatomic, strong) MHVPersonInfo *personInfo;
@property (nonatomic, strong) MHVApplicationCreationInfo *applicationCreationInfo;

// Dependencies
@property (nonatomic, strong) id<MHVKeychainServiceProtocol> keychainService;
@property (nonatomic, strong) id<MHVShellAuthServiceProtocol> shellAuthService;

@end

@implementation MHVSodaConnection

@synthesize serviceInstance = _serviceInstance;
@synthesize sessionCredential = _sessionCredential;

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                     credentialClient:(id<MHVSessionCredentialClientProtocol>)credentialClient
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

- (void)authenticateWithViewController:(UIViewController *_Nullable)viewController
                            completion:(void(^_Nullable)(NSError *_Nullable error))completion;
{
    dispatch_async(self.authQueue, ^
    {
        if (![self canStartAuthWithCompletion:completion])
        {
            return;
        }
                       
        [self setConnectionPropertiesFromKeychain];
        
        if (!self.applicationCreationInfo)
        {
           
        }
        
        if (!self.sessionCredential)
        {
            //await this.RefreshSessionCredentialAsync(CancellationToken.None).ConfigureAwait(false);
        }
        
        if (!self.personInfo )
        {
            //await this.GetAndSavePersonInfoAsync().ConfigureAwait(false);
        }
        
        
    });
}

- (void)authorizeAdditionalRecordsWithViewController:(UIViewController *_Nullable)viewController
                                          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    dispatch_async(self.authQueue, ^
    {
        if (![self canStartAuthWithCompletion:completion])
        {
            return;
        }
        
        [self setConnectionPropertiesFromKeychain];
        
        if (!self.sessionCredential || !self.applicationCreationInfo)
        {
            [self finishAuthWithError:[NSError error:[NSError MHVUnauthorizedError] withDescription:@"Authorization required to perform this operation."]
                           completion:completion];
        }
        
        [self.shellAuthService authorizeAdditionalRecordsWithViewController:viewController
                                                                   shellUrl:[[NSURL alloc] initWithString:self.serviceInstance.shellUrl]
                                                                masterAppId:self.configuration.masterApplicationId
                                                                 completion:^(NSError * _Nullable error)
        {
            if (error)
            {
                [self finishAuthWithError:error completion:completion];
                
                return;
            }
            
            [self.personClient getAuthorizedPeopleWithCompletion:^(NSArray<MHVPersonInfo *> * _Nullable people, NSError * _Nullable error)
            {
                if (error)
                {
                    [self finishAuthWithError:error completion:completion];
                    
                    return;
                }
                
                self.personInfo = [people firstObject];
                
                [self.keychainService setXMLObject:self.personInfo forKey:kPersonInfoKey];
                
                if (completion)
                {
                    completion(nil);
                }
                
            }];
            
        }];
        
    });
}

- (void)deauthorizeApplicationWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    dispatch_async(self.authQueue, ^
    {
        if (![self canStartAuthWithCompletion:completion])
        {
            return;
        }
        
        // Delete authorization data from the keychain.
        BOOL success =
            [self.keychainService removeObjectForKey:kServiceInstanceKey] &&
            [self.keychainService removeObjectForKey:kApplicationCreationInfoKey] &&
            [self.keychainService removeObjectForKey:kSessionCredentialKey] &&
            [self.keychainService removeObjectForKey:kPersonInfoKey];
    
        if (!success)
        {
            [self finishAuthWithError:[NSError error:[NSError MHVIOError] withDescription:@"One or more values could not be deleted from the keychain."]
                           completion:completion];
            
            return;
        }
        
        if (self.serviceInstance &&
            self.applicationCreationInfo &&
            self.sessionCredential &&
            self.personInfo)
        {
            [self removeAuthRecords:self.personInfo.records completion:^(NSError * _Nullable error)
            {
                _serviceInstance = nil;
                _applicationCreationInfo = nil;
                _sessionCredential = nil;
                _personInfo = nil;
                
                [self finishAuthWithError:nil completion:completion];
            }];
        }
        else
        {
            [self finishAuthWithError:nil completion:completion];
        }
    });
}

#pragma mark - Private

// Use in conjunction with the authQueue to ensure various auth related calls are synchronized.
- (BOOL)canStartAuthWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (self.isAuthUpdating)
    {
        if (completion)
        {
            completion([NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Another authentication operation is currenlty running."]);
        }
        
        return NO;
    }
    
    self.isAuthUpdating = YES;
    
    return YES;
}

// Use in conjunction with the authQueue to ensure various auth related calls are synchronized.
- (void)finishAuthWithError:(NSError *)error completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    dispatch_async(self.authQueue, ^
    {
        if (completion)
        {
            completion(error);
        }
        
        self.isAuthUpdating = NO;
    });
}

- (void)provisionForSodaWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    
}

- (void)removeAuthRecords:(MHVRecordCollection *)records completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (records.count < 1)
    {
        if (completion)
        {
            completion(nil);
        }
    }

    __block MHVRecord *record = [records firstObject];
    
    [self.platformClient removeApplicationAuthorizationWithRecordId:record.ID completion:^(NSError * _Nullable error)
    {
        if (error)
        {
            // Errors here can be ignored, but we are logging them to help with debugging.
            MHVASSERT_MESSAGE(error.localizedDescription);
        }
        
        [records removeObject:record];
        
        // Recurse through the record collection until there are no more records.
        [self removeAuthRecords:records completion:completion];
        
    }];
}

- (void)setConnectionPropertiesFromKeychain
{
    if (!self.serviceInstance)
    {
       _serviceInstance = [self.keychainService xmlObjectForKey:kServiceInstanceKey];
    }
    
    if (!self.applicationCreationInfo)
    {
        self.applicationCreationInfo = [self.keychainService xmlObjectForKey:kApplicationCreationInfoKey];
    }
    
    if (!self.sessionCredential)
    {
        _sessionCredential = [self.keychainService xmlObjectForKey:kSessionCredentialKey];
    }
    
    if (!self.personInfo)
    {
        self.personInfo = [self.keychainService xmlObjectForKey:kPersonInfoKey];
    }
}

@end
