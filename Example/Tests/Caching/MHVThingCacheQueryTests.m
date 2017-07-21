//
//  MHVThingCacheQueryTests.m
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
#import "MHVThingCache.h"
#import "Kiwi.h"

static NSString *kRecordUUID = @"11111111-aaaa-aaaa-aaaa-111111111111";

SPEC_BEGIN(MHVThingCacheQueryTests)

describe(@"MHVThingCache", ^
{
    __block MHVMockDatabase *database;
    __block MHVThingCache *thingCache;
    __block NSArray<MHVThingQueryResult *> *returnedCollection;
    __block NSError *returnedError;
    
    MHVPersonInfo *testPerson = [MHVPersonInfo new];
    testPerson.records = @[];
    
    MHVRecord *record = [MHVRecord new];
    record.ID = [[NSUUID alloc] initWithUUIDString:kRecordUUID];
    testPerson.records = @[record];
    
    MHVThingCacheConfiguration *cacheConfig = [MHVThingCacheConfiguration new];
    cacheConfig.cacheTypeIds = @[[MHVAllergy typeID],
                                 [MHVWeight typeID]];
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(cacheConfiguration) andReturn:cacheConfig];
    [mockConnection stub:@selector(personInfo) andReturn:testPerson];
    [mockConnection stub:@selector(thingClient) andReturn:nil];
    [mockConnection stub:@selector(applicationId) andReturn:@"app-id-1"];
    
    beforeEach(^
               {
                   database = nil;
                   thingCache = nil;
                   returnedCollection = nil;
                   returnedError = nil;
               });
    
    context(@"when cachedResultsForQueries is called and record has not synced", ^
            {
                beforeEach(^
                           {
                               [mockConnection stub:@selector(personInfo) andReturn:testPerson];
                               
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:[[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                                                                          hasSynced:NO
                                                                                                                   shouldHaveThings:NO]
                                                                              connection:mockConnection];
                               
                               [thingCache cachedResultsForQueries:@[]
                                                          recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                                        completion:^(NSArray<MHVThingQueryResult *> *_Nullable resultCollection, NSError *_Nullable error)
                                {
                                    returnedCollection = resultCollection;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil query result collection", ^
                   {
                       [[expectFutureValue(returnedCollection) shouldEventually] beNil];
                   });
                it(@"should have error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                   });
            });
    
    context(@"when cachedResultsForQueries is called and record has things", ^
            {
                beforeEach(^
                           {
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:[[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                                                                          hasSynced:YES
                                                                                                                   shouldHaveThings:YES]
                                                                              connection:mockConnection];
                               
                               [thingCache cachedResultsForQueries:@[[MHVThingQuery new]]
                                                          recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                                        completion:^(NSArray<MHVThingQueryResult *> *_Nullable resultCollection, NSError *_Nullable error)
                                {
                                    returnedCollection = resultCollection;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have 1 thing in query result collection", ^
                   {
                       [[expectFutureValue(returnedCollection) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(returnedCollection.count)) shouldEventually] equal:theValue(1)];
                   });
            });
    
    context(@"when cachedResultsForQueries is called and database returns error", ^
            {
                beforeEach(^
                           {
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:NO
                                                                    shouldHaveThings:NO];
                               database.errorToReturn = [NSError MHVCacheError:@"DBError"];
                               
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:database
                                                                              connection:mockConnection];
                               
                               [thingCache cachedResultsForQueries:@[]
                                                          recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                                        completion:^(NSArray<MHVThingQueryResult *> *_Nullable resultCollection, NSError *_Nullable error)
                                {
                                    returnedCollection = resultCollection;
                                    returnedError = error;
                                }];
                           });
                
                it(@"should return the database error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNonNil];
                       [[expectFutureValue(returnedError.localizedDescription) shouldEventually] equal:@"The operation couldn’t be completed. DBError"];
                   });
                it(@"should have nil query result collection", ^
                   {
                       [[expectFutureValue(returnedCollection) shouldEventually] beNil];
                   });
            });
    
#pragma mark - Add/Update/Delete Things
    
    context(@"when addThings is called for thing record with no things", ^
            {
                beforeEach(^
                           {
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:YES
                                                                    shouldHaveThings:NO];
                               
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:database
                                                                              connection:mockConnection];
                               
                               [thingCache addThings:@[[MHVAllergy newThing]]
                                            recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                          completion:^(NSError *_Nullable error)
                                {
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have 1 thing for record", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(1)];
                   });
            });
    
    context(@"when updateThings is called for existing database thing", ^
            {
                beforeEach(^
                           {
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:YES
                                                                    shouldHaveThings:YES];
                               
                               MHVThing *thingCopy = [database.database[kRecordUUID].things.firstObject newDeepCopy];
                               thingCopy.key.version = @"NEWVERSION";
                               
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:database
                                                                              connection:mockConnection];
                               
                               [thingCache updateThings:@[thingCopy]
                                               recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                             completion:^(NSError *_Nullable error)
                                {
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have database record with 1 thing", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(1)];
                   });
                it(@"should change existing thing version", ^
                   {
                       [[expectFutureValue(database.database[kRecordUUID].things.firstObject.key.version) shouldEventually] equal:@"NEWVERSION"];
                   });
            });
    
    
    context(@"when deleteThings is called for a thing that exists", ^
            {
                beforeEach(^
                           {
                               database = [[MHVMockDatabase alloc] initWithRecordIds:@[kRecordUUID]
                                                                           hasSynced:YES
                                                                    shouldHaveThings:YES];
                               
                               MHVThing *thingCopy = [database.database[kRecordUUID].things.firstObject newDeepCopy];
                               
                               thingCache = [[MHVThingCache alloc] initWithCacheDatabase:database
                                                                              connection:mockConnection];
                               
                               [thingCache deleteThings:@[thingCopy]
                                               recordId:[[NSUUID alloc] initWithUUIDString:kRecordUUID]
                                             completion:^(NSError *_Nullable error)
                                {
                                    returnedError = error;
                                }];
                           });
                
                it(@"should have nil error", ^
                   {
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                it(@"should have deleted thing and database thing item count is 0", ^
                   {
                       [[expectFutureValue(theValue(database.database[kRecordUUID].things.count)) shouldEventually] equal:theValue(0)];
                   });
            });
});

SPEC_END
