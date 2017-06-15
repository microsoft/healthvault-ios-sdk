//
// MHVPersonClientTests.m
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
#import "MHVCommon.h"
#import "MHVMethod.h"
#import "MHVPersonClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVServiceResponse.h"
#import "MHVApplicationSettings.h"
#import "MHVHttpServiceResponse.h"
#import "MHVErrorConstants.h"
#import "MHVPersonInfo.h"
#import "MHVGetAuthorizedPeopleResult.h"
#import "MHVGetAuthorizedPeopleSettings.h"
#import "Kiwi.h"

static NSString *kHealthVaultErrorXml = @"<response><status><code>3</code><error><message>Test Error.</message></error></status>";

SPEC_BEGIN(MHVPersonClientTests)

describe(@"MHVPersonClient", ^
{
    __block NSString *responseString;
    __block MHVApplicationSettings *returnedSettings;
    __block MHVPersonInfo *returnedPersonInfo;
    __block MHVGetAuthorizedPeopleResult *returnedAuthorizedPeople;
    __block MHVRecordCollection *returnedRecords;
    __block NSError *returnedError;
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id(NSArray *params)
     {
         MHVHttpServiceResponse *httpServiceResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                 statusCode:0];
         
         MHVServiceResponse *serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:httpServiceResponse isXML:YES];
         
         
         void (^completion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
         completion(serviceResponse, serviceResponse.error);
         return nil;
     }];
    
    let(personClient, ^
        {
            return [[MHVPersonClient alloc] initWithConnection:mockConnection];
        });
    
    beforeEach(^{
        returnedSettings = nil;
        returnedPersonInfo = nil;
        returnedRecords = nil;
        returnedError = nil;
    });
    
#pragma mark - GetApplicationSettings
    
    context(@"GetApplicationSettings success", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetApplicationSettings\"><app-settings><data>ABCDEFG</data></app-settings></wc:info></response>";
                    
                    [personClient getApplicationSettingsWithCompletion:^(MHVApplicationSettings * _Nullable settings, NSError * _Nullable error)
                     {
                         returnedSettings = settings;
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have settings", ^
                   {
                       [[expectFutureValue(returnedSettings) shouldEventually] beNonNil];
                   });
                it(@"should have correct settings values", ^
                   {
                       [[expectFutureValue(returnedSettings.xmlSettings) shouldEventually] equal:@"<data>ABCDEFG</data>"];
                   });
            });
    
    context(@"GetApplicationSettings error response", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = kHealthVaultErrorXml;
                    
                    [personClient getApplicationSettingsWithCompletion:^(MHVApplicationSettings * _Nullable settings, NSError * _Nullable error)
                     {
                         returnedSettings = settings;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should not have settings", ^
                   {
                       [[expectFutureValue(returnedSettings) shouldEventually] beNil];
                   });
            });
    
