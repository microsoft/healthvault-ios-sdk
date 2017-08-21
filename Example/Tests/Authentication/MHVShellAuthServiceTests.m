//
//  MHVShellAuthServiceTests.m
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
#import "Kiwi.h"
#import "MHVShellAuthService.h"
#import "MHVBrowserAuthBrokerProtocol.h"
#import "MHVConfiguration.h"
#import "NSError+MHVError.h"
#import "MHVErrorConstants.h"

@class UIViewController;

static NSString *const kDefaultShellUrlStringTest = @"https://testshellurl.com";
static NSString *const kDefaultAppIdGuid = @"20000000-2000-2000-2000-200000000000";
static NSString *const kDefaultToken = @"TESTTOKEN";
static NSString *const kDefaultInstanceIdGuid = @"30000000-3000-3000-3000-300000000000";
static NSString *const kDefaultSuccessUrlString = @"https://testshellurl.com/application/complete?appid=fed09046-c006-479b-bda7-0eb585a7e538&target=AppAuthSuccess&instanceid=1";

SPEC_BEGIN(MHVShellAuthServiceTests)

describe(@"MHVShellAuthService", ^
{
    // These variables can be modified to setup various states and test failure paths.
    
    __block MHVConfiguration *config;
    __block MHVShellAuthService *authService;
    __block UIViewController *viewController;
    __block NSURL *shellUrl;
    __block NSUUID *appId;
    __block NSString *token;
    __block NSUUID *appInstanceId;
    __block NSString *outInstanceId;
    __block NSURL *successUrl;
    __block NSError *authBrokerError;
    
    // Validation
    __block UIViewController *outViewController;
    __block NSURL *startUrl;
    __block NSURL *endUrl;
    __block NSError *authError;
    __block NSString *errorMessage;
    
    __block id<MHVBrowserAuthBrokerProtocol> authBroker = [KWMock mockForProtocol:@protocol(MHVBrowserAuthBrokerProtocol)];
    
    beforeEach(^
    {
        // Before each test, setup the default state.
        
        config = [MHVConfiguration new];
        authService = [[MHVShellAuthService alloc] initWithConfiguration:config
                                                              authBroker:authBroker];
        viewController = (UIViewController *)[NSObject new];
        shellUrl = [[NSURL alloc]initWithString:kDefaultShellUrlStringTest];
        appId = [[NSUUID alloc] initWithUUIDString:kDefaultAppIdGuid];
        token = kDefaultToken;
        appInstanceId = [[NSUUID alloc] initWithUUIDString:kDefaultInstanceIdGuid];
        outInstanceId = nil;
        successUrl = [[NSURL alloc] initWithString:kDefaultSuccessUrlString];
        
        outViewController = nil;
        startUrl = nil;
        endUrl = nil;
        authBrokerError = nil;
        authError = nil;
        errorMessage = nil;
    });
    
#pragma mark - mocks
    
    // Mock the newApplicationCreationInfo call.
    [(id)authBroker stub:@selector(authenticateWithViewController:startUrl:endUrl:completion:) withBlock:^id(NSArray *params)
     {
         outViewController = params[0];
         startUrl = params[1];
         endUrl = params[2];
         void (^authBlk)(NSURL *_Nullable successUrl, NSError *_Nullable error) = params[3];
         authBlk(successUrl, authBrokerError);
         return nil;
     }];
    
#pragma mark - Tests
    
    context(@"when provisionApplicationWithViewController is called with valid parameters", ^
            {
                beforeEach(^
                {
                    [authService provisionApplicationWithViewController:viewController
                                                               shellUrl:shellUrl
                                                            masterAppId:appId
                                                       appCreationToken:token
                                                          appInstanceId:appInstanceId
                                                             completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                     {
                         outInstanceId = instanceId;
                         authError = error;
                     }];
                });
                
                it(@"should forward the view controller to the auth broker", ^
                   {
                        [[expectFutureValue(outViewController) shouldEventually] equal:viewController];
                   });
                
                it(@"should format and escape the start url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(startUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/redirect.aspx?target=CREATEAPPLICATION&targetqs=%3Fappid%3D20000000-2000-2000-2000-200000000000%26appCreationToken%3DTESTTOKEN%26instanceName%3D30000000-3000-3000-3000-300000000000%26ismra%3Dfalse%26mobile%3Dtrue"];
                   });
                
                it(@"should format the end url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(endUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/application/complete"];
                   });
                
                it(@"should complete with an instanceId if the call to browser auth broker is successful", ^
                   {
                       [[expectFutureValue(outInstanceId) shouldEventually] equal:@"1"];
                   });
                
                it(@"should complete with no error if the call to browser auth broker is successful", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNil];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called with valid parameters and configuration is multi record", ^
            {
                beforeEach(^
                           {
                               config.isMultiRecordApp = YES;
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    outInstanceId = instanceId;
                                    authError = error;
                                }];
                           });
                
                it(@"should format and escape the start url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(startUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/redirect.aspx?target=CREATEAPPLICATION&targetqs=%3Fappid%3D20000000-2000-2000-2000-200000000000%26appCreationToken%3DTESTTOKEN%26instanceName%3D30000000-3000-3000-3000-300000000000%26ismra%3Dtrue%26mobile%3Dtrue"];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called with valid parameters and configuration is multi instance aware", ^
            {
                beforeEach(^
                           {
                               config.isMultiInstanceAware = YES;
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    outInstanceId = instanceId;
                                    authError = error;
                                }];
                           });
                
                it(@"should format and escape the start url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(startUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/redirect.aspx?target=CREATEAPPLICATION&targetqs=%3Fappid%3D20000000-2000-2000-2000-200000000000%26appCreationToken%3DTESTTOKEN%26instanceName%3D30000000-3000-3000-3000-300000000000%26ismra%3Dfalse%26mobile%3Dtrue%26aib%3Dtrue"];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called with missing parameters", ^
            {
                beforeEach(^
                           {
                               shellUrl = nil;
                               appId = nil;
                               token = nil;
                               appInstanceId = nil;
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:@"One or more required parameters are missing."];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called when another provisioning call is in progress", ^
            {
                beforeEach(^
                           {
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error){}];
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeAuthorizationInProgress)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:@"Another authentication operation is currently in progress."];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called and the auth broker returns an error", ^
            {
                beforeEach(^
                           {
                               errorMessage = @"Auth broker test error";
                               authBrokerError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should forward the error from the auth broker", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
            });
    
    context(@"when provisionApplicationWithViewController is called and the auth broker returns an invalid success url", ^
            {
                beforeEach(^
                           {
                               successUrl = [[NSURL alloc] initWithString:@"https://testshellurl.com/badurl"];
                               
                               [authService provisionApplicationWithViewController:viewController
                                                                          shellUrl:shellUrl
                                                                       masterAppId:appId
                                                                  appCreationToken:token
                                                                     appInstanceId:appInstanceId
                                                                        completion:^(NSString * _Nullable instanceId, NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should forward the error from the auth broker", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:@"Failed to obtain an instanceId from the authorization service."];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called with valid parameters", ^
            {
                beforeEach(^
                           {
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should forward the view controller to the auth broker", ^
                   {
                       [[expectFutureValue(outViewController) shouldEventually] equal:viewController];
                   });
                
                it(@"should format and escape the start url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(startUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/redirect.aspx?target=APPAUTH&targetqs=%3Fappid%3D30000000-3000-3000-3000-300000000000%26ismra%3Dfalse"];
                   });
                
                it(@"should format the end url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(endUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/application/complete"];
                   });
                
                it(@"should complete with no error if the call to browser auth broker is successful", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNil];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called with valid parameters and configuration is multi record", ^
            {
                beforeEach(^
                           {
                               config.isMultiRecordApp = YES;
                               
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should format and escape the start url it provides to the browser auth broker", ^
                   {
                       [[expectFutureValue(startUrl.absoluteString) shouldEventually] equal:@"https://testshellurl.com/redirect.aspx?target=APPAUTH&targetqs=%3Fappid%3D30000000-3000-3000-3000-300000000000%26ismra%3Dtrue"];
                   });

            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called when another authorization call is in progress", ^
            {
                beforeEach(^
                           {
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error){}];
                               
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeAuthorizationInProgress)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:@"Another authentication operation is currently in progress."];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called with missing parameters", ^
            {
                beforeEach(^
                           {
                               shellUrl = nil;
                               appInstanceId = nil;
                               
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should provide a detailed error", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:@"One or more required parameters are missing."];
                   });
            });
    
    context(@"when authorizeAdditionalRecordsWithViewController is called and the auth broker returns an error", ^
            {
                beforeEach(^
                           {
                               errorMessage = @"Auth broker test error";
                               authBrokerError = [NSError error:[NSError MHVUnknownError] withDescription:errorMessage];
                               
                               [authService authorizeAdditionalRecordsWithViewController:viewController
                                                                                shellUrl:shellUrl
                                                                           appInstanceId:appInstanceId
                                                                              completion:^(NSError * _Nullable error)
                                {
                                    authError = error;
                                }];
                           });
                
                it(@"should forward the error from the auth broker", ^
                   {
                       [[expectFutureValue(authError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(authError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
                       [[expectFutureValue(authError.localizedDescription) shouldEventually] containString:errorMessage];
                   });
            });
});

SPEC_END
