//
//  MHVThingCacheDatabaseProtocol.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class MHVThingCollection, MHVThingQuery, MHVThingQueryResult;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheDatabaseProtocol <NSObject>

/**
 Initialize and setup database if needed.
 This is called after a user has authenticated, and may be called after deleteDatabase
 when signing out and signing in again

 @return Error if there was an error
 */
- (NSError *_Nullable)setupDatabase;

/**
 Delete the current database
 
 @return NSError for any errors deleting the database
 */
- (NSError *_Nullable)deleteDatabase;

/**
 Determine if a record exists
 
 @param recordId the RecordID to find
 @return CachedRecord matching the ID or nil
 @note This operation is synchronous
 */
- (BOOL)hasRecordId:(NSString *)recordId;

/**
 Create a new database record given a recordId if it does not exist

 @param recordId The record ID
 @return Error if there was an error 
 */
- (NSError *_Nullable)newRecordForRecordId:(NSString *)recordId;

/**
 Delete a record from the current database

 @param recordId id of the record to be deleted
 @note This operation is synchronous
 */
- (NSError *_Nullable)deleteRecord:(NSString *)recordId;

/**
 Delete Things given an array of IDs

 @param thingIds the IDs of the things to be deleted
 @param recordId the RecordId of the owner of the things
 @note This operation is synchronous
 @return error for any save errors
 */
- (NSError *_Nullable)deleteThingIds:(NSArray<NSString *> *)thingIds recordId:(NSString *)recordId;

/**
 Update or create things in the cache database for a Thing collection

 @param things collection of Things to be added or updated
 @param recordId the owner record of the Things
 @param lastSequenceNumber the new sequence number to use after updating
 @param completion Envoked when the operation is complete
 */
- (void)addOrUpdateThings:(MHVThingCollection *)things
                 recordId:(NSString *)recordId
       lastSequenceNumber:(NSInteger)lastSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion;

/**
 Retrieve things for a query

 @param query The GetThings query
 @param recordId the owner record of the Things
 @param completion Envoked with the MHVThingQueryResult
 */
- (void)cachedResultsForQuery:(MHVThingQuery *)query
                     recordId:(NSString *)recordId
                   completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion;

/**
 Fetch all cached records

 @param completion Envoked with the array of records
 */
- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable records, NSError *_Nullable error))completion;

/**
 Get the last sync date from an id<MHVCachedRecord> object
 
 @param recordId The record ID
 @return NSDate of the last sync
 */
- (NSDate *_Nullable)lastSyncDateFromRecordId:(NSString *)recordId;

/**
 Get the last sync date from an id<MHVCachedRecord> object

 @param recordId The record ID
 @return NSInteger for last sequence number
 */
- (NSInteger)lastSequenceNumberFromRecordId:(NSString *)recordId;

/**
 Determine if the cache is valid for a record
 
 @param recordId The record ID
 @return BOOL if cache is valid
 */
- (BOOL)isCacheValidForRecordId:(NSString *)recordId;

/**
 Set the cache info for a record to be invalid
 Setting to invalid will reset the sequence number to 0 so all data will be re-synced

 @param recordId The record ID
 */
- (void)setCacheInvalidForRecordId:(NSString *)recordId;

/**
 Update a record with a new date and/or sequence number

 @param record The record
 @param lastSyncDate NSDate to update, should not update date on the record if nil
 @param sequenceNumber NSNumber sequence number, should not update number on the record if nil
 @return NSError if any error occurred
 */
- (NSError *_Nullable)updateRecordId:(NSString *)record lastSyncDate:(NSDate *_Nullable)lastSyncDate sequenceNumber:(NSNumber *_Nullable)sequenceNumber;

@end

NS_ASSUME_NONNULL_END