#pragma mark - SetApplicationSettings
    
    context(@"SetApplicationSettings success", ^
            {
                beforeEach(^{
                    // Mock response for SetApplicationSettings
                    responseString = @"<response><status><code>0</code></status></response>";
                    
                    MHVApplicationSettings *appSettings = [MHVApplicationSettings new];
                    appSettings.xmlSettings = @"<test>data</test>";
                    
                    [personClient setApplicationSettings:appSettings
                                              completion:^(NSError * _Nullable error)
                     {
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
            });
    
    context(@"SetApplicationSettings error response", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = kHealthVaultErrorXml;
                    
                    MHVApplicationSettings *appSettings = [MHVApplicationSettings new];
                    appSettings.xmlSettings = @"<test>data</test>";
                    
                    [personClient setApplicationSettings:appSettings
                                              completion:^(NSError * _Nullable error)
                     {
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
            });
    
    context(@"SetApplicationSettings parameter error", ^
            {
                beforeEach(^{
                    MHVApplicationSettings *nilAppSettings = nil;
                    [personClient setApplicationSettings:nilAppSettings
                                              completion:^(NSError * _Nullable error)
                     {
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should have required parameter error code", ^
                   {
                       [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
#pragma mark - GetAuthorizedPeople
    
    context(@"GetAuthorizedPeople success", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results><person-info><person-id>5370f5ce-de91-4fff-b830-90c40d483941</person-id><name>Mike B</name><record id=\"4c4c84fd-b5d0-48ff-8038-17c8f1b084d5\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Mike B\" state=\"Active\" date-created=\"2015-10-09T15:28:42.397Z\" max-size-bytes=\"4294967296\" size-bytes=\"30065480\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793271\" location-country=\"US\" date-updated=\"2017-06-13T00:24:30.333Z\" latest-operation-sequence-number=\"860\" record-app-auth-created-date=\"2017-06-13T00:24:30.333Z\">Mike B</record><record id=\"8698144d-c29a-46c2-a20c-baa9c847140d\" record-custodian=\"true\" rel-type=\"2\" rel-name=\"Other\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test\" state=\"Active\" date-created=\"2017-04-28T20:44:46.537Z\" max-size-bytes=\"4294967296\" size-bytes=\"31586376\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793272\" location-country=\"US\" date-updated=\"2017-06-13T00:24:30.4Z\" latest-operation-sequence-number=\"146\" record-app-auth-created-date=\"2017-06-13T00:24:30.4Z\">Test SubPerson</record><record id=\"432f684f-26f9-4e25-a9fe-5375ddaa0bc0\" record-custodian=\"true\" rel-type=\"13\" rel-name=\"Pet\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test2\" state=\"Active\" date-created=\"2017-06-06T15:23:40.533Z\" max-size-bytes=\"4294967296\" size-bytes=\"57470\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793273\" location-country=\"US\" location-state-province=\"WA\" date-updated=\"2017-06-13T00:24:30.46Z\" latest-operation-sequence-number=\"14\" record-app-auth-created-date=\"2017-06-13T00:24:30.46Z\">Test2 Test2</record><preferred-culture><language>en-US</language></preferred-culture><preferred-uiculture><language>en-US</language></preferred-uiculture><location><country>US</country></location></person-info><more-results>false</more-results></response-results></wc:info></response>";
                    
                    [personClient getAuthorizedPeopleWithCompletion:^(MHVGetAuthorizedPeopleResult * _Nullable authorizedPeople, NSError * _Nullable error)
                     {
                         returnedAuthorizedPeople = authorizedPeople;
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have authorized people", ^
                   {
                       [[expectFutureValue(returnedAuthorizedPeople) shouldEventually] beNonNil];
                   });
                it(@"should have 1 authorized people", ^
                   {
                       [[expectFutureValue(theValue(returnedAuthorizedPeople.persons.count)) shouldEventually] equal:@(1)];
                   });
                it(@"should have correct authorized name", ^
                   {
                       [[expectFutureValue(theValue(returnedAuthorizedPeople.persons.count)) shouldEventually] equal:@(1)];
                       
                       [[[returnedAuthorizedPeople.persons objectAtIndex:0].name should] equal:@"Mike B"];
                   });
            });
    
    context(@"GetAuthorizedPeople error response", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = kHealthVaultErrorXml;
                    
                    [personClient getAuthorizedPeopleWithCompletion:^(MHVGetAuthorizedPeopleResult * _Nullable authorizedPeople, NSError * _Nullable error)
                     {
                         returnedAuthorizedPeople = authorizedPeople;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should not have authorized people", ^
                   {
                       [[expectFutureValue(returnedAuthorizedPeople) shouldEventually] beNil];
                   });
            });

    context(@"GetAuthorizedPeopleSettings success", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedPeople\"><response-results><person-info><person-id>5370f5ce-de91-4fff-b830-90c40d483941</person-id><name>Mike B</name><record id=\"4c4c84fd-b5d0-48ff-8038-17c8f1b084d5\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Mike B\" state=\"Active\" date-created=\"2015-10-09T15:28:42.397Z\" max-size-bytes=\"4294967296\" size-bytes=\"30065480\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793271\" location-country=\"US\" date-updated=\"2017-06-13T00:24:30.333Z\" latest-operation-sequence-number=\"860\" record-app-auth-created-date=\"2017-06-13T00:24:30.333Z\">Mike B</record><record id=\"8698144d-c29a-46c2-a20c-baa9c847140d\" record-custodian=\"true\" rel-type=\"2\" rel-name=\"Other\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test\" state=\"Active\" date-created=\"2017-04-28T20:44:46.537Z\" max-size-bytes=\"4294967296\" size-bytes=\"31586376\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793272\" location-country=\"US\" date-updated=\"2017-06-13T00:24:30.4Z\" latest-operation-sequence-number=\"146\" record-app-auth-created-date=\"2017-06-13T00:24:30.4Z\">Test SubPerson</record><record id=\"432f684f-26f9-4e25-a9fe-5375ddaa0bc0\" record-custodian=\"true\" rel-type=\"13\" rel-name=\"Pet\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test2\" state=\"Active\" date-created=\"2017-06-06T15:23:40.533Z\" max-size-bytes=\"4294967296\" size-bytes=\"57470\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793273\" location-country=\"US\" location-state-province=\"WA\" date-updated=\"2017-06-13T00:24:30.46Z\" latest-operation-sequence-number=\"14\" record-app-auth-created-date=\"2017-06-13T00:24:30.46Z\">Test2 Test2</record><preferred-culture><language>en-US</language></preferred-culture><preferred-uiculture><language>en-US</language></preferred-uiculture><location><country>US</country></location></person-info><more-results>false</more-results></response-results></wc:info></response>";
                    
                    [personClient getAuthorizedPeopleWithSettings:[MHVGetAuthorizedPeopleSettings new]
                                                       completion:^(MHVGetAuthorizedPeopleResult * _Nullable authorizedPeople, NSError * _Nullable error)
                     {
                         returnedAuthorizedPeople = authorizedPeople;
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have authorized people", ^
                   {
                       [[expectFutureValue(returnedAuthorizedPeople) shouldEventually] beNonNil];
                   });
                it(@"should have 1 authorized people", ^
                   {
                       [[expectFutureValue(theValue(returnedAuthorizedPeople.persons.count)) shouldEventually] equal:@(1)];
                   });
                it(@"should have correct authorized name", ^
                   {
                       [[expectFutureValue(theValue(returnedAuthorizedPeople.persons.count)) shouldEventually] equal:@(1)];
                       
                       [[[returnedAuthorizedPeople.persons objectAtIndex:0].name should] equal:@"Mike B"];
                   });
            });
    
    context(@"GetAuthorizedPeopleSettings error response", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = kHealthVaultErrorXml;
                    
                    [personClient getAuthorizedPeopleWithSettings:[MHVGetAuthorizedPeopleSettings new]
                                                       completion:^(MHVGetAuthorizedPeopleResult * _Nullable authorizedPeople, NSError * _Nullable error)
                     {
                         returnedAuthorizedPeople = authorizedPeople;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should not have authorized people", ^
                   {
                       [[expectFutureValue(returnedAuthorizedPeople) shouldEventually] beNil];
                   });
            });

    context(@"GetAuthorizedPeopleSettings parameter error", ^
            {
                beforeEach(^{
                    // Mock response for GetApplicationSettings
                    responseString = kHealthVaultErrorXml;
                    
                    MHVGetAuthorizedPeopleSettings *nilSettings = nil;
                    
                    [personClient getAuthorizedPeopleWithSettings:nilSettings
                                                       completion:^(MHVGetAuthorizedPeopleResult * _Nullable authorizedPeople, NSError * _Nullable error)
                     {
                         returnedAuthorizedPeople = authorizedPeople;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should have required parameter error code", ^
                   {
                       [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                it(@"should not have authorized people", ^
                   {
                       [[expectFutureValue(returnedAuthorizedPeople) shouldEventually] beNil];
                   });
            });

#pragma mark - GetPersonInfo
    
    context(@"GetPersonInfo success", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetPersonInfo\"><person-info><person-id>3333-1fa2-4ac1-b62f-2b0cef201611</person-id><name>TestName</name><app-settings><data>0000</data></app-settings><record id=\"RECORD-ID\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Mike B\" state=\"Active\" date-created=\"2015-10-09T15:28:42.397Z\" max-size-bytes=\"4294967296\" size-bytes=\"30059559\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793179\" location-country=\"US\" date-updated=\"2017-06-07T17:49:56.53Z\" latest-operation-sequence-number=\"847\" record-app-auth-created-date=\"2017-06-07T17:49:56.53Z\">TestName</record><preferred-culture><language>en-US</language></preferred-culture><preferred-uiculture><language>en-US</language></preferred-uiculture><location><country>US</country></location></person-info></wc:info></response>";
                    
                    [personClient getPersonInfoWithCompletion:^(MHVPersonInfo * _Nullable person, NSError * _Nullable error)
                     {
                         returnedPersonInfo = person;
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have person info", ^
                   {
                       [[expectFutureValue(returnedPersonInfo) shouldEventually] beNonNil];
                   });
                it(@"should have person info", ^
                   {
                       [[expectFutureValue(returnedPersonInfo.name) shouldEventually] equal:@"TestName"];
                       [[expectFutureValue(returnedPersonInfo.applicationSettings.xmlSettings) shouldEventually] equal:@"<data>0000</data>"];
                   });
            });
    
    context(@"GetPersonInfo error response", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = kHealthVaultErrorXml;
                    
                    [personClient getPersonInfoWithCompletion:^(MHVPersonInfo * _Nullable person, NSError * _Nullable error)
                     {
                         returnedPersonInfo = person;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should not have person info", ^
                   {
                       [[expectFutureValue(returnedPersonInfo) shouldEventually] beNil];
                   });
            });
    
#pragma mark - GetAuthorizedRecords
    
    context(@"GetAuthorizedRecords success", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetAuthorizedRecords\"><record id=\"6c812547-d1d0-439c-bb0a-f6e6b756547a\" record-custodian=\"true\" rel-type=\"1\" rel-name=\"Self\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Mike B\" state=\"Active\" date-created=\"2015-10-09T15:28:42.397Z\" max-size-bytes=\"4294967296\" size-bytes=\"30059559\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793202\" location-country=\"US\" date-updated=\"2017-06-08T17:05:37.72Z\" latest-operation-sequence-number=\"848\" record-app-auth-created-date=\"2017-06-08T17:05:37.72Z\">Mike B</record><record id=\"88d8a957-b8e4-426f-8fc7-dae8b76da6ef\" record-custodian=\"true\" rel-type=\"2\" rel-name=\"Other\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test\" state=\"Active\" date-created=\"2017-04-28T20:44:46.537Z\" max-size-bytes=\"4294967296\" size-bytes=\"24137673\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793203\" location-country=\"US\" date-updated=\"2017-06-08T17:05:37.773Z\" latest-operation-sequence-number=\"129\" record-app-auth-created-date=\"2017-06-08T17:05:37.773Z\">Test SubPerson</record><record id=\"d5f885e6-30f1-47f2-9abd-7bce6142bd73\" record-custodian=\"true\" rel-type=\"13\" rel-name=\"Pet\" auth-expires=\"9999-12-31T23:59:59.999Z\" display-name=\"Test2\" state=\"Active\" date-created=\"2017-06-06T15:23:40.533Z\" max-size-bytes=\"4294967296\" size-bytes=\"57470\" app-record-auth-action=\"NoActionRequired\" app-specific-record-id=\"793204\" location-country=\"US\" location-state-province=\"WA\" date-updated=\"2017-06-08T17:05:37.83Z\" latest-operation-sequence-number=\"9\" record-app-auth-created-date=\"2017-06-08T17:05:37.83Z\">Test2 Test2</record></wc:info></response>";
                    
                    [personClient getAuthorizedRecordsWithRecordIds:@[[[NSUUID alloc] initWithUUIDString:@"6c812547-d1d0-439c-bb0a-f6e6b756547a"],
                                                                      [[NSUUID alloc] initWithUUIDString:@"88d8a957-b8e4-426f-8fc7-dae8b76da6ef"],
                                                                      [[NSUUID alloc] initWithUUIDString:@"d5f885e6-30f1-47f2-9abd-7bce6142bd73"]]
                                                         completion:^(MHVRecordCollection *_Nullable records, NSError * _Nullable error)
                     {
                         returnedRecords = records;
                         returnedError = error;
                     }];
                });
                
                it(@"should not have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have records", ^
                   {
                       [[expectFutureValue(returnedRecords) shouldEventually] beNonNil];
                   });
                it(@"should have 3 records", ^
                   {
                       [[expectFutureValue(theValue(returnedRecords.count)) shouldEventually] equal:@(3)];
                   });
            });
    
    context(@"GetAuthorizedRecords error response", ^
            {
                beforeEach(^{
                    // Mock response for GetPersonInfo
                    responseString = kHealthVaultErrorXml;
                    
                    [personClient getAuthorizedRecordsWithRecordIds:@[[[NSUUID alloc] initWithUUIDString:@"6c812547-d1d0-439c-bb0a-f6e6b756547a"],
                                                                      [[NSUUID alloc] initWithUUIDString:@"88d8a957-b8e4-426f-8fc7-dae8b76da6ef"],
                                                                      [[NSUUID alloc] initWithUUIDString:@"d5f885e6-30f1-47f2-9abd-7bce6142bd73"]]
                                                         completion:^(MHVRecordCollection *_Nullable records, NSError * _Nullable error)
                     {
                         returnedRecords = records;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should not have records", ^
                   {
                       [[expectFutureValue(returnedRecords) shouldEventually] beNil];
                   });
            });
    
    context(@"GetAuthorizedRecords parameter error", ^
            {
                beforeEach(^{
                    NSArray *nilArray = nil;
                    [personClient getAuthorizedRecordsWithRecordIds:nilArray
                                                         completion:^(MHVRecordCollection *_Nullable records, NSError * _Nullable error)
                     {
                         returnedRecords = records;
                         returnedError = error;
                     }];
                });
                
                it(@"should have errors", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
                it(@"should have required parameter error code", ^
                   {
                       [[expectFutureValue(theValue(returnedError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                it(@"should not have records", ^
                   {
                       [[expectFutureValue(returnedRecords) shouldEventually] beNil];
                   });
            });
});
    
    SPEC_END
