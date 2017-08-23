//
//  MHVSodaConnectionTests.m
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
//

#import <XCTest/XCTest.h>
#import "MHVSodaConnection.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVConnectionProtocol.h"
#import "MHVConnection.h"
#import "MHVConfiguration.h"
#import "MHVSessionCredentialClientProtocol.h"
#import "MHVHttpServiceProtocol.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVShellAuthServiceProtocol.h"
#import "MHVServiceInstance.h"
#import "MHVSessionCredential.h"
#import "MHVPlatformClientProtocol.h"
#import "MHVApplicationCreationInfo.h"
#import "MHVClientFactory.h"
#import "Kiwi.h"
#import "MHVServiceDefinition.h"
#import "MHVSystemInstances.h"
#import "MHVServiceInstance.h"
#import "MHVPersonClientProtocol.h"
#import "MHVPersonInfo.h"
#import "NSError+MHVError.h"
#import "MHVErrorConstants.h"
#import "MHVRecord.h"

static NSString *const kDefaultInstanceId = @"TESTINSTANCE1";
static NSString *const kDefaultSharedSecret = @"TESTSHAREDSECRET";
static NSString *const kDefaultAppIdGuid = @"20000000-2000-2000-2000-200000000000";
static NSString *const kDefaultAppCreationToken = @"TESTAPPCREATIONTOKEN";
static NSString *const kDefaultToken = @"TESTTOKEN";

SPEC_BEGIN(MHVSodaConnectionTests)

