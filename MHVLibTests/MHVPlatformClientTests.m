//
//  MHVPlatformClientTests.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/7/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHVCommon.h"
#import "MHVPlatformClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVErrorConstants.h"
#import "Kiwi.h"
#import "MHVServiceResponse.h"
#import "MHVMethod.h"
#import "MHVLocation.h"
#import "MHVServiceInstance.h"
#import "MHVHttpServiceResponse.h"

SPEC_BEGIN(MHVPlatformClientTests)

describe(@"MHVPlatformClient", ^
{
    // These variables can be modified to setup various states and test failure paths.
    
    // SelectInstance Method
    __block MHVServiceResponse *selectInstanceResponse;
    __block NSError *selectInstanceError;
    
    // GetThingType Method
    __block MHVServiceResponse *getThingTypeResponse;
    __block NSError *getThingTypeError;
    
    // NewApplicationCreationInfo Method
    __block MHVServiceResponse *newAppInfoResponse;
    __block NSError *newAppInfoError;
    
    // RemoveApplicationRecordAuthorization Method
    __block MHVServiceResponse *removeAuthResponse;
    __block NSError *removeAuthError;
    
    // GetServiceDefinition Method
    __block MHVServiceResponse *getServiceDefResponse;
    __block NSError *getServiceDefError;
    
    // Error validation
    __block NSError *expectedError;
    __block NSString *errorMessage;
    
    // Response Helper
    __block MHVServiceResponse *(^generateResponse)(NSString *, NSInteger) = ^(NSString *xmlString, NSInteger statusCode)
    {
        MHVHttpServiceResponse *response = [[MHVHttpServiceResponse alloc] initWithResponseData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                     statusCode:statusCode];
        
        return [[MHVServiceResponse alloc] initWithWebResponse:response
                                                         isXML:YES];
    };
    
    beforeEach(^
    {
        selectInstanceResponse = nil;
        selectInstanceError = nil;
        getThingTypeResponse = nil;
        getThingTypeError = nil;
        newAppInfoResponse = nil;
        newAppInfoError = nil;
        removeAuthResponse = nil;
        removeAuthError = nil;
        getServiceDefResponse = nil;
        getServiceDefError = nil;
        expectedError = nil;
        errorMessage = nil;
    });
    
    __block KWMock<MHVConnectionProtocol> *connection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    __block MHVPlatformClient *client = [[MHVPlatformClient alloc] initWithConnection:connection];
    
#pragma mark - Mocks
    
    [connection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id(NSArray *params)
    {
        MHVMethod *method = params[0];
        void (^serviceBlock)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
        
        if ([method.name isEqualToString:@"SelectInstance"])
        {
            serviceBlock(selectInstanceResponse, selectInstanceError);
        }
        else if ([method.name isEqualToString:@"GetThingType"])
        {
            serviceBlock(getThingTypeResponse, getThingTypeError);
        }
        else if ([method.name isEqualToString:@"NewApplicationCreationInfo"])
        {
            serviceBlock(newAppInfoResponse, newAppInfoError);
        }
        else if ([method.name isEqualToString:@"RemoveApplicationRecordAuthorization"])
        {
            serviceBlock(removeAuthResponse, removeAuthError);
        }
        else if ([method.name isEqualToString:@"GetServiceDefinition"])
        {
            serviceBlock(getServiceDefResponse, getServiceDefError);
        }
        
        return nil;
    }];
    
    context(@"when selectInstanceWithPreferredLocation is successful", ^
    {
        __block MHVServiceInstance *instance;
        
        beforeEach(^
        {
            selectInstanceResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.SelectInstance\"><selected-instance><id>123</id><name>TEST</name><description>TEST instance</description><platform-url>https://platform.test-service.com/platform/wildcat.ashx</platform-url><shell-url>https://account.test-service.com/</shell-url></selected-instance></wc:info></response>", 200);
            
            instance = nil;
            
            [client selectInstanceWithPreferredLocation:[[MHVLocation alloc] initWithCountry:@"US" stateProvince:@"WA"]
                                             completion:^(MHVServiceInstance * _Nullable serviceInstance, NSError * _Nullable error)
            {
                instance = serviceInstance;
                expectedError = error;
            }];
        });
        
        it(@"should complete with no error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNil];
        });
        
        it(@"should complete with a valid service instance object", ^
        {
            [[expectFutureValue(instance) shouldEventually] beNonNil];
            [[expectFutureValue(instance.instanceID) shouldEventually] equal:@"123"];
            [[expectFutureValue(instance.name) shouldEventually] equal:@"TEST"];
            [[expectFutureValue(instance.instanceDescription) shouldEventually] equal:@"TEST instance"];
            [[expectFutureValue(instance.healthServiceUrl.absoluteString) shouldEventually] equal:@"https://platform.test-service.com/platform/wildcat.ashx"];
            [[expectFutureValue(instance.shellUrl.absoluteString) shouldEventually] equal:@"https://account.test-service.com/"];
        });
    });
    
    context(@"when selectInstanceWithPreferredLocation is called without a location parameter", ^
    {
        __block MHVServiceInstance *instance;
        
        beforeEach(^
        {
            selectInstanceResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.SelectInstance\"><selected-instance><id>123</id><name>TEST</name><description>TEST instance</description><platform-url>https://platform.test-service.com/platform/wildcat.ashx</platform-url><shell-url>https://account.test-service.com/</shell-url></selected-instance></wc:info></response>", 200);
            
            instance = nil;
            MHVLocation *location = nil;
            
            [client selectInstanceWithPreferredLocation:location
                                             completion:^(MHVServiceInstance * _Nullable serviceInstance, NSError * _Nullable error)
             {
                 instance = serviceInstance;
                 expectedError = error;
             }];
        });
        
        it(@"should provide a detailed error", ^
           {
               [[expectFutureValue(expectedError) shouldEventually] beNonNil];
               [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
               [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"preferredLocation is a required parameter."];
           });
        
        it(@"should not provide a service instance object", ^
        {
            [[expectFutureValue(instance) shouldEventually] beNil];
        });
    });
    
    context(@"when selectInstanceWithPreferredLocation fails due to an invalid xml response", ^
    {
        __block MHVServiceInstance *instance;
        
        beforeEach(^
        {
            selectInstanceResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.SelectInstance\"><selected-instance><test>failure</test></wc:info></response>", 200);
            
            instance = nil;
            MHVLocation *location = nil;
            
            [client selectInstanceWithPreferredLocation:location
                                             completion:^(MHVServiceInstance * _Nullable serviceInstance, NSError * _Nullable error)
             {
                 instance = serviceInstance;
                 expectedError = error;
             }];
        });
        
        it(@"should provide a detailed error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"The SelectInstance response is invalid."];
        });
        
        it(@"should not provide a service instance object", ^
        {
            [[expectFutureValue(instance) shouldEventually] beNil];
        });
    });
});

SPEC_END
