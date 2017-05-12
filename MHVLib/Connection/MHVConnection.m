//
//  MHVConnection.m
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

#import "MHVConnection.h"

@interface MHVConnection ()

// Dependencies
@property (nonatomic, strong) id<MHVSessionCredentialClientProtocol> credentialClient;
@property (nonatomic, strong) id<MHVHttpServiceProtocol> httpService;

@end

@implementation MHVConnection

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                     credentialClient:(id<MHVSessionCredentialClientProtocol>)credentialClient
                          httpService:(id<MHVHttpServiceProtocol>)httpService
{
    self = [super init];
    
    if (self)
    {
        _configuration = configuration;
        _credentialClient = credentialClient;
        _httpService = httpService;
    }
    
    return self;
}

- (NSUUID *_Nullable)applicationId;
{
    return nil;
}

- (MHVSessionCredential *_Nullable)sessionCredential;
{
    return nil;
}

- (id<MHVTaskProgressProtocol> _Nullable)executeMethod:(MHVMethod *_Nonnull)method
                                     version:(NSInteger)version
                                  parameters:(NSString *_Nullable)parameters
                                    recordId:(NSUUID *_Nullable)recordId
                               correlationId:(NSUUID *_Nullable)correlationId
                                  completion:(void (^_Nullable)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    return nil;
}

- (id<MHVTaskProgressProtocol>)getPersonInfoWithCompletion:(void (^_Nonnull)(MHVPersonInfo *_Nullable, NSError *_Nullable error))completion;
{
    return nil;
}

- (void)authenticateWithViewController:(UIViewController *_Nullable)viewController
                            completion:(void(^_Nullable)(NSError *_Nullable error))completion;
{
    
}

- (id<MHVPersonClientProtocol> _Nullable)personClient;
{
    return nil;
}

- (id<MHVPlatformClientProtocol> _Nullable)platformClient
{
    return nil;
}

- (id<MHVThingClientProtocol> _Nullable)thingClient
{
    return nil;
}

- (id<MHVVocabularyClientProtocol> _Nullable)vocabularyClient
{
    return nil;
}

@end