describe(@"MHVSodaConnection", ^
{
    // These variables can be modified to setup various states and test failure paths.
    
    // Keychain
    __block BOOL shouldSaveServiceInstance;
    __block BOOL shouldSaveApplicationCreationInfo;
    __block BOOL shouldSaveSessionCredential;
    __block BOOL shouldSavePersonInfo;
    __block BOOL shouldDeleteServiceInstance;
    __block BOOL shouldDeleteApplicationCreationInfo;
    __block BOOL shouldDeleteSessionCredential;
    __block BOOL shouldDeletePersonInfo;
    
    // Response for newApplicationCreationInfoWithCompletion:
    __block MHVApplicationCreationInfo *appCreationInfo;
    __block NSError *appCreationError;
    
    // Response for provisionApplicationWithViewController
    __block NSString *instanceId;
    __block NSError *provisionError;
    
    // Response for authorizeAdditionalRecordsWithViewController
    __block NSError *additionalAuthError;
    
    // Response for getServiceDefinitionWithWithResponseSections
    __block MHVServiceDefinition *serviceDefinition;
    __block NSError *serviceDefinitionError;
    
    // Response for removeApplicationAuthorizationWithRecordId
    __block NSError *removeAuthError;
    
    // Response for getSessionCredentialWithSharedSecret
    __block MHVSessionCredential *credential;
    __block NSError *credentialError;
    
    //Resonse for getAuthorizedPeopleWithCompletion
    __block MHVPersonInfo *personInfo;
    __block NSError *authorizedPeopleError;
    
    // Values to mock and validate keychain interaction
    __block BOOL didSaveServiceInstance;
    __block BOOL didSaveApplicationCreationInfo;
    __block BOOL didSaveSessionCredential;
    __block BOOL didSavePersonInfo;
    __block BOOL didDeleteServiceInstance;
    __block BOOL didDeleteApplicationCreationInfo;
    __block BOOL didDeleteSessionCredential;
    __block BOOL didDeletePersonInfo;
    __block MHVServiceInstance *serviceInstanceFromKeychain;
    __block MHVApplicationCreationInfo *appCreationInfoFromKeychain;
    __block MHVSessionCredential *sessionCredentialFromKeychain;
    __block MHVPersonInfo *personInfoFromKeychain;
    
    // Error validation
    __block NSError *expectedError;
    __block NSString *errorMessage;
    
    // Connection
    __block MHVSodaConnection *connection;
    
    MHVConfiguration *config = [MHVConfiguration new];
    id<MHVHttpServiceProtocol> httpservice = [KWMock mockForProtocol:@protocol(MHVHttpServiceProtocol)];
    id<MHVKeychainServiceProtocol> keychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    id<MHVShellAuthServiceProtocol> authService = [KWMock mockForProtocol:@protocol(MHVShellAuthServiceProtocol)];
    
    MHVClientFactory *clientFactory = [MHVClientFactory mock];
    id<MHVPlatformClientProtocol> platformClient = [KWMock mockForProtocol:@protocol(MHVPlatformClientProtocol)];
    id<MHVSessionCredentialClientProtocol> credentialClient = [KWMock mockForProtocol:@protocol(MHVSessionCredentialClientProtocol)];
    id<MHVPersonClientProtocol> personClient = [KWMock mockForProtocol:@protocol(MHVPersonClientProtocol)];
    [(id)clientFactory stub:@selector(platformClientWithConnection:) andReturn:platformClient];
    [(id)clientFactory stub:@selector(credentialClientWithConnection:) andReturn:credentialClient];
    [(id)clientFactory stub:@selector(personClientWithConnection:) andReturn:personClient];
    [(id)clientFactory stub:@selector(thingClientWithConnection:thingCacheDatabase:) andReturn:nil];
    
    beforeEach(^
    {
        shouldSaveServiceInstance = YES;
        shouldSaveApplicationCreationInfo = YES;
        shouldSaveSessionCredential = YES;
        shouldSavePersonInfo = YES;
        shouldDeleteServiceInstance = YES;
        shouldDeleteApplicationCreationInfo = YES;
        shouldDeleteSessionCredential = YES;
        shouldDeletePersonInfo = YES;
        appCreationInfo =  [[MHVApplicationCreationInfo alloc] initWithAppInstanceId:[[NSUUID alloc]initWithUUIDString:kDefaultAppIdGuid]
                                                                        sharedSecret:kDefaultSharedSecret
                                                                    appCreationToken:kDefaultAppCreationToken];;
        appCreationError = nil;
        instanceId = kDefaultInstanceId;
        provisionError = nil;
        additionalAuthError = nil;
        serviceDefinition = [MHVServiceDefinition new];
        serviceDefinition.systemInstances = [MHVSystemInstances new];
        MHVServiceInstance *testInstance = [MHVServiceInstance new];
        testInstance.instanceID = kDefaultInstanceId;
        serviceDefinition.systemInstances.instances = @[testInstance];
        serviceDefinitionError = nil;
        credential = [[MHVSessionCredential alloc]initWithToken:kDefaultToken sharedSecret:kDefaultSharedSecret];
        credentialError = nil;
        personInfo = [MHVPersonInfo new];
        MHVRecord *record = [MHVRecord new];
        record.ID = [NSUUID UUID];
        personInfo.records = @[record];
        personInfo.selectedRecordID = record.ID;
        authorizedPeopleError = nil;
        didSaveServiceInstance = NO;
        didSaveApplicationCreationInfo = NO;
        didSaveSessionCredential = NO;
        didSavePersonInfo = NO;
        didDeleteServiceInstance = NO;
        didDeleteApplicationCreationInfo = NO;
        didDeleteSessionCredential = NO;
        didDeletePersonInfo = NO;
        serviceInstanceFromKeychain = nil;
        appCreationInfoFromKeychain = nil;
        sessionCredentialFromKeychain = nil;
        personInfoFromKeychain = nil;
        expectedError = nil;
        errorMessage = nil;
        
        // Setup the default state and create a new instance of the connection
        // The default values setup the authentication flow to a passing state
        connection = [[MHVSodaConnection alloc] initWithConfiguration:config
                                                    cacheSynchronizer:nil
                                                   cacheConfiguration:nil
                                                        clientFactory:clientFactory
                                                          httpService:httpservice
                                                      keychainService:keychainService
                                                     shellAuthService:authService];
    });
    
    
#pragma mark - Mocks
    
    // Mock the keychain service
    [(id)keychainService stub:@selector(xmlObjectForKey:) withBlock:^id(NSArray *params)
    {
        NSString *key = params[0];
        
        if ([key isEqualToString:@"ServiceInstance"])
        {
            return serviceInstanceFromKeychain;
        }
        else if ([key isEqualToString:@"ApplicationCreationInfo"])
        {
            return appCreationInfoFromKeychain;
        }
        else if ([key isEqualToString:@"SessionCredential"])
        {
            return sessionCredentialFromKeychain;
        }
        else if ([key isEqualToString:@"PersonInfo"])
        {
            return personInfoFromKeychain;
        }
        
        return nil;
    }];
    [(id)keychainService stub:@selector(setXMLObject:forKey:) withBlock:^id(NSArray *params)
    {
        NSString *key = params[1];
        
        if ([key isEqualToString:@"ServiceInstance"])
        {
            didSaveServiceInstance = YES;
            return theValue(shouldSaveServiceInstance);
        }
        else if ([key isEqualToString:@"ApplicationCreationInfo"])
        {
            didSaveApplicationCreationInfo = YES;
            return theValue(shouldSaveApplicationCreationInfo);
        }
        else if ([key isEqualToString:@"SessionCredential"])
        {
            didSaveSessionCredential = YES;
            return theValue(shouldSaveSessionCredential);
        }
        else if ([key isEqualToString:@"PersonInfo"])
        {
            didSavePersonInfo = YES;
            return theValue(shouldSavePersonInfo);
        }
        
        return theValue(YES);
    }];
    [(id)keychainService stub:@selector(removeObjectForKey:) withBlock:^id(NSArray *params)
    {
        NSString *key = params[0];
        
        if ([key isEqualToString:@"ServiceInstance"])
        {
            didDeleteServiceInstance = YES;
            return theValue(shouldDeleteServiceInstance);
        }
        else if ([key isEqualToString:@"ApplicationCreationInfo"])
        {
            didDeleteApplicationCreationInfo = YES;
            return theValue(shouldDeleteApplicationCreationInfo);
        }
        else if ([key isEqualToString:@"SessionCredential"])
        {
            didDeleteSessionCredential = YES;
            return theValue(shouldDeleteSessionCredential);
        }
        else if ([key isEqualToString:@"PersonInfo"])
        {
            didDeletePersonInfo = YES;
            return theValue(shouldDeletePersonInfo);
        }
        
        return theValue(YES);
    }];
    
    // Mock the newApplicationCreationInfo call.
    [(id)platformClient stub:@selector(newApplicationCreationInfoWithCompletion:) withBlock:^id(NSArray *params)
    {
        void (^appCreationBlk)(MHVApplicationCreationInfo *applicationCreationInfo, NSError *error) = params[0];
        appCreationBlk(appCreationInfo, appCreationError);
        return nil;
    }];
    
    // Mock the provisionApplicationWithViewController call
    [(id)authService stub:@selector(provisionApplicationWithViewController:shellUrl:masterAppId:appCreationToken:appInstanceId:completion:) withBlock:^id(NSArray *params)
    {
        void (^provisionBlk)(NSString * _Nullable instanceId, NSError * _Nullable error) = params[5];
        provisionBlk(instanceId, provisionError);
        return nil;
    }];
    
    // Mock the authorizeAdditionalRecordsWithViewController call
    [(id)authService stub:@selector(authorizeAdditionalRecordsWithViewController:shellUrl:appInstanceId:completion:) withBlock:^id(NSArray *params)
     {
         void (^authorizeBlk)(NSError * _Nullable error) = params[3];
         authorizeBlk(additionalAuthError);
         return nil;
     }];
    
    // Mock the getServiceDefinitionWithWithResponseSections call
    [(id)platformClient stub:@selector(getServiceDefinitionWithWithLastUpdatedTime:responseSections:completion:) withBlock:^id(NSArray *params)
    {
        void (^serviceDefBlk)(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error) = params[2];
        serviceDefBlk(serviceDefinition, serviceDefinitionError);
        return nil;
    }];
    
    // Mock the removeApplicationAuthorizationWithRecordId call
    [(id)platformClient stub:@selector(removeApplicationAuthorizationWithRecordId:completion:) withBlock:^id(NSArray *params)
    {
        void (^removeAuthBlk)(NSError * _Nullable error) = params[1];
        removeAuthBlk(removeAuthError);
        return nil;
    }];
    
    // Mock the getSessionCredentialWithSharedSecret call
    [(id)credentialClient stub:@selector(getSessionCredentialWithSharedSecret:completion:) withBlock:^id(NSArray *params)
    {
        void (^credentialBlk)(MHVSessionCredential * _Nullable credential, NSError * _Nullable error) = params[1];
        credentialBlk(credential, credentialError);
        return nil;
    }];
    
    // Mock the getAuthorizedPeopleWithCompletion call
    [(id)personClient stub:@selector(getAuthorizedPeopleWithCompletion:) withBlock:^id(NSArray *params)
    {
        void (^peopleBlk)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError * _Nullable error) = params[0];
        
        peopleBlk(personInfo ? @[personInfo] : nil, authorizedPeopleError);
        
        return nil;
    }];
    
#pragma mark - Tests
    
    context(@"initial state", ^
            {
                it(@"should have no service instance data", ^
                   {
                       [[connection.serviceInstance should] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[connection.applicationId should] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[connection.sessionCredential should] beNil];
                   });
            });
    
    context(@"when authenticateWithViewController is successful", ^
            {
                beforeEach(^
                {
                    [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                     {
                         expectedError = error;
                     }];
                });

                it(@"should complete with no errors", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNil];
                   });
                
                it(@"should save the service instance to disk", ^
                   {
                       [[expectFutureValue(theValue(didSaveServiceInstance)) shouldEventually] beYes];
                   });
                
                it(@"should save the application creation to disk", ^
                   {
                       [[expectFutureValue(theValue(didSaveApplicationCreationInfo)) shouldEventually] beYes];
                   });
                
                it(@"should save the session credential to disk", ^
                   {
                       [[expectFutureValue(theValue(didSaveSessionCredential)) shouldEventually] beYes];
                   });
                
                it(@"should save the person info to disk", ^
                   {
                       [[expectFutureValue(theValue(didSavePersonInfo)) shouldEventually] beYes];
                   });
                
                it(@"should have the correct service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.serviceInstance.instanceID) shouldEventually] containString:kDefaultInstanceId];
                   });
                
                it(@"should have the correct application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.applicationId.UUIDString) shouldEventually] containString:kDefaultAppIdGuid];
                   });
                
                it(@"should have the correct session credential data", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.sessionCredential.token) shouldEventually] containString:kDefaultToken];
                       [[expectFutureValue(connection.sessionCredential.sharedSecret) shouldEventually] containString:kDefaultSharedSecret];
                   });
            });
    
    context(@"when authenticateWithViewController is called and the connection data is cached", ^
            {
                beforeEach(^
                           {
                               serviceInstanceFromKeychain = serviceDefinition.systemInstances.instances[0];
                               appCreationInfoFromKeychain = appCreationInfo;
                               sessionCredentialFromKeychain = credential;
                               personInfoFromKeychain = personInfo;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should complete with no errors", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNil];
                   });
                
                it(@"should have the correct service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.serviceInstance.instanceID) shouldEventually] containString:kDefaultInstanceId];
                   });
                
                it(@"should have the correct application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.applicationId.UUIDString) shouldEventually] containString:kDefaultAppIdGuid];
                   });
                
                it(@"should have the correct session credential data", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.sessionCredential.token) shouldEventually] containString:kDefaultToken];
                       [[expectFutureValue(connection.sessionCredential.sharedSecret) shouldEventually] containString:kDefaultSharedSecret];
                   });
            });
    
    context(@"when authenticateWithViewController fails to obtain application creation info", ^
            {
                beforeEach(^
                           {
                               appCreationInfo = nil;
                               errorMessage = @"provisionApplicationWithViewController failed";
                               appCreationError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to provision the application", ^
            {
                beforeEach(^
                           {
                               instanceId = nil;
                               errorMessage = @"provisionApplicationWithViewController failed";
                               provisionError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to get a valid service definition", ^
            {
                beforeEach(^
                           {
                               serviceDefinition = nil;
                               errorMessage = @"getServiceDefinitionWithWithResponseSections failed";
                               serviceDefinitionError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to get a valid session credential", ^
            {
                beforeEach(^
                           {
                               credential = nil;
                               errorMessage = @"getSessionCredentialWithSharedSecret failed";
                               credentialError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to get authorized people", ^
            {
                beforeEach(^
                           {
                               personInfo = nil;
                               errorMessage = @"getAuthorizedPeopleWithCompletion failed";
                               authorizedPeopleError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController is called and authentication is already in progerss", ^
            {
                
                it(@"should provide a detailed error", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                       {
                           expectedError = error;
                       }];
                       
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeAuthorizationInProgress)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Another authentication operation is currently in progress."];
                   });
            });
    
    context(@"when authenticateWithViewController fails to save the service instance to disk", ^
            {
                beforeEach(^
                           {
                               shouldSaveServiceInstance = NO;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Could not save the service instance to the keychain."];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to save the application creation info to disk", ^
            {
                beforeEach(^
                           {
                               shouldSaveApplicationCreationInfo = NO;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Could not save the application creation info to the keychain."];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to save the session credential to disk", ^
            {
                beforeEach(^
                           {
                               shouldSaveSessionCredential = NO;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Could not save the session credential to the keychain."];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when authenticateWithViewController fails to save the person info to disk", ^
            {
                beforeEach(^
                           {
                               shouldSavePersonInfo = NO;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Could not save the person info to the keychain."];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when deauthorizeApplication is successful", ^
            {
                beforeEach(^
                           {
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error){}];
                                }];
                           });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when deauthorizeApplication is called and the app is not authenticated", ^
            {
                beforeEach(^
                           {
                               [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error){}];
                           });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when deauthorizeApplication is successful and there are multiple records", ^
            {
                beforeEach(^
                           {
                               personInfo.records = @[[MHVRecord new],
                                                      [MHVRecord new],
                                                      [MHVRecord new]];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error){}];
                                }];
                           });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when deauthorizeApplication fails to delete credential data from disk", ^
            {
                beforeEach(^
                           {
                               removeAuthError = [NSError MHVUnknownError];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error)
                                    {
                                        expectedError = error;
                                    }];
                                }];
                           });
                
                it(@"should not fail the process with an error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNil];
                   });
                
                it(@"should have no service instance data", ^
                   {
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNil];
                   });
                
                it(@"should have no application id data", ^
                   {
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNil];
                   });
                
                it(@"should have no session credential", ^
                   {
                       [[expectFutureValue(connection.sessionCredential) shouldEventually] beNil];
                   });
                
                it(@"should delete any credential data saved to disk", ^
                   {
                       [[expectFutureValue(theValue(didDeleteServiceInstance)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteApplicationCreationInfo)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeleteSessionCredential)) shouldEventually] beYes];
                       [[expectFutureValue(theValue(didDeletePersonInfo)) shouldEventually] beYes];
                   });
            });
    
    context(@"when deauthorizeApplication fails to remove authorization record", ^
            {
                beforeEach(^
                           {
                               shouldDeleteServiceInstance = NO;
                               shouldDeleteApplicationCreationInfo = NO;
                               shouldDeleteSessionCredential = NO;
                               shouldDeletePersonInfo = NO;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    [connection deauthorizeApplicationWithCompletion:^(NSError * _Nullable error)
                                     {
                                         expectedError = error;
                                     }];
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"One or more values could not be deleted from the keychain."];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is successful", ^
            {
                __block NSInteger originalRecordCount = 0;
                __block NSInteger additionalRecordCount = 0;
                
                beforeEach(^
                           {
                               originalRecordCount = 0;
                               additionalRecordCount = 0;
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    originalRecordCount = connection.personInfo.records.count;
                                    personInfo.records = [personInfo.records arrayByAddingObjectsFromArray:@[[MHVRecord new], [MHVRecord new]]];
                                    
                                    [connection authorizeAdditionalRecordsWithViewController:nil
                                                                                  completion:^(NSError * _Nullable error)
                                     {
                                         additionalRecordCount = connection.personInfo.records.count;
                                         expectedError = error;
                                     }];
                                }];
                           });
                
                it(@"should not complete with an error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNil];
                   });
                
                it(@"should have updated personInfo records", ^
                   {
                       [[expectFutureValue(theValue(originalRecordCount)) shouldEventually] equal:theValue(1)];
                       [[expectFutureValue(theValue(additionalRecordCount)) shouldEventually] equal:theValue(3)];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called when the connection is not authenticated", ^
            {
                beforeEach(^
                           {
                               [connection authorizeAdditionalRecordsWithViewController:nil
                                                                             completion:^(NSError * _Nullable error)
                                {
                                    expectedError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnauthorized)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"Authorization required to authorize additional records. Must call authenticateWithViewController:completion: first."];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called and the internal authorization process fails", ^
            {
                beforeEach(^
                           {
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    errorMessage = @"TEST ADDITIONAL AUTH ERROR";
                                    additionalAuthError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                                    
                                    [connection authorizeAdditionalRecordsWithViewController:nil
                                                                                  completion:^(NSError * _Nullable error)
                                     {
                                         expectedError = error;
                                     }];
                                }];
                           });
                
                it(@"should forward the error to the caller", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called and fails to get new person info", ^
            {
                beforeEach(^
                           {
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    errorMessage = @"TEST PERSON INFO ERROR";
                                    authorizedPeopleError = [NSError error:[NSError MHVIOError] withDescription:errorMessage];
                                    
                                    [connection authorizeAdditionalRecordsWithViewController:nil
                                                                                  completion:^(NSError * _Nullable error)
                                     {
                                         expectedError = error;
                                     }];
                                }];
                           });
                
                it(@"should forward the error to the caller", ^
                   {
                       [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeIOError)];
                       [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
            });
    
});

SPEC_END
