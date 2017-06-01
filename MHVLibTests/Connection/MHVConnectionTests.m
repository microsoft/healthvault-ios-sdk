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
#import "NSError+MHVError.h"
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
    KWMock<MHVKeychainServiceProtocol> *keychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    KWMock<MHVShellAuthServiceProtocol> *authService = [KWMock mockForProtocol:@protocol(MHVShellAuthServiceProtocol)];
    
    MHVClientFactory *clientFactory = [MHVClientFactory mock];
    KWMock<MHVPlatformClientProtocol> *platformClient = [KWMock mockForProtocol:@protocol(MHVPlatformClientProtocol)];
    KWMock<MHVSessionCredentialClientProtocol> *credentialClient = [KWMock mockForProtocol:@protocol(MHVSessionCredentialClientProtocol)];
    KWMock<MHVPersonClientProtocol> *personClient = [KWMock mockForProtocol:@protocol(MHVPersonClientProtocol)];
    [(id)clientFactory stub:@selector(platformClientWithConnection:) andReturn:platformClient];
    [(id)clientFactory stub:@selector(credentialClientWithConnection:) andReturn:credentialClient];
    [(id)clientFactory stub:@selector(personClientWithConnection:) andReturn:personClient];
    [(id)keychainService stub:@selector(setXMLObject:forKey:) andReturn:theValue(YES)];
    
    // Test Connection
    MHVConnection *testConnection = [[MHVSodaConnection alloc] initWithConfiguration:[MHVConfiguration new]
                                                                       clientFactory:clientFactory
                                                                         httpService:httpService
                                                                     keychainService:keychainService
                                                                    shellAuthService:authService];
    
    // Set service and credential for tests
    testConnection.serviceInstance = [[MHVInstance alloc] init];
    testConnection.serviceInstance.healthServiceUrl = [NSURL URLWithString:@"https://test.url"];
    
    beforeEach(^
    {
        testConnection.sessionCredential = [[MHVSessionCredential alloc] initWithToken:kDefaultToken sharedSecret:kDefaultSharedSecret];
    });
    
    // Requested values
    __block NSURL *requestedURL;
    __block NSString *requestedHttpMethod;
    __block NSDictionary *requestedHeaders;
    __block NSData *requestedBody;
    
    __block NSError *requestCompletionError;
    
    [httpService stub:@selector(sendRequestForURL:httpMethod:body:headers:completion:) withBlock:^id(NSArray *params)
     {
         requestedURL = params[0];
         requestedHttpMethod = params[1];
         requestedBody = params[2];
         requestedHeaders = params[3];
         
         if (requestCompletionError)
         {
             void (^completion)(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) = params[4];
             completion(nil, requestCompletionError);
         }
         
         return nil;
     }];
    
    context(@"MHVMethod getThings", ^
            {
                beforeAll(^{
                    requestedURL = nil;
                    requestedHttpMethod = nil;
                    requestedHeaders = nil;
                    requestedBody = nil;
                    requestCompletionError = nil;

                    MHVMethod *method = [MHVMethod getThings];
                    method.parameters = @"GETTHINGSBODY";
                    [testConnection executeHttpServiceOperation:method
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[expectFutureValue(requestedURL) shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be service url", ^
                   {
                       [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url"];
                   });
                
                it(@"body should be set", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                   });
                
                it(@"body should contain values", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                       
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
                    requestedURL = nil;
                    requestedHttpMethod = nil;
                    requestedHeaders = nil;
                    requestedBody = nil;
                    requestCompletionError = nil;
                    
                    MHVMethod *method = [MHVMethod putThings];
                    method.parameters = @"PUTTHINGSBODY";
                    [testConnection executeHttpServiceOperation:method
                                                     completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                });
                
                it(@"sendRequest should have been performed", ^
                   {
                       [[expectFutureValue(requestedURL) shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be service url", ^
                   {
                       [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url"];
                   });
                
                it(@"body should be set", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                   });
                
                it(@"body should contain values", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       //Check that body contains correct xml elements
                       [[theValue([bodyString containsString:@"<method>PutThings</method>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<method-version>2</method-version>"]) should] beYes];
                       [[theValue([bodyString containsString:@"<auth-token>TESTTOKEN</auth-token>"]) should] beYes];
                       [[theValue([bodyString containsString:@"PUTTHINGSBODY"]) should] beYes];
                   });
            });
    
    context(@"MHVMethod Token Refresh reissues request", ^
    {
        __block NSNumber *tokenWasRefreshed;

        beforeAll(^
        {
            requestedURL = nil;
            requestedHttpMethod = nil;
            requestedHeaders = nil;
            requestedBody = nil;
            
            //Set error, so request will refresh the token
            requestCompletionError = [NSError MHVUnauthorizedError];

            // Mock token refresh method
            [credentialClient stub:@selector(getSessionCredentialWithSharedSecret:completion:) withBlock:^id(NSArray *params)
             {
                 void (^completion)(MHVSessionCredential *_Nullable credential, NSError *_Nullable error) = params[1];
                 
                 MHVSessionCredential *credential = [[MHVSessionCredential alloc] initWithToken:@"REFRESHED-TOKEN" sharedSecret:kDefaultSharedSecret];
                 
                 //Clear error, so re-issue request won't continue to refresh
                 requestCompletionError = nil;
                 
                 tokenWasRefreshed = @(YES);
                 
                 completion(credential, nil);
                 
                 return nil;
             }];

            MHVMethod *method = [MHVMethod getThings];
            method.parameters = @"GETTHINGSBODY";
            [testConnection executeHttpServiceOperation:method
                                             completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error) { }];
        });
       
        // All tests check tokenWasRefreshed = YES to make sure they happen after the token refesh, and not the initial request
        it(@"token should have been refreshed", ^
           {
               [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
           });

        it(@"url should be service url", ^
           {
               [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
               [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url"];
           });
        
        it(@"body should contain refreshed token and original", ^
           {
               [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
               [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
               
               NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
               
               //Check that body contains correct xml elements
               [[theValue([bodyString containsString:@"<method>GetThings</method>"]) should] beYes];
               [[theValue([bodyString containsString:@"<method-version>3</method-version>"]) should] beYes];
               [[theValue([bodyString containsString:@"<auth-token>REFRESHED-TOKEN</auth-token>"]) should] beYes];
               [[theValue([bodyString containsString:@"GETTHINGSBODY"]) should] beYes];
           });
    });
    
    context(@"MHVRestRequest not anonymous", ^
            {
                beforeAll(^{
                    requestedURL = nil;
                    requestedHttpMethod = nil;
                    requestedHeaders = nil;
                    requestedBody = nil;
                    requestCompletionError = nil;
                    
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
                       [[expectFutureValue(requestedURL) shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be formatted with path from pathParams and queryParams", ^
                   {
                       [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url/path?query1=ABC"];
                   });
                
                it(@"http method should be set", ^
                   {
                       [[expectFutureValue(requestedHttpMethod) shouldEventually] equal:@"METHOD"];
                   });
                
                it(@"authorization header should be set", ^
                   {
                       [[expectFutureValue(requestedHeaders) shouldEventually] beNonNil];
                       [[expectFutureValue(requestedHeaders[@"Authorization"]) shouldEventually] equal:kDefaultToken];
                   });
                
                it(@"body should be set", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       [[expectFutureValue(bodyString) shouldEventually] equal:@"Body"];
                   });
            });
    
    context(@"MHVRestRequest anonymous", ^
            {
                beforeAll(^{
                    requestedURL = nil;
                    requestedHttpMethod = nil;
                    requestedHeaders = nil;
                    requestedBody = nil;
                    requestCompletionError = nil;
                    
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
                       [[expectFutureValue(requestedURL) shouldEventually] beKindOfClass:[NSURL class]];
                   });
                
                it(@"url should be formatted with path from pathParams and queryParams", ^
                   {
                       [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url/path?query1=ABC"];
                   });
                
                it(@"http method should be set", ^
                   {
                       [[expectFutureValue(requestedHttpMethod) shouldEventually] equal:@"METHOD"];
                   });
                
                it(@"authorization header should not be set", ^
                   {
                       [[expectFutureValue(requestedHeaders) shouldEventually] beNonNil];
                       [[expectFutureValue(requestedHeaders[@"Authorization"]) shouldEventually] beNil];
                   });
                
                it(@"body should be set", ^
                   {
                       [[expectFutureValue(requestedBody) shouldEventually] beNonNil];
                       
                       NSString *bodyString = [[NSString alloc] initWithData:requestedBody encoding:NSUTF8StringEncoding];
                       
                       [[expectFutureValue(bodyString) shouldEventually] equal:@"Body"];
                   });
            });
    
    context(@"MHVRestRequest Token Refresh reissues request", ^
            {
                __block NSNumber *tokenWasRefreshed;
                
                beforeAll(^
                          {
                              requestedURL = nil;
                              requestedHttpMethod = nil;
                              requestedHeaders = nil;
                              requestedBody = nil;
                              
                              //Set error, so request will refresh the token
                              requestCompletionError = [NSError MHVUnauthorizedError];
                              
                              // Mock token refresh method
                              [credentialClient stub:@selector(getSessionCredentialWithSharedSecret:completion:) withBlock:^id(NSArray *params)
                               {
                                   void (^completion)(MHVSessionCredential *_Nullable credential, NSError *_Nullable error) = params[1];
                                   
                                   MHVSessionCredential *credential = [[MHVSessionCredential alloc] initWithToken:@"REFRESHED-TOKEN" sharedSecret:kDefaultSharedSecret];
                                   
                                   //Clear error, so re-issue request won't continue to refresh
                                   requestCompletionError = nil;
                                   
                                   tokenWasRefreshed = @(YES);
                                   
                                   completion(credential, nil);
                                   
                                   return nil;
                               }];
                              
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
                
                // All tests check tokenWasRefreshed = YES to make sure they happen after the token refesh, and not the initial request
                it(@"token should have been refreshed", ^
                   {
                       [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
                   });
                
                it(@"url should be formatted with path from pathParams and queryParams", ^
                   {
                       [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
                       [[expectFutureValue(requestedURL.absoluteString) shouldEventually] equal:@"https://test.url/path?query1=ABC"];
                   });
                
                it(@"refreshed authorization header should be set", ^
                   {
                       [[expectFutureValue(tokenWasRefreshed) shouldEventually] beYes];
                       [[expectFutureValue(requestedHeaders) shouldEventually] beNonNil];
                       [[expectFutureValue(requestedHeaders[@"Authorization"]) shouldEventually] equal:@"REFRESHED-TOKEN"];
                   });
            });
});

SPEC_END
