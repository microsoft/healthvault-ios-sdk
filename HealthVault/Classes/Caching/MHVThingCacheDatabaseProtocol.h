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
@class MHVThingCollection;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVCachedRecord

// id<MHVCachedRecord> are treated as opaque objects by MHVThingCache.
// MHVThingCacheDatabaseProtocol methods perform all Record actions needed by the MHVThingCache

@end

@protocol MHVThingCacheDatabaseProtocol <NSObject>

/**
 Create a new cache record given a recordId

 @param recordId The record ID
 @return the cache record
 */
- (id<MHVCachedRecord>)newRecord:(NSString *)recordId;

/**
 Saves changes to the database

 @return error for any save errors
 */
- (NSError *_Nullable)saveContext;

/**
 Delete the current database
 */
- (void)deleteDatabase;

/**
 Delete a record from the current database

 @param recordId id of the record to be deleted
 @note This operation is synchronous
 */
- (void)deleteRecord:(NSString *)recordId;

/**
 Delete Things given an array of IDs

 @param thingIds the IDs of the things to be deleted
 @param recordId the RecordId of the owner of the things
 @note This operation is synchronous
 */
- (void)deleteThingIds:(NSArray<NSString *> *)thingIds recordId:(NSString *)recordId;

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
               completion:(void (^)(BOOL success))completion;

/**
 Fetch all cached records

 @param completion Envoked with the array of records
 */
- (void)fetchCachedRecords:(void(^)(NSArray<id<MHVCachedRecord>> *_Nullable records))completion;

/**
 Retrieve a CachedRecord given a recordId

 @param recordId the RecordID to find
 @return CachedRecord matching the ID or nil
 @note This operation is synchronous
 */
- (id<MHVCachedRecord> _Nullable)fetchCachedRecord:(NSString *)recordId;

/**
 Get the recordId from an id<MHVCachedRecord> object

 @param record The record
 @return recordId for the record
 */
- (NSString *_Nullable)recordIdFromRecord:(id<MHVCachedRecord>)record;

/**
 Get the last sync date from an id<MHVCachedRecord> object
 
 @param record The record
 @return NSDate of the last sync
 */
- (NSDate *_Nullable)lastSyncDateFromRecord:(id<MHVCachedRecord>)record;

/**
 Get the last sync date from an id<MHVCachedRecord> object

 @param record The record
 @return NSInteger for last sequence number
 */
- (NSInteger)lastSequenceNumberFromRecord:(id<MHVCachedRecord>)record;

/**
 Update a record with a new date and/or sequence number

 @param record The record
 @param lastSyncDate NSDate to update, should not update date on the record if nil
 @param sequenceNumber NSNumber sequence number, should not update number on the record if nil
 */
- (void)updateRecord:(id<MHVCachedRecord>)record lastSyncDate:(NSDate *_Nullable)lastSyncDate sequenceNumber:(NSNumber *_Nullable)sequenceNumber;

@end

NS_ASSUME_NONNULL_END
