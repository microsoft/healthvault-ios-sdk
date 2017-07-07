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

static NSString *kTestRecordId = @"11111111-aaaa-1111-1111-111111111111";
static NSString *kTestThingId = @"22222222-bbbb-2222-2222-222222222222";

SPEC_BEGIN(MHVThingCacheDatabaseTests)

describe(@"MHVThingCacheDatabase", ^
{
    __block NSDictionary *fileAttributes;
    __block NSError *returnedSetupDatabaseError;
    __block NSError *returnedSetupRecordsError;
    __block NSNumber *returnedUpdateItemCount;
    __block NSError *returnedUpdateThingsError;
    __block NSDate *returnedLastSyncDate;
    __block NSInteger returnedLastSequenceNumber;
    __block BOOL returnedIsCacheValid;
    __block NSURL *removedItemAtURL;
    __block NSError *returnedCacheStatusError;
    __block BOOL fileExistsAtPathReturnValue = YES;
    __block BOOL deletedFromKeychain = NO;

    //Temp URL (EncryptedCoreData doesn't allow passing in mock file manager, so need a valid temp location)
    NSURL *tempUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    tempUrl = [tempUrl URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    KWMock *mockFileManager = [KWMock mockForClass:[NSFileManager class]];
    [mockFileManager stub:@selector(URLsForDirectory:inDomains:) andReturn:@[tempUrl]];
    [mockFileManager stub:@selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)];
    [mockFileManager stub:@selector(fileExistsAtPath:) andReturn:theValue(fileExistsAtPathReturnValue)];
    [mockFileManager stub:@selector(removeItemAtURL:error:) withBlock:^id (NSArray *params)
     {
         removedItemAtURL = params[0];
         [[NSFileManager defaultManager] removeItemAtURL:removedItemAtURL error:nil];
         
         return @(YES);
     }];
    [mockFileManager stub:@selector(setAttributes:ofItemAtPath:error:) withBlock:^id (NSArray *params)
     {
         fileAttributes = params[0];
         return @(YES);
     }];
    
    KWMock<MHVKeychainServiceProtocol> *mockKeychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    [mockKeychainService stub:@selector(setString:forKey:)];
    [mockKeychainService stub:@selector(removeObjectForKey:)withBlock:^id (NSArray *params)
     {
         deletedFromKeychain = YES;
         return @(YES);
     }];
    [mockKeychainService stub:@selector(stringForKey:) andReturn:@"string"];
    
    let(database, ^
        {
            id<MHVThingCacheDatabaseProtocol> database = [[MHVThingCacheDatabase alloc] initWithKeychainService:mockKeychainService
                                                                                                    fileManager:(NSFileManager *)mockFileManager];
            
            return database;
        });
    
    beforeEach(^
               {
                   [[NSFileManager defaultManager] createDirectoryAtURL:tempUrl withIntermediateDirectories:YES attributes:nil error:nil];
                   
                   returnedSetupDatabaseError = nil;
                   returnedSetupRecordsError = nil;
                   fileAttributes = nil;

                   returnedUpdateItemCount = nil;
                   returnedUpdateThingsError = nil;
                   returnedLastSyncDate = nil;
                   returnedLastSequenceNumber = -1;
                   returnedIsCacheValid = NO;
                   returnedCacheStatusError = nil;
                   removedItemAtURL = nil;
                   fileExistsAtPathReturnValue = YES;
                   deletedFromKeychain = NO;
               });
    
    afterEach(^
    {
        [[NSFileManager defaultManager] removeItemAtURL:tempUrl error:nil];
    });
    
#pragma mark - Records

    context(@"when setupDatabaseWithCompletion is called", ^
            {
                __block NSArray *returnedRecords;
                __block NSError *returnedFetchRecordsError;
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                }];
                           });
                
                it(@"should have nil error", ^
                   {
                       [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                   });
                it(@"should set file attributes to be protected", ^
                   {
                       [[expectFutureValue(fileAttributes) shouldEventually] beNonNil];
                       [[expectFutureValue(fileAttributes[NSFileProtectionKey]) shouldEventually] equal:NSFileProtectionCompleteUntilFirstUserAuthentication];
                   });
            });

    context(@"when setupRecordIds is called to create a new record", ^
            {
                __block NSArray *returnedRecords;
                __block NSError *returnedFetchRecordsError;
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                    
                                    [database setupRecordIds:@[kTestRecordId]
                                                  completion:^(NSError *error)
                                     {
                                         returnedSetupRecordsError = error;

                                         [database fetchCachedRecordIds:^(NSArray<NSString *> *_Nullable records, NSError *_Nullable error)
                                          {
                                              returnedRecords = records;
                                              returnedFetchRecordsError = error;
                                          }];
                                     }];
                                }];
                           });
                
                it(@"should have nil for all errors", ^
                   {
                       [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                       [[expectFutureValue(returnedSetupRecordsError) shouldEventually] beNil];
                       [[expectFutureValue(returnedFetchRecordsError) shouldEventually] beNil];
                   });
                it(@"fetchCachedRecordIds should return the newly added record", ^
                   {
                       [[expectFutureValue(returnedFetchRecordsError) shouldEventually] beNil];
                       [[expectFutureValue(theValue(returnedRecords.count)) shouldEventually] equal:@(1)];
                       [[expectFutureValue(theValue([returnedRecords containsObject:kTestRecordId])) shouldEventually] equal:@(YES)];
                   });
            });
    
    context(@"when cacheStatusForRecordId is called for a new record", ^
            {
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                    
                                    [database setupRecordIds:@[kTestRecordId]
                                                  completion:^(NSError *error)
                                     {
                                         returnedSetupRecordsError = error;
                                         
                                         [database cacheStatusForRecordId:kTestRecordId
                                                               completion:^(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error)
                                          {
                                              returnedLastSyncDate = lastSyncDate;
                                              returnedLastSequenceNumber = lastSequenceNumber;
                                              returnedIsCacheValid = isCacheValid;
                                              returnedCacheStatusError = error;
                                          }];
                                     }];
                                }];
                           });
                
                it(@"should have nil for all errors", ^
                   {
                       [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                       [[expectFutureValue(returnedSetupRecordsError) shouldEventually] beNil];
                       [[expectFutureValue(returnedCacheStatusError) shouldEventually] beNil];
                   });
                it(@"should return record that is valid and has not been synced", ^
                   {
                       [[expectFutureValue(returnedLastSyncDate) shouldEventually] beNil];
                       [[expectFutureValue(theValue(returnedLastSequenceNumber)) shouldEventually] equal:@(0)];
                       [[expectFutureValue(theValue(returnedIsCacheValid)) shouldEventually] equal:@(YES)];
                   });
            });
    
        context(@"when updateRecordId is called", ^
                {
                    __block NSError *returnedUpdateRecordInfoError;

                    beforeEach(^
                               {
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupRecordIds:@[kTestRecordId]
                                                      completion:^(NSError *error)
                                         {
                                             returnedSetupRecordsError = error;

                                             [database updateRecordId:kTestRecordId
                                                         lastSyncDate:[NSDate dateWithTimeIntervalSince1970:60]
                                                       sequenceNumber:@(3)
                                                           completion:^(NSError *_Nullable error)
                                              {
                                                  returnedUpdateRecordInfoError = error;
                                                  
                                                  [database cacheStatusForRecordId:kTestRecordId
                                                                        completion:^(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error)
                                                   {
                                                       returnedLastSyncDate = lastSyncDate;
                                                       returnedLastSequenceNumber = lastSequenceNumber;
                                                       returnedIsCacheValid = isCacheValid;
                                                       returnedCacheStatusError = error;
                                                   }];
                                              }];
                                         }];
                                    }];
                               });
    
                    it(@"should have nil for all errors", ^
                       {
                           [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                           [[expectFutureValue(returnedSetupRecordsError) shouldEventually] beNil];
                           [[expectFutureValue(returnedUpdateRecordInfoError) shouldEventually] beNil];
                           [[expectFutureValue(returnedCacheStatusError) shouldEventually] beNil];
                       });
                    it(@"date should should be the updated date", ^
                       {
                           [[expectFutureValue(returnedLastSyncDate) shouldEventually] equal:[NSDate dateWithTimeIntervalSince1970:60]];
                       });
                    it(@"sequence number should be updated number", ^
                       {
                           [[expectFutureValue(theValue(returnedLastSequenceNumber)) shouldEventually] equal:@(3)];
                       });
                    it(@"record should be valid", ^
                       {
                           [[expectFutureValue(theValue(returnedIsCacheValid)) shouldEventually] beYes];
                       });
                });
    
    #pragma mark - Things
    
        context(@"when addOrUpdateThings is called to add a thing", ^
                {
                    beforeEach(^
                               {
                                   __weak __typeof__(database)weakDatabase = database;
                                   
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupRecordIds:@[kTestRecordId]
                                                      completion:^(NSError *error)
                                         {
                                             MHVThing *thing = [MHVAllergy newThing];
                                             [thing ensureKey];
                                             thing.key.thingID = kTestThingId;
                                             
                                             MHVAllergy *allergy = thing.allergy;
                                             allergy.name = [MHVCodableValue fromText:@"Allergy to Nuts"];
                                             allergy.allergenType = [MHVCodableValue fromText:@"food"];
                                             
                                             MHVThingCollection *things = [[MHVThingCollection alloc] initWithThing:thing];
                                             
                                             [weakDatabase addOrUpdateThings:things
                                                                    recordId:kTestRecordId
                                                          lastSequenceNumber:99
                                                                  completion:^(NSInteger updateItemCount, NSError *_Nullable error)
                                              {
                                                  returnedUpdateItemCount = @(updateItemCount);
                                                  returnedUpdateThingsError = error;
                                                  
                                                  [weakDatabase cacheStatusForRecordId:kTestRecordId
                                                                            completion:^(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error)
                                                   {
                                                       returnedLastSyncDate = lastSyncDate;
                                                       returnedLastSequenceNumber = lastSequenceNumber;
                                                       returnedIsCacheValid = isCacheValid;
                                                       returnedCacheStatusError = error;
                                                   }];
                                              }];
                                         }];
                                    }];
                               });
    
                    it(@"should have nil for all errors", ^
                       {
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                           [[expectFutureValue(returnedUpdateThingsError) shouldEventually] beNil];
                       });
                    it(@"added item count should be 1", ^
                       {
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] equal:@(1)];
                       });
                    it(@"cacheStatusForRecordId should have updated sequence number", ^
                       {
                           [[expectFutureValue(returnedLastSyncDate) shouldEventually] beNonNil];
                           [[expectFutureValue(theValue(returnedLastSequenceNumber)) shouldEventually] equal:@(99)];
                           [[expectFutureValue(theValue(returnedIsCacheValid)) shouldEventually] equal:@(YES)];
                       });
                    
                    it(@"cachedResultsForQuery can retrieve the new thing", ^
                       {
                           __block MHVThingQueryResult *returnedQueryResult;
                           __block NSError *returnedQueryError;
                           
                           //Wait for beforeEach above to add the thing
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                           
                           [database cachedResultsForQuery:[[MHVThingQuery alloc] initWithThingID:kTestThingId]
                                                  recordId:kTestRecordId
                                                completion:^(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error)
                            {
                                returnedQueryResult = queryResult;
                                returnedQueryError = error;
                            }];
                           
                           [[expectFutureValue(returnedQueryResult) shouldEventually] beNonNil];
                           [[expectFutureValue(theValue(returnedQueryResult.things.count)) shouldEventually] equal:@(1)];
                           [[expectFutureValue(returnedQueryError) shouldEventually] beNil];
                       });
                });
    
