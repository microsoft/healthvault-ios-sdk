//
//  MHVThingCacheSynchronizerTests.m
//  healthvault-ios-sdk
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVMockDatabase.h"
#import "Kiwi.h"

static NSString *kRecordUUID = @"11111111-aaaa-aaaa-aaaa-111111111111";

SPEC_BEGIN(MHVThingCacheSynchronizerTests)

describe(@"MHVThingCacheSynchronizerTests", ^
{
    __block NSString *xmlResponseGetRecordOperations;
    __block NSString *xmlResponseGetThings;
    __block MHVThingCacheSynchronizer *thingCacheSynchronizer;
    __block NSError *returnedError;
    __block NSInteger returnedSyncedItemCount = 0;
    __block MHVMockDatabase *database =  nil;
    MHVPersonInfo *testPerson = [MHVPersonInfo new];
    
    MHVRecord *record = [MHVRecord new];
    record.ID = [[NSUUID alloc] initWithUUIDString:kRecordUUID];
    testPerson.records = @[record];
    
    MHVThingCacheConfiguration *cacheConfig = [MHVThingCacheConfiguration new];
    cacheConfig.cacheTypeIds = @[[MHVAllergy typeID],
                                 [MHVWeight typeID]];
    
    KWMock<MHVNetworkObserverProtocol> *networkObserver = [KWMock mockForProtocol:@protocol(MHVNetworkObserverProtocol)];
    [networkObserver stub:@selector(currentNetworkStatus) andReturn:theValue(1)];
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(cacheConfiguration) andReturn:cacheConfig];
    [mockConnection stub:@selector(personInfo) andReturn:testPerson];
    
    MHVThingClient *thingClient = [[MHVThingClient alloc] initWithConnection:mockConnection
                                                       cache:nil];
    [mockConnection stub:@selector(thingClient) andReturn:thingClient];
    
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id(NSArray *params)
    {
         NSString *xmlResponse;
         if (xmlResponseGetRecordOperations)
         {
             xmlResponse = xmlResponseGetRecordOperations;
             xmlResponseGetRecordOperations = nil;
         }
         else
         {
             xmlResponse = xmlResponseGetThings;
         }
         
         MHVHttpServiceResponse *httpResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[xmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                          statusCode:0];
         
         MHVServiceResponse *serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:httpResponse
                                                                                         isXML:YES];
         
         void (^completion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
         completion(serviceResponse, serviceResponse.error);
         return nil;
    }];
    
    beforeEach(^
               {
                   xmlResponseGetRecordOperations = nil;
                   xmlResponseGetThings = nil;
                   returnedError = nil;
                   returnedSyncedItemCount = 0;
                   database =  nil;
               });
    
    context(@"when syncWithOptions is called with valid record operations for thing creation", ^
            {
                beforeEach(^
                           {
                               //Mock GetRecordOperations, so have things to retrieve
                               xmlResponseGetRecordOperations = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetRecordOperations\"><latest-record-operation-sequence-number>959</latest-record-operation-sequence-number><operations><record-operation><operation>Create</operation><sequence-number>959</sequence-number><thing-id version-stamp=\"11d99ccc-ee45-4748-9076-ef005634b04d\">a01e7b0b-9ab1-40d9-b172-d5035d1620d7</thing-id><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><eff-date>2017-07-05T06:24:58</eff-date><updated-end-date>2017-07-05T06:24:58</updated-end-date></record-operation></operations></wc:info></response>";
                               
                               //Mock GetThings
                               xmlResponseGetThings = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\"><group name=\"648F6C9F-9B07-4272-89F4-19F923D1C65E\"><thing><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id><type-id name=\"File\">bd0403c5-4ae2-4b0e-a8db-1888678e4528</type-id><thing-state>Active</thing-state><flags>0</flags><eff-date>2017-06-02T22:01:52.471</eff-date><data-xml><common /></data-xml></thing></group></wc:info></response>";
                               
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:NO
                                                                    shouldHaveThings:NO];
                               
                               thingCacheSynchronizer = [[MHVThingCacheSynchronizer alloc] initWithCacheDatabase:database
                                                                                                 networkObserver:networkObserver];
                               
                               thingCacheSynchronizer.connection = mockConnection;
                               
                               [thingCacheSynchronizer syncWithOptions:MHVCacheOptionsForeground
                                                            completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                {
                                    returnedSyncedItemCount = syncedItemCount;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil for error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have synced item count equal 1", ^
                   {
                       [[expectFutureValue(theValue(returnedSyncedItemCount)) shouldEventually] equal:theValue(1)];
                   });
                it(@"should have database record's thing count equal 1", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(1)];
                   });
            });
    
    context(@"when syncWithOptions is called with valid record operations for thing deletion", ^
            {
                beforeEach(^
                           {
                               //Mock GetRecordOperations, so have things to retrieve
                               xmlResponseGetRecordOperations = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetRecordOperations\"><latest-record-operation-sequence-number>959</latest-record-operation-sequence-number><operations><record-operation><operation>Delete</operation><sequence-number>959</sequence-number><thing-id version-stamp=\"version-id-1\">thing-id-1</thing-id><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><eff-date>2017-07-05T06:24:58</eff-date><updated-end-date>2017-07-05T06:24:58</updated-end-date></record-operation></operations></wc:info></response>";
                               
                               //Mock GetThings
                               xmlResponseGetThings = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\"></wc:info></response>";
                               
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:NO
                                                                    shouldHaveThings:YES];
                               
                               thingCacheSynchronizer = [[MHVThingCacheSynchronizer alloc] initWithCacheDatabase:database
                                                                                                 networkObserver:networkObserver];
                               
                               thingCacheSynchronizer.connection = mockConnection;
                               
                               [thingCacheSynchronizer syncWithOptions:MHVCacheOptionsForeground
                                                            completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                {
                                    returnedSyncedItemCount = syncedItemCount;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil for error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have synced item count equal 1", ^
                   {
                       [[expectFutureValue(theValue(returnedSyncedItemCount)) shouldEventually] equal:theValue(1)];
                   });
                it(@"should have database record's thing count equal 0", ^
                   {
                       [[expectFutureValue(theValue(returnedSyncedItemCount)) shouldEventually] equal:theValue(1)];
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(0)];
                   });
            });
    
    context(@"when syncWithOptions is called with error for record operations", ^
            {
                beforeEach(^
                           {
                               //Mock GetRecordOperations, so have things to retrieve
                               xmlResponseGetRecordOperations = @"<response><status><code>3</code><error><message>Test Error.</message></error></status></response>";
                               
                               //Mock GetThings
                               xmlResponseGetThings = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\"></wc:info></response>";
                               
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:NO
                                                                    shouldHaveThings:YES];
                               
                               thingCacheSynchronizer = [[MHVThingCacheSynchronizer alloc] initWithCacheDatabase:database
                                                                                                 networkObserver:networkObserver];
                               
                               thingCacheSynchronizer.connection = mockConnection;
                               
                               [thingCacheSynchronizer syncWithOptions:MHVCacheOptionsForeground
                                                            completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                {
                                    returnedSyncedItemCount = syncedItemCount;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have an error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                       [[expectFutureValue(returnedError.localizedDescription) shouldEventually] equal:@"The operation couldn’t be completed. Test Error.\n(null)\n(null)"];
                   });
                it(@"should have synced item count equal 0", ^
                   {
                       [[expectFutureValue(theValue(returnedSyncedItemCount)) shouldEventually] equal:theValue(0)];
                   });
                it(@"should have database record's thing count equal 1", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(1)];
                   });
            });
    
    context(@"when syncWithOptions is called with valid record operations and error for GetThings", ^
            {
                beforeEach(^
                           {
                               //Mock GetRecordOperations, so have things to retrieve
                               xmlResponseGetRecordOperations = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetRecordOperations\"><latest-record-operation-sequence-number>959</latest-record-operation-sequence-number><operations><record-operation><operation>Create</operation><sequence-number>959</sequence-number><thing-id version-stamp=\"11d99ccc-ee45-4748-9076-ef005634b04d\">a01e7b0b-9ab1-40d9-b172-d5035d1620d7</thing-id><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><eff-date>2017-07-05T06:24:58</eff-date><updated-end-date>2017-07-05T06:24:58</updated-end-date></record-operation></operations></wc:info></response>";
                               
                               //Mock GetThings
                               xmlResponseGetThings = @"<response><status><code>3</code><error><message>Test Error.</message></error></status></response>";
                               
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:NO
                                                                    shouldHaveThings:NO];
                               
                               thingCacheSynchronizer = [[MHVThingCacheSynchronizer alloc] initWithCacheDatabase:database
                                                                                                 networkObserver:networkObserver];
                               
                               thingCacheSynchronizer.connection = mockConnection;
                               
                               [thingCacheSynchronizer syncWithOptions:MHVCacheOptionsForeground
                                                            completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                {
                                    returnedSyncedItemCount = syncedItemCount;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have an error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                       [[expectFutureValue(returnedError.localizedDescription) shouldEventually] equal:@"The operation couldn’t be completed. Test Error.\n(null)\n(null)"];
                   });
                it(@"should have synced item count equal 0", ^
                   {
                       [[expectFutureValue(theValue(returnedSyncedItemCount)) shouldEventually] equal:theValue(0)];
                   });
                it(@"should have database record's thing count equal 0", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(0)];
                   });
            });
});

SPEC_END
