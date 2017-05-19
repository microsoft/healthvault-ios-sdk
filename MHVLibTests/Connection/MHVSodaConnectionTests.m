//
//  MHVSodaConnectionTests.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/18/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVInstance.h"
#import "MHVSessionCredential.h"
#import "MHVPlatformClientProtocol.h"
#import "MHVApplicationCreationInfo.h"
#import "MHVClientFactory.h"
#import "Kiwi.h"
#import "MHVServiceDefinition.h"
#import "MHVSystemInstances.h"
#import "MHVInstance.h"
#import "MHVPersonClientProtocol.h"
#import "MHVPersonInfo.h"
#import "NSError+MHVError.h"

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
    
    // Response for getServiceDefinitionWithWithResponseSections
    __block MHVServiceDefinition *serviceDefinition;
    __block NSError *serviceDefinitionError;
    
    // Response for getSessionCredentialWithSharedSecret
    __block MHVSessionCredential *credential;
    __block NSError *credentialError;
    
    //Resonse for getAuthorizedPeopleWithCompletion
    __block MHVPersonInfo *personInfo;
    __block NSError *authorizedPeopleError;
    
    // Values to validate keychain interaction
    __block BOOL didSaveServiceInstance;
    __block BOOL didSaveApplicationCreationInfo;
    __block BOOL didSaveSessionCredential;
    __block BOOL didSavePersonInfo;
    __block BOOL didDeleteServiceInstance;
    __block BOOL didDeleteApplicationCreationInfo;
    __block BOOL didDeleteSessionCredential;
    __block BOOL didDeletePersonInfo;
    
    // Error validation
    __block NSError *loginError;
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
    
    beforeEach(^
    {
        // Setup the default state and create a new instance of the connection
        // The default values setup the authentication flow to a passing state
        connection = [[MHVSodaConnection alloc] initWithConfiguration:config
                                                        clientFactory:clientFactory
                                                          httpService:httpservice
                                                      keychainService:keychainService
                                                     shellAuthService:authService];
        
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
        serviceDefinition = [MHVServiceDefinition new];
        serviceDefinition.systemInstances = [MHVSystemInstances new];
        MHVInstance *testInstance = [MHVInstance new];
        testInstance.instanceID = kDefaultInstanceId;
        serviceDefinition.systemInstances.instances = [[MHVInstanceCollection alloc] initWithObject:testInstance];
        serviceDefinitionError = nil;
        credential = [[MHVSessionCredential alloc]initWithToken:kDefaultToken sharedSecret:kDefaultSharedSecret];
        credentialError = nil;
        personInfo = [MHVPersonInfo new];
        personInfo.selectedRecordID = [NSUUID UUID];
        authorizedPeopleError = nil;
        didSaveServiceInstance = NO;
        didSaveApplicationCreationInfo = NO;
        didSaveSessionCredential = NO;
        didSavePersonInfo = NO;
        didDeleteServiceInstance = NO;
        didDeleteApplicationCreationInfo = NO;
        didDeleteSessionCredential = NO;
        didDeletePersonInfo = NO;
        loginError = nil;
        errorMessage = nil;
    });
    
    
#pragma mark - Mocks
    
    // Mock the keychain service
    [(id)keychainService stub:@selector(xmlObjectForKey:) andReturn:nil];
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
    
    // Mock the getServiceDefinitionWithWithResponseSections call
    [(id)platformClient stub:@selector(getServiceDefinitionWithWithResponseSections:completion:) withBlock:^id(NSArray *params)
    {
        void (^serviceDefBlk)(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error) = params[1];
        serviceDefBlk(serviceDefinition, serviceDefinitionError);
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
        void (^peopleBlk)(NSArray<MHVPersonInfo *> * _Nullable people, NSError * _Nullable error) = params[0];
        
        NSArray<MHVPersonInfo *> *array;
        
        if (personInfo)
        {
            array = @[personInfo];
        }
        
        peopleBlk(array, authorizedPeopleError);
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
    
    context(@"when authenticateWithViewController call is successful", ^
            {
                __block NSError *loginError;

                it(@"should complete with no errors", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                        {
                            loginError = error;
                        }];
                       
                       [[expectFutureValue(loginError) shouldEventually] beNil];
                   });
                
                it(@"should save the service instance to disk", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(theValue(didSaveServiceInstance)) shouldEventually] beYes];
                   });
                
                it(@"should save the application creation to disk", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(theValue(didSaveApplicationCreationInfo)) shouldEventually] beYes];
                   });
                
                it(@"should save the session credential to disk", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(theValue(didSaveSessionCredential)) shouldEventually] beYes];
                   });
                
                it(@"should save the person info to disk", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(theValue(didSavePersonInfo)) shouldEventually] beYes];
                   });
                
                it(@"should have the correct service instance data", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(connection.serviceInstance) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.serviceInstance.instanceID) shouldEventually] containString:kDefaultInstanceId];
                   });
                
                it(@"should have the correct application id data", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
                       [[expectFutureValue(connection.applicationId) shouldEventually] beNonNil];
                       [[expectFutureValue(connection.applicationId.UUIDString) shouldEventually] containString:kDefaultAppIdGuid];
                   });
                
                it(@"should have the correct session credential data", ^
                   {
                       [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error){}];
                       
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
                                    loginError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(loginError) shouldEventually] beNonNil];
                       [[expectFutureValue(loginError.localizedDescription) shouldEventually] containString:errorMessage];
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
                                    loginError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(loginError) shouldEventually] beNonNil];
                       [[expectFutureValue(loginError.localizedDescription) shouldEventually] containString:errorMessage];
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
                                    loginError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(loginError) shouldEventually] beNonNil];
                       [[expectFutureValue(loginError.localizedDescription) shouldEventually] containString:errorMessage];
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
                                    loginError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(loginError) shouldEventually] beNonNil];
                       [[expectFutureValue(loginError.localizedDescription) shouldEventually] containString:errorMessage];
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
                               personInfo = nil;
                               errorMessage = @"getAuthorizedPeopleWithCompletion failed";
                               authorizedPeopleError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
                                {
                                    loginError = error;
                                }];
                           });
                
                it(@"should provide the error from the method call", ^
                   {
                       [[expectFutureValue(loginError) shouldEventually] beNonNil];
                       [[expectFutureValue(loginError.localizedDescription) shouldEventually] containString:errorMessage];
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
});

SPEC_END
