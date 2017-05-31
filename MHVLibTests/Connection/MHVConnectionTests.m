//
//  MHVConnectionTests.m
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
#import "MHVCommon.h"
#import "MHVConnectionProtocol.h"
#import "MHVSodaConnection.h"
#import "MHVRestRequest.h"
#import "MHVMethod.h"
#import "MHVHttpServiceProtocol.h"
#import "MHVConfiguration.h"
#import "MHVClientFactory.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVShellAuthServiceProtocol.h"
#import "MHVPlatformClientProtocol.h"
#import "MHVSessionCredentialClientProtocol.h"
#import "MHVPersonClientProtocol.h"
#import "MHVApplicationCreationInfo.h"
#import "MHVSessionCredential.h"
#import "MHVPersonInfo.h"
#import "Kiwi.h"

static NSString *const kDefaultSharedSecret = @"TESTSHAREDSECRET";
static NSString *const kDefaultToken = @"TESTTOKEN";

@interface MHVConnection (Testing)

@property (nonatomic, strong, nullable) MHVSessionCredential *sessionCredential;

@end

SPEC_BEGIN(MHVConnectionTests)

describe(@"MHVConnectionTests", ^
{
    // Mocks
    KWMock<MHVHttpServiceProtocol> *httpService = [KWMock mockForProtocol:@protocol(MHVHttpServiceProtocol)];
    id<MHVKeychainServiceProtocol> keychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    id<MHVShellAuthServiceProtocol> authService = [KWMock mockForProtocol:@protocol(MHVShellAuthServiceProtocol)];
    
    MHVClientFactory *clientFactory = [MHVClientFactory mock];
    id<MHVPlatformClientProtocol> platformClient = [KWMock mockForProtocol:@protocol(MHVPlatformClientProtocol)];
    id<MHVSessionCredentialClientProtocol> credentialClient = [KWMock mockForProtocol:@protocol(MHVSessionCredentialClientProtocol)];
    id<MHVPersonClientProtocol> personClient = [KWMock mockForProtocol:@protocol(MHVPersonClientProtocol)];
    [(id)clientFactory stub:@selector(platformClientWithConnection:) andReturn:platformClient];
    [(id)clientFactory stub:@selector(credentialClientWithConnection:) andReturn:credentialClient];
    [(id)clientFactory stub:@selector(personClientWithConnection:) andReturn:personClient];
    
    // Test Connection
    MHVConnection *testConnection = [[MHVSodaConnection alloc] initWithConfiguration:[MHVConfiguration new]
                                                                       clientFactory:clientFactory
                                                                         httpService:httpService
                                                                     keychainService:keychainService
                                                                    shellAuthService:authService];
    
    // Set service and credential for tests
    testConnection.serviceInstance = [[MHVInstance alloc] init];
    testConnection.serviceInstance.healthServiceUrl = [NSURL URLWithString:@"https://test.url"];
    
    testConnection.sessionCredential = [[MHVSessionCredential alloc] initWithToken:kDefaultToken sharedSecret:kDefaultSharedSecret];
    
    // Requested values
    __block NSURL *requestedURL;
    __block NSString *httpMethod;
    __block NSDictionary *requestedHeaders;
    __block NSData *requestedBody;
    
    [httpService stub:@selector(sendRequestForURL:httpMethod:body:headers:completion:) withBlock:^id(NSArray *params)
     {
         requestedURL = params[0];
         httpMethod = params[1];
         requestedBody = params[2];
         requestedHeaders = params[3];
         
         return nil;
     }];
    
    
    context(@"MHVMethod getThings", ^
            {
                beforeAll(^{
                    MHVMethod *method = [MHVMethod getThings];
                    method.parameters = @"GETTHINGSBODY";
                    [testConnection executeHttpServiceOperation:method
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[requestedURL shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be service url", ^
                   {
                       [[requestedURL.absoluteString shouldEventually] equal:@"https://test.url"];
                   });
                
                it(@"body should be set", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                   });
                
                it(@"body should contain values", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       //Check that body contains correct xml elements
                       [[theValue([bodyString containsString:@"<method>GetThings</method>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<method-version>3</method-version>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<auth-token>TESTTOKEN</auth-token>"]) should] beYes];
                       [[theValue([bodyString containsString:@"GETTHINGSBODY"]) should] beYes];
                   });
            });
    
    context(@"MHVMethod putThings", ^
            {
                beforeAll(^{
                    MHVMethod *method = [MHVMethod putThings];
                    method.parameters = @"PUTTHINGSBODY";
                    [testConnection executeHttpServiceOperation:method
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[requestedURL shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be service url", ^
                   {
                       [[requestedURL.absoluteString shouldEventually] equal:@"https://test.url"];
                   });
                
                it(@"body should be set", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                   });
                
                it(@"body should contain values", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       //Check that body contains correct xml elements
                       [[theValue([bodyString containsString:@"<method>PutThings</method>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<method-version>2</method-version>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<auth-token>TESTTOKEN</auth-token>"]) should] beYes];
                       [[theValue([bodyString containsString:@"PUTTHINGSBODY"]) should] beYes];
                   });
            });
    
    context(@"MHVRestRequest not anonymous", ^
            {
                beforeAll(^{
                    MHVRestRequest *restRequest = [[MHVRestRequest alloc] initWithPath:@"path"
                                                                            httpMethod:@"METHOD"
                                                                            pathParams:nil
                                                                           queryParams:@{ @"query1" : @"ABC" }
                                                                            formParams:nil
                                                                                  body:[@"Body" dataUsingEncoding:NSUTF8StringEncoding]
                                                                           isAnonymous:NO];
                    
                    [testConnection executeHttpServiceOperation:restRequest
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[requestedURL shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be formatted with path from pathParams and queryParams", ^
                   {
                       [[requestedURL.absoluteString shouldEventually] equal:@"https://test.url/path?query1=ABC"];
                   });
                
                it(@"http method should be set", ^
                   {
                       [[httpMethod shouldEventually] equal:@"METHOD"];
                   });
                
                it(@"authorization header should be set", ^
                   {
                       [[requestedHeaders shouldEventually] beNonNil];
                       [[requestedHeaders[@"Authorization"] shouldEventually] equal:kDefaultToken];
                   });
                
                it(@"body should be set", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       [[bodyString shouldEventually] equal:@"Body"];
                   });
            });
    
    context(@"MHVRestRequest anonymous", ^
            {
                beforeAll(^{
                    MHVRestRequest *restRequest = [[MHVRestRequest alloc] initWithPath:@"path"
                                                                            httpMethod:@"METHOD"
                                                                            pathParams:nil
                                                                           queryParams:@{ @"query1" : @"ABC" }
                                                                            formParams:nil
                                                                                  body:[@"Body" dataUsingEncoding:NSUTF8StringEncoding]
                                                                           isAnonymous:YES];
                    
                    [testConnection executeHttpServiceOperation:restRequest
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[requestedURL shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be formatted with path from pathParams and queryParams", ^
                   {
                       [[requestedURL.absoluteString shouldEventually] equal:@"https://test.url/path?query1=ABC"];
                   });
                
                it(@"http method should be set", ^
                   {
                       [[httpMethod shouldEventually] equal:@"METHOD"];
                   });
                
                it(@"authorization header should not be set", ^
                   {
                       [[requestedHeaders shouldEventually] beNonNil];
                       [[requestedHeaders[@"Authorization"] shouldEventually] beNil];
                   });
                
                it(@"body should be set", ^
                   {
                       [[requestedBody shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       [[bodyString shouldEventually] equal:@"Body"];
                   });
            });
});

SPEC_END
