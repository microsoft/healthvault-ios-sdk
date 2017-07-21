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
    __block id<MHVCacheStatusProtocol> returnedStatus;
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
                   returnedStatus = nil;
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

    context(@"when the setupDatabaseWithCompletion call is successful", ^
            {
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                }];
                           });
                
                it(@"should have a nil error", ^
                   {
                       [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                   });
                it(@"should set file attributes to be protected", ^
                   {
                       [[expectFutureValue(fileAttributes) shouldEventually] beNonNil];
                       [[expectFutureValue(fileAttributes[NSFileProtectionKey]) shouldEventually] equal:NSFileProtectionCompleteUntilFirstUserAuthentication];
                   });
            });

    context(@"when the setupCacheForRecordIds call to create a single record is successful", ^
            {
                __block NSArray *returnedRecords;
                __block NSError *returnedFetchRecordsError;
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                    
                                    [database setupCacheForRecordIds:@[kTestRecordId]
                                                          completion:^(NSError *error)
                                     {
                                         returnedSetupRecordsError = error;

                                         [database fetchCachedRecordIds:^(NSArray<NSString *> *_Nullable recordIds, NSError *_Nullable error)
                                          {
                                              returnedRecords = recordIds;
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
                it(@"should add a cche entry for the record", ^
                   {
                       [[expectFutureValue(returnedFetchRecordsError) shouldEventually] beNil];
                       [[expectFutureValue(theValue(returnedRecords.count)) shouldEventually] equal:@(1)];
                       [[expectFutureValue(theValue([returnedRecords containsObject:kTestRecordId])) shouldEventually] equal:@(YES)];
                   });
            });
    
    context(@"when cacheStatusForRecordId is called for a record that has not been synced and is successful", ^
            {
                beforeEach(^
                           {
                               [database setupDatabaseWithCompletion:^(NSError *error)
                                {
                                    returnedSetupDatabaseError = error;
                                    
                                    [database setupCacheForRecordIds:@[kTestRecordId]
                                                          completion:^(NSError *error)
                                     {
                                         returnedSetupRecordsError = error;
                                         
                                         [database cacheStatusForRecordId:kTestRecordId
                                                               completion:^(id<MHVCacheStatusProtocol> _Nonnull status, NSError *_Nullable error)
                                          {
                                              returnedStatus = status;
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
                it(@"should return status that is valid and has not been synced", ^
                   {
                       [[expectFutureValue(returnedStatus.lastCompletedSyncDate) shouldEventually] beNil];
                       [[expectFutureValue(returnedStatus.lastCacheConsistencyDate) shouldEventually] beNil];
                       [[expectFutureValue(theValue(returnedStatus.newestCacheSequenceNumber)) shouldEventually] equal:theValue(0)];
                       [[expectFutureValue(theValue(returnedStatus.newestHealthVaultSequenceNumber)) shouldEventually] equal:theValue(1)];
                       [[expectFutureValue(theValue(returnedStatus.isCacheValid)) shouldEventually] equal:theValue(YES)];
                   });
            });
    
        context(@"when the call to updateLastCompletedSyncDate is successful", ^
                {
                    __block NSError *returnedUpdateRecordInfoError;
                    __block NSDate *testDate = [NSDate dateWithTimeIntervalSince1970:60];

                    beforeEach(^
                               {
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupCacheForRecordIds:@[kTestRecordId]
                                                              completion:^(NSError *error)
                                         {
                                             returnedSetupRecordsError = error;

                                             [database updateLastCompletedSyncDate:testDate
                                                          lastCacheConsistencyDate:testDate
                                                                    sequenceNumber:3
                                                                          recordId:kTestRecordId
                                                                        completion:^(NSError *_Nullable error)
                                              {
                                                  returnedUpdateRecordInfoError = error;
                                                  
                                                  [database cacheStatusForRecordId:kTestRecordId
                                                                        completion:^(id<MHVCacheStatusProtocol> _Nonnull status, NSError *_Nullable error)
                                                   {
                                                       returnedStatus = status;
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
                    it(@"should update the record", ^
                       {
                           [[expectFutureValue(returnedStatus.lastCompletedSyncDate) shouldEventually] equal:testDate];
                           [[expectFutureValue(returnedStatus.lastCacheConsistencyDate) shouldEventually] equal:testDate];
                           [[expectFutureValue(theValue(returnedStatus.newestCacheSequenceNumber)) shouldEventually] equal:theValue(3)];
                           [[expectFutureValue(theValue(returnedStatus.newestHealthVaultSequenceNumber)) shouldEventually] equal:theValue(3)];
                           [[expectFutureValue(theValue(returnedStatus.isCacheValid)) shouldEventually] equal:theValue(YES)];
                       });
                });
    
    #pragma mark - Things
    
        context(@"when synchronizeThings is called with one new thing and is successful", ^
                {
                    beforeEach(^
                               {
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupCacheForRecordIds:@[kTestRecordId]
                                                              completion:^(NSError *error)
                                         {
                                             MHVThing *thing = [MHVAllergy newThing];
                                             [thing ensureKey];
                                             thing.key.thingID = kTestThingId;
                                             
                                             MHVAllergy *allergy = thing.allergy;
                                             allergy.name = [MHVCodableValue fromText:@"Allergy to Nuts"];
                                             allergy.allergenType = [MHVCodableValue fromText:@"food"];
                                             
                                             NSArray<MHVThing *> *things = @[thing];
                                             
                                             [database synchronizeThings:things
                                                                recordId:kTestRecordId
                                                     batchSequenceNumber:99
                                                    latestSequenceNumber:99
                                                              completion:^(NSInteger synchronizedItemCount, NSError *_Nullable error)
                                              {
                                                  returnedUpdateItemCount = @(synchronizedItemCount);
                                                  returnedUpdateThingsError = error;
                                                  
                                                  [database cacheStatusForRecordId:kTestRecordId
                                                                        completion:^(id<MHVCacheStatusProtocol> _Nonnull status, NSError *_Nullable error)
                                                   {
                                                       returnedStatus = status;
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
                    it(@"should retrun a synchronizedItemCount of exactly 1", ^
                       {
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] equal:@(1)];
                       });
                    it(@"should update the sequence number for the cache", ^
                       {
                           [[expectFutureValue(theValue(returnedStatus.newestCacheSequenceNumber)) shouldEventually] equal:theValue(99)];
                           [[expectFutureValue(theValue(returnedStatus.newestHealthVaultSequenceNumber)) shouldEventually] equal:theValue(99)];
                           [[expectFutureValue(theValue(returnedStatus.isCacheValid)) shouldEventually] equal:theValue(YES)];
                       });
                    
                    it(@"should cache the thing", ^
                       {
                           __block MHVThingQueryResult *returnedQueryResult;
                           __block NSError *returnedQueryError;
                           
                           //Wait for beforeEach above to add the thing
                           [[expectFutureValue(returnedUpdateItemCount) shouldEventually] beNonNil];
                           
                           [database cachedResultForQuery:[[MHVThingQuery alloc] initWithThingID:kTestThingId]
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
    
        context(@"when the resetDatabaseWithCompletion call is successful", ^
                {
                    __block NSError *returnedResetDatabaseError;
                    __block NSNumber *tasksFinished;
                    
                    beforeEach(^
                               {
                                   [database setupDatabaseWithCompletion:^(NSError *error)
                                    {
                                        returnedSetupDatabaseError = error;
                                        
                                        [database setupCacheForRecordIds:@[kTestRecordId]
                                                              completion:^(NSError *error)
                                         {
                                             returnedSetupRecordsError = error;
                                             
                                             fileExistsAtPathReturnValue = NO;
                                             
                                             [database resetDatabaseWithCompletion:^(NSError *error)
                                              {
                                                  returnedResetDatabaseError = error;
                                                  
                                                  [database cacheStatusForRecordId:kTestRecordId
                                                                        completion:^(id<MHVCacheStatusProtocol> _Nonnull status, NSError *_Nullable error)
                                                   {
                                                       tasksFinished = @(YES);
                                                       returnedStatus = status;
                                                       returnedCacheStatusError = error;
                                                   }];
                                              }];
                                         }];
                                    }];
                               });
                    
                    it(@"should have nil for all errors", ^
                       {
                           [[expectFutureValue(tasksFinished) shouldEventually] beNonNil];
                           
                           [[expectFutureValue(returnedSetupDatabaseError) shouldEventually] beNil];
                           [[expectFutureValue(returnedSetupRecordsError) shouldEventually] beNil];
                           [[expectFutureValue(returnedResetDatabaseError) shouldEventually] beNil];
                       });
                    it(@"should have deleted the database file", ^
                       {
                           [[expectFutureValue(tasksFinished) shouldEventually] beNonNil];
                           
                           [[expectFutureValue(removedItemAtURL) shouldEventually] beNonNil];
                       });
                    it(@"should have deleted the password from the keychain", ^
                       {
                           [[expectFutureValue(tasksFinished) shouldEventually] beNonNil];

                           [[expectFutureValue(theValue(deletedFromKeychain)) shouldEventually] beYes];
                       });
                    it(@"should delete the cache for the given record id", ^
                       {
                           [[expectFutureValue(tasksFinished) shouldEventually] beNonNil];

                           [[expectFutureValue(returnedCacheStatusError) shouldEventually] beNonNil];
                           [[expectFutureValue(theValue(returnedCacheStatusError.code)) shouldEventually] equal:theValue(MHVErrorTypeCacheError)];
                           [[expectFutureValue(returnedCacheStatusError.localizedDescription) shouldEventually] equal:@"The operation couldn’t be completed. Record does not exist"];
                           
                           [[expectFutureValue(returnedStatus) shouldEventually] beNil];
                       });
                });
});

SPEC_END
