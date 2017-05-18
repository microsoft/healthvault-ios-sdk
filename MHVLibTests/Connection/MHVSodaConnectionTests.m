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

#import "Kiwi.h"

SPEC_BEGIN(MHVSodaConnectionTests)

describe(@"MHVSodaConnection", ^
{
    MHVConfiguration *config = [MHVConfiguration new];
    id<MHVSessionCredentialClientProtocol> credentialClient = [KWMock mockForProtocol:@protocol(MHVSessionCredentialClientProtocol)];
    id<MHVHttpServiceProtocol> httpservice = [KWMock mockForProtocol:@protocol(MHVHttpServiceProtocol)];
    id<MHVKeychainServiceProtocol> keychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    id<MHVShellAuthServiceProtocol> authService = [KWMock mockForProtocol:@protocol(MHVShellAuthServiceProtocol)];
    id<MHVPlatformClientProtocol> platformClient = [KWMock mockForProtocol:@protocol(MHVPlatformClientProtocol)];
    
    MHVSodaConnection *connection = [[MHVSodaConnection alloc] initWithConfiguration:config
                                                                    credentialClient:credentialClient
                                                                         httpService:httpservice
                                                                     keychainService:keychainService
                                                                    shellAuthService:authService];
    
    [connection stub:@selector(platformClient) andReturn:platformClient];
    
    
    context(@"initial state", ^
    {
     
        MHVSodaConnection *newConnection = [[MHVSodaConnection alloc] initWithConfiguration:config
                                                                           credentialClient:credentialClient
                                                                                httpService:httpservice
                                                                            keychainService:keychainService
                                                                           shellAuthService:authService];
        
        it(@"should have no session data", ^
        {
            [[newConnection.serviceInstance should] beNil];
            [[newConnection.applicationId should] beNil];
            [[newConnection.sessionCredential should] beNil];
        });
    });
    
    context(@"when a user logs out", ^
    {
        // Mock the keychain service response for sign in.
        [(id)keychainService stub:@selector(xmlObjectForKey:) andReturn:nil];
        
        // Mock the newApplicationCreationInfo call.
        [(id)platformClient stub:@selector(newApplicationCreationInfoWithCompletion:) withBlock:^id(NSArray *params)
        {
            void (^appCreationBlk)(MHVApplicationCreationInfo *applicationCreationInfo, NSError *error) = params[0];
            
            MHVApplicationCreationInfo *info = [[MHVApplicationCreationInfo alloc] initWithAppInstanceId:[NSUUID UUID]
                                                                                            sharedSecret:@"SHAREDSECRET"
                                                                                        appCreationToken:@"APPCREATIONTOKEN"];
            appCreationBlk(info, nil);
            return nil;
        }];
        
        // Mock
        
        beforeAll(^
        {
            [connection authenticateWithViewController:nil completion:^(NSError * _Nullable error)
            {
                [connection deauthorizeApplicationWithCompletion:nil];
            }];
            
            
        });
        
        it(@"should have no session data", ^
           {
               [[connection.serviceInstance should] beNil];
               [[connection.applicationId should] beNil];
               [[connection.sessionCredential should] beNil];
           });
        
    });
});

SPEC_END
