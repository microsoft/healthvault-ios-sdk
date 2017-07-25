//
// MHVPlatformClientTests.m
// MHVLib
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
#import "MHVValidator.h"
#import "MHVPlatformClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVErrorConstants.h"
#import "Kiwi.h"
#import "MHVServiceResponse.h"
#import "MHVMethod.h"
#import "MHVLocation.h"
#import "MHVServiceInstance.h"
#import "MHVHttpServiceResponse.h"
#import "NSError+MHVError.h"
#import "MHVServiceDefinition.h"
#import "MHVThingTypeDefinition.h"
#import "MHVBool.h"
#import "MHVThingTypeVersionInfo.h"
#import "MHVApplicationCreationInfo.h"

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
            
            [client selectInstanceWithPreferredLocation:[[MHVLocation alloc] initWithCountry:@"US" stateProvince:@"WA"]
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
        
        context(@"when selectInstanceWithPreferredLocation fails due to an http service error", ^
        {
            __block MHVServiceInstance *instance;
            
            beforeEach(^
            {
                errorMessage = @"Test http service error message";
                selectInstanceError = [NSError error:[NSError MHVNetworkError] withDescription:errorMessage];
                
                instance = nil;
                
                [client selectInstanceWithPreferredLocation:[[MHVLocation alloc] initWithCountry:@"US" stateProvince:@"WA"]
                                                 completion:^(MHVServiceInstance * _Nullable serviceInstance, NSError * _Nullable error)
                 {
                     instance = serviceInstance;
                     expectedError = error;
                 }];
            });
            
            it(@"should forward the error from the http service", ^
            {
                [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeNetworkError)];
                [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
            });
            
            it(@"should not provide a service instance object", ^
            {
                [[expectFutureValue(instance) shouldEventually] beNil];
            });
        });
    });
    
    context(@"when getServiceDefinitionWithCompletion is successful", ^
    {
        __block MHVServiceDefinition *definition;
        
        beforeEach(^
        {
            getServiceDefResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetServiceDefinition2\"><platform><url>https://platform.test-service.com/platform/wildcat.ashx</url><version>1.1.1.1</version><configuration key=\"testKey\">testValue</configuration></platform><shell><url>https://account.test-service.com/</url><redirect-url>https://account.test-service.com/redirect.aspx</redirect-url></shell><instances current-instance-id=\"123\"><instance><id>1</id><name>US</name><description>US instance</description><platform-url>https://platform.test-service.com/platform/wildcat.ashx</platform-url><shell-url>https://account.test-service.com/</shell-url></instance><instance><id>2</id><name>EU</name><description>EU Instance</description><platform-url>https://platform.test-service.co.uk/platform/wildcat.ashx</platform-url><shell-url>https://account.test-service.co.uk/</shell-url></instance></instances><updated-date>2017-06-08T01:15:12</updated-date></wc:info></response>", 200);
            
            definition = nil;
            
            [client getServiceDefinitionWithWithLastUpdatedTime:[NSDate date]
                                               responseSections:MHVServiceInfoSectionsAll
                                                     completion:^(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error)
             {
                 definition = serviceDefinition;
                 expectedError = error;
             }];
        });
        
        it(@"should complete with no error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNil];
        });
        
        it(@"should complete with a valid service instance object", ^
        {
            [[expectFutureValue(definition) shouldEventually] beNonNil];
            [[expectFutureValue(definition.platform.url) shouldEventually] equal:@"https://platform.test-service.com/platform/wildcat.ashx"];
            [[expectFutureValue(definition.platform.version) shouldEventually] equal:@"1.1.1.1"];
            [[expectFutureValue(theValue(definition.platform.config.count)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(definition.shell.url) shouldEventually] equal:@"https://account.test-service.com/"];
            [[expectFutureValue(definition.shell.redirectUrl) shouldEventually] equal:@"https://account.test-service.com/redirect.aspx"];
            [[expectFutureValue(definition.systemInstances.currentInstanceID) shouldEventually] equal:@"123"];
            [[expectFutureValue(theValue(definition.systemInstances.instances.count)) shouldEventually] equal:theValue(2)];
        });
    });
    
    context(@"when getServiceDefinitionWithCompletion fails due to an invalid xml response", ^
    {
        __block MHVServiceDefinition *definition;
        
        beforeEach(^
        {
            getServiceDefResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetServiceDefinition2\"><platform><test>failure</test></wc:info></response>", 200);
            
            definition = nil;
            
            [client getServiceDefinitionWithWithLastUpdatedTime:nil
                                               responseSections:MHVServiceInfoSectionsAll
                                                     completion:^(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error)
             {
                 definition = serviceDefinition;
                 expectedError = error;
             }];
        });
        
        it(@"should provide a detailed error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"The GetServiceDefinition response is invalid."];
        });
        
        it(@"should not provide a service definition object", ^
        {
            [[expectFutureValue(definition) shouldEventually] beNil];
        });
    });
    
    context(@"when selectInstanceWithPreferredLocation fails due to an http service error", ^
    {
        __block MHVServiceDefinition *definition;
        
        beforeEach(^
        {
            errorMessage = @"Test http service error message";
            getServiceDefError = [NSError error:[NSError MHVNetworkError] withDescription:errorMessage];
            
            definition = nil;
            
            [client getServiceDefinitionWithWithLastUpdatedTime:nil
                                               responseSections:MHVServiceInfoSectionsAll
                                                     completion:^(MHVServiceDefinition * _Nullable serviceDefinition, NSError * _Nullable error)
             {
                 definition = serviceDefinition;
                 expectedError = error;
             }];
        });
        
        it(@"should forward the error from the http service", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeNetworkError)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
        });
        
        it(@"should not provide a service definition object", ^
        {
               [[expectFutureValue(definition) shouldEventually] beNil];
        });
    });
    
    context(@"when getHealthRecordThingTypeDefinitionsWithTypeIds is successful", ^
    {
        __block NSDictionary<NSString *,MHVThingTypeDefinition *> *typeDefs;
        __block NSString *typeId = @"11111111-1111-1111-1111-111111111111";
        
        beforeEach(^
        {
            getThingTypeResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThingType\"><thing-type><id>11111111-1111-1111-1111-111111111111</id><name>Test</name><uncreatable>false</uncreatable><immutable>true</immutable><singleton>true</singleton><xsd>TestXSD</xsd><versions thing-type-id=\"22222222-2222-2222-2222-222222222222\"><version-info version-type-id=\"33333333-3333-3333-3333-333333333333\" version-name=\"TestThing\" version-sequence=\"1\"><order-by-properties><property name=\"when\" type=\"date-time\" xpath=\"test/when\" /><property name=\"value\" type=\"double\" xpath=\"test/value/kg\" /></order-by-properties></version-info></versions><effective-date-xpath>test/effective</effective-date-xpath><updated-end-date-xpath>test/updated</updated-end-date-xpath><allow-readonly>true</allow-readonly></thing-type></wc:info></response>", 200);
            
            typeDefs = nil;
            
            [client getHealthRecordThingTypeDefinitionsWithTypeIds:@[typeId]
                                                          sections:MHVThingTypeSectionsAll
                                                        imageTypes:nil
                                             lastClientRefreshDate:[NSDate date]
                                                        completion:^(NSDictionary<NSString *,MHVThingTypeDefinition *> * _Nullable definitions, NSError * _Nullable error)
             {
                 typeDefs = definitions;
                 expectedError = error;
             }];
        });
        
        it(@"should complete with no error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNil];
        });
        
        it(@"should complete with a valid definitions dictionary", ^
        {
            MHVThingTypeDefinition *typeDef = [typeDefs objectForKey:typeId];
            
            [[expectFutureValue(typeDef) shouldEventually] beNonNil];
            [[expectFutureValue(typeDef.typeId.UUIDString) shouldEventually] equal:typeId];
            [[expectFutureValue(typeDef.xmlSchemaDefinition) shouldEventually] equal:@"TestXSD"];
            [[expectFutureValue(theValue(typeDef.isCreatable.value)) shouldEventually] beYes];
            [[expectFutureValue(theValue(typeDef.isImmutable.value)) shouldEventually] beYes];
            [[expectFutureValue(theValue(typeDef.isSingletonType.value)) shouldEventually] beYes];
            [[expectFutureValue(theValue(typeDef.allowReadOnly.value)) shouldEventually] beYes];
            [[expectFutureValue(typeDef.effectiveDateXPath) shouldEventually] equal:@"test/effective"];
            [[expectFutureValue(typeDef.updatedEndDateXPath) shouldEventually] equal:@"test/updated"];
            [[expectFutureValue(theValue(typeDef.versions.count)) shouldEventually] equal:theValue(1)];
        });
    });
    
    context(@"when getHealthRecordThingTypeDefinitionsWithTypeIds fails due to an invalid xml response", ^
    {
        __block NSDictionary<NSString *,MHVThingTypeDefinition *> *typeDefs;
        
        beforeEach(^
        {
            getThingTypeResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThingType\"><thing-type><test>failure</test></wc:info></response>", 200);
            
            typeDefs = nil;
            
            [client getHealthRecordThingTypeDefinitionsWithTypeIds:nil
                                                          sections:MHVThingTypeSectionsAll
                                                        imageTypes:nil
                                             lastClientRefreshDate:[NSDate date]
                                                        completion:^(NSDictionary<NSString *,MHVThingTypeDefinition *> * _Nullable definitions, NSError * _Nullable error)
             {
                 typeDefs = definitions;
                 expectedError = error;
             }];
        });
        
        it(@"should provide a detailed error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"The GetThingType response is invalid."];
        });
        
        it(@"should not provide a definitions dictionary object", ^
        {
            [[expectFutureValue(typeDefs) shouldEventually] beNil];
        });
    });
    
    context(@"when getHealthRecordThingTypeDefinitionsWithTypeIds fails due to an http service error", ^
    {
        __block NSDictionary<NSString *,MHVThingTypeDefinition *> *typeDefs;
        
        beforeEach(^
        {
            errorMessage = @"Test http service error message";
            getThingTypeError = [NSError error:[NSError MHVNetworkError] withDescription:errorMessage];
            
            typeDefs = nil;
            
            [client getHealthRecordThingTypeDefinitionsWithTypeIds:nil
                                                          sections:MHVThingTypeSectionsAll
                                                        imageTypes:nil
                                             lastClientRefreshDate:[NSDate date]
                                                        completion:^(NSDictionary<NSString *,MHVThingTypeDefinition *> * _Nullable definitions, NSError * _Nullable error)
             {
                 typeDefs = definitions;
                 expectedError = error;
             }];
        });
        
        it(@"should forward the error from the http service", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeNetworkError)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
        });
        
        it(@"should not provide a definitions dictionary object", ^
        {
            [[expectFutureValue(typeDefs) shouldEventually] beNil];
        });
    });
    
    context(@"when newApplicationCreationInfoWithCompletion is successful", ^
    {
        __block MHVApplicationCreationInfo *appCreationInfo;
        
        beforeEach(^
        {
            newAppInfoResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.NewApplicationCreationInfo\"><app-id>11111111-1111-1111-1111-111111111111</app-id><shared-secret>TestSecret</shared-secret><app-token>TestToken</app-token></wc:info></response>", 200);
            
            appCreationInfo = nil;
            
            [client newApplicationCreationInfoWithCompletion:^(MHVApplicationCreationInfo * _Nullable applicationCreationInfo, NSError * _Nullable error)
             {
                 appCreationInfo = applicationCreationInfo;
                 expectedError = error;
             }];
        });
        
        it(@"should complete with no error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNil];
        });
        
        it(@"should complete with a valid application creation info object", ^
        {
            [[expectFutureValue(appCreationInfo) shouldEventually] beNonNil];
            [[expectFutureValue(appCreationInfo.appInstanceId.UUIDString) shouldEventually] equal:@"11111111-1111-1111-1111-111111111111"];
            [[expectFutureValue(appCreationInfo.sharedSecret) shouldEventually] equal:@"TestSecret"];
            [[expectFutureValue(appCreationInfo.appCreationToken) shouldEventually] equal:@"TestToken"];
        });
    });
    
    context(@"when newApplicationCreationInfoWithCompletion fails due to an invalid xml response", ^
    {
        __block MHVApplicationCreationInfo *appCreationInfo;
        
        beforeEach(^
        {
            newAppInfoResponse = generateResponse(@"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.NewApplicationCreationInfo\"><app-id></wc:info></response>", 200);
            
            appCreationInfo = nil;
            
            [client newApplicationCreationInfoWithCompletion:^(MHVApplicationCreationInfo * _Nullable applicationCreationInfo, NSError * _Nullable error)
             {
                 appCreationInfo = applicationCreationInfo;
                 expectedError = error;
             }];
        });
        
        it(@"should provide a detailed error", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeUnknown)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"The NewApplicationCreationInfo response is invalid."];
        });
        
        it(@"should not provide a application creation info object", ^
        {
            [[expectFutureValue(appCreationInfo) shouldEventually] beNil];
        });
    });
    
    context(@"when newApplicationCreationInfoWithCompletion fails due to an http service error", ^
    {
        __block MHVApplicationCreationInfo *appCreationInfo;
        
        beforeEach(^
        {
            errorMessage = @"Test http service error message";
            newAppInfoError = [NSError error:[NSError MHVNetworkError] withDescription:errorMessage];
            
            appCreationInfo = nil;
            
            [client newApplicationCreationInfoWithCompletion:^(MHVApplicationCreationInfo * _Nullable applicationCreationInfo, NSError * _Nullable error)
             {
                 appCreationInfo = applicationCreationInfo;
                 expectedError = error;
             }];
        });
        
        it(@"should forward the error from the http service", ^
        {
            [[expectFutureValue(expectedError) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeNetworkError)];
            [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
        });
        
        it(@"should not provide a application creation info object", ^
        {
            [[expectFutureValue(appCreationInfo) shouldEventually] beNil];
        });
    });
    
    
    
    
    
    context(@"when removeApplicationAuthorizationWithRecordId is successful", ^
            {
                beforeEach(^
                {
                    removeAuthResponse = generateResponse(@"<response><status><code>0</code></status></response>", 200);
                    
                    [client removeApplicationAuthorizationWithRecordId:[NSUUID UUID]
                                                            completion:^(NSError * _Nullable error)
                     {
                         expectedError = error;
                     }];
                });
                
                it(@"should complete with no error", ^
                {
                    [[expectFutureValue(expectedError) shouldEventually] beNil];
                });
            });
    
    context(@"when removeApplicationAuthorizationWithRecordId is called without the recordId parameter", ^
            {
                beforeEach(^
                {
                    removeAuthResponse = generateResponse(@"<response><status><code>0</code></status></response>", 200);
                    
                    NSUUID *recordId = nil;
                    
                    [client removeApplicationAuthorizationWithRecordId:recordId
                                                            completion:^(NSError * _Nullable error)
                     {
                         expectedError = error;
                     }];
                });
                
                it(@"should provide a detailed error", ^
                {
                    [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                    [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeRequiredParameter)];
                    [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:@"recordId is a required parameter."];
                });
            });
    
    context(@"when removeApplicationAuthorizationWithRecordId fails due to an http service error", ^
            {
                beforeEach(^
                {
                    errorMessage = @"Test http service error message";
                    removeAuthError = [NSError error:[NSError MHVNetworkError] withDescription:errorMessage];
                    
                    [client removeApplicationAuthorizationWithRecordId:[NSUUID UUID]
                                                            completion:^(NSError * _Nullable error)
                     {
                         expectedError = error;
                     }];
                });
                
                it(@"should forward the error from the http service", ^
                {
                    [[expectFutureValue(expectedError) shouldEventually] beNonNil];
                    [[expectFutureValue(theValue(expectedError.code)) shouldEventually] equal:theValue(MHVErrorTypeNetworkError)];
                    [[expectFutureValue(expectedError.localizedDescription) shouldEventually] containString:errorMessage];
                });
            });
});

SPEC_END
