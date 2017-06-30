//
// MHVThingCacheDatabaseTests.m
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
#import "MHVThingCacheDatabase.h"
#import "MHVKeychainService.h"
#import "Kiwi.h"

static NSString *kRecordOneUUID = @"11111111-1111-1111-1111-111111111111";
static NSString *kRecordTwoUUID = @"22222222-2222-2222-2222-222222222222";

SPEC_BEGIN(MHVThingCacheDatabaseTests)

describe(@"MHVThingCacheDatabase", ^
{
    KWMock *mockFileManager = [KWMock mockForClass:[NSFileManager class]];
    
    [mockFileManager stub:@selector(URLsForDirectory:inDomains:) andReturn:@[[[NSURL alloc] initFileURLWithPath:@"/mock/path/"]]];
    [mockFileManager stub:@selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)];
    [mockFileManager stub:@selector(fileExistsAtPath:) andReturn:theValue(YES)];
    

    let(database, ^
    {
        id<MHVThingCacheDatabaseProtocol> database = [[MHVThingCacheDatabase alloc] initWithKeychainService:[MHVKeychainService new]
                                                                                                fileManager:mockFileManager];
        
        return database;
    });

#pragma mark - Records

    context(@"when new record created", ^
            {
                beforeEach(^
                           {
                               [database newRecord:kRecordOneUUID];
                           });
                
                it(@"it should retrieveable", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[record should] beNonNil];
                   });

                it(@"it should have correct ID", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[[database recordIdFromRecord:record] should] equal:kRecordOneUUID];
                   });

                it(@"database should have one record", ^
                   {
                       __block NSArray *returnedRecords;
                       [database fetchCachedRecords:^(NSArray<id<MHVCachedRecord>> *_Nullable records)
                        {
                            returnedRecords = records;
                        }];
                       
                       [[expectFutureValue(returnedRecords) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(returnedRecords.count)) shouldEventually] equal:theValue(1)];
                   });
            });

    context(@"when two records created", ^
            {
                beforeEach(^
                           {
                               [database newRecord:kRecordOneUUID];
                               [database newRecord:kRecordTwoUUID];
                           });
                
                it(@"they should retrieveable", ^
                   {
                       NSObject<MHVCachedRecord> *recordOne = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       NSObject<MHVCachedRecord> *recordTwo = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordTwoUUID];
                       
                       [[recordOne should] beNonNil];
                       [[recordTwo should] beNonNil];
                   });
                
                it(@"database should have two records", ^
                   {
                       __block NSArray *returnedRecords;
                       [database fetchCachedRecords:^(NSArray<id<MHVCachedRecord>> *_Nullable records)
                        {
                            returnedRecords = records;
                        }];
                       
                       [[expectFutureValue(returnedRecords) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(returnedRecords.count)) shouldEventually] equal:theValue(2)];
                   });
            });

    context(@"when record is updated", ^
            {
                beforeEach(^
                           {
                               id<MHVCachedRecord> record = [database newRecord:kRecordOneUUID];
                               
                               [database updateRecord:record
                                         lastSyncDate:[NSDate dateWithTimeIntervalSince1970:60]
                                       sequenceNumber:@(3)];
                           });
                
                it(@"date should should be changed", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[[database lastSyncDateFromRecord:record] should] equal:[NSDate dateWithTimeIntervalSince1970:60]];
                   });
                it(@"sequence number should be changed", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[theValue([database lastSequenceNumberFromRecord:record]) should] equal:@(3)];
                   });
            });

#pragma mark - Things

    context(@"when things added", ^
            {
                __block NSNumber *returnedUpdateItemCount;
                __block NSError *returnedError;
                beforeEach(^
                           {
                               [database newRecord:kRecordOneUUID];
                               
                               MHVThing *thing = [MHVAllergy newThing];
                               MHVAllergy *allergy = thing.allergy;                               
                               allergy.name = [MHVCodableValue fromText:@"Allergy to Nuts"];
                               allergy.allergenType = [MHVCodableValue fromText:@"food"];
                               
                               MHVThingCollection *things = [[MHVThingCollection alloc] initWithThing:thing];
                               
                               [database addOrUpdateThings:things
                                                  recordId:kRecordOneUUID
                                        lastSequenceNumber:99
                                                completion:^(NSInteger updateItemCount, NSError *_Nullable error)
                               {
                                   returnedUpdateItemCount = @(updateItemCount);
                                   returnedError = error;
                               }];
                           });
                
                it(@"it should be successful", ^
                   {
                       [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                       [[expectFutureValue(returnedError) shouldEventually] beNil];
                   });
                
                it(@"sequence number should be updated", ^
                   {
                       [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                       
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[theValue([database lastSequenceNumberFromRecord:record]) should] equal:@(99)];
                   });
            });
    
    //...add tests querying to get things

#pragma mark - Deletes

    context(@"when record deleted", ^
            {
                beforeEach(^
                           {
                               [database newRecord:kRecordOneUUID];
                               
                               [database deleteRecord:kRecordOneUUID];
                           });
                
                it(@"it should no longer return records", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[record should] beNil];
                   });
            });
    
    context(@"when database deleted", ^
            {
                beforeEach(^
                           {
                               [database newRecord:kRecordOneUUID];
                               [database deleteDatabase];
                           });
                
                it(@"it should no longer return records", ^
                   {
                       NSObject<MHVCachedRecord> *record = (NSObject<MHVCachedRecord> *)[database fetchCachedRecord:kRecordOneUUID];
                       
                       [[record should] beNil];
                   });
            });
});

SPEC_END