#pragma mark - Reset
    
        context(@"when resetDatabaseWithCompletion is called", ^
                {
                    __block NSError *returnedResetDatabaseError;
                    
                    beforeEach(^
                               {
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupRecordIds:@[kTestRecordId]
                                                      completion:^(NSError *error)
                                         {
                                             returnedSetupRecordsError = error;
                                             
                                             fileExistsAtPathReturnValue = NO;
                                             
                                             [database resetDatabaseWithCompletion:^(NSError *error)
                                              {
                                                  returnedResetDatabaseError = error;
                                                  
                                                  [database cacheStatusForRecordId:kTestRecordId
                                                                            completion:^(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error)
                                                   {
                                                       returnedLastSyncDate = lastSyncDate;
                                                       returnedLastSequenceNumber = lastSequenceNumber;
                                                       returnedIsCacheValid = isCacheValid;
                                                       returnedCacheStatusError = error;
                                                   }];
                                              }];
                                         }];
                                    }];
                               });
                    
                    it(@"should have nil for all reset errors", ^
                       {
                           [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                           [[expectFutureValue(returnedSetupRecordsError) shouldEventually] beNil];
                           [[expectFutureValue(returnedResetDatabaseError) shouldEventually] beNil];
                       });
                    it(@"should have deleted the database file", ^
                       {
                           [[expectFutureValue(removedItemAtURL) shouldEventually] beNonNil];
                       });
                    it(@"should have deleted the password from the keychain", ^
                       {
                           [[expectFutureValue(theValue(deletedFromKeychain)) shouldEventually] beYes];
                       });
                    it(@"should have error calling cacheStatusForRecordId for deleted record", ^
                       {
                           [[expectFutureValue(returnedCacheStatusError) shouldEventually] beNonNil];
                           
                           [[expectFutureValue(returnedLastSyncDate) shouldEventually] beNil];
                           [[expectFutureValue(theValue(returnedLastSequenceNumber)) shouldEventually] equal:@(0)];
                           [[expectFutureValue(theValue(returnedIsCacheValid)) shouldEventually] equal:@(NO)];
                       });
                });
});

SPEC_END
