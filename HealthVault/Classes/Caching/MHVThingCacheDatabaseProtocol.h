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

@class MHVThing, MHVThingQuery, MHVThingQueryResult, MHVPendingMethod;
@protocol MHVCacheStatusProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheDatabaseProtocol <NSObject>

/**
 Called to Initialize and setup database if needed.
 @note This is called immediately after a user has authenticated the application.
 
 @param completion Must be envoked when the operation is complete or if an error occurs.
 */
- (void)setupDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;

/**
 Called after a user has completely de-authorized an application. All user data should be removed from the database.
 @note For multi-record apps this method is called only after the application has been de-authorized for ALL records.
 
 @param completion Must be envoked when the operation is complete or if an error occurs.
 */
- (void)resetDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called after a user has authenticated the application (also after setupDatabaseWithCompletion:) and after the application has been authorized for additional records (multi-record apps).
 
 @param recordIds The record ids
 @param completion Must be envoked when the operation is complete or if an error occurs.
 */
- (void)setupCacheForRecordIds:(NSArray<NSString *> *)recordIds
                    completion:(void (^)(NSError *_Nullable error))completion;

/**
 Deletes all cached Things for a given recordId. This method will be called when a single record is de-authorized.
 
 @param recordId id of the cache to be deleted
 @param completion Must be envoked when the operation is complete or if an error occurs.
 */
- (void)deleteCacheForRecordId:(NSString *)recordId
                    completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called AFTER a Thing (or Things) have been created and successfully added to HealthVault.

 @param things A collection of new things to be added to the cache database.
 @param recordId the RecordId of the owner of the things.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if the creation process could not be completed.
 */
- (void)createCachedThings:(NSArray<MHVThing *> *)things
                  recordId:(NSString *)recordId
                completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called AFTER a Thing (or Things) have been successfully updated in HealthVault.

 @param things A collection of existing things to be updated in the cache database.
 @param recordId the RecordId of the owner of the things.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if the creation process could not be completed.
 */
- (void)updateCachedThings:(NSArray<MHVThing *> *)things
                  recordId:(NSString *)recordId
                completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called AFTER a Thing (or Things) have been successfully deleted from HealthVault.
 @note This method may also be called once during the synchronization process to remove Things that have been deleted from HealthVault but still exsist in the cache.
 
 @param thingIds the IDs of the things to be deleted
 @param recordId the RecordId of the owner of the things
 @param completion Envoked when the operation is complete
 */
- (void)deleteCachedThingsWithThingIds:(NSArray<NSString *> *)thingIds
                              recordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method will be called to synchronize Things from HealthVault to the cache database for a given recordId.
 
 @note The synchronization may include a large number of Things that have been either added or updated in HealthVault. In this case, the data is split into batches that are processed serially. The batchSequenceNumber and latestSequenceNumber parameters are used to determine if all batches have been processed - Where, batchSequenceNumber represents the greatest sequence number for a given batch, and latestSequenceNumber represents the greatest sequence number for all batches. During initial setup of the cache, or after long periods where a sync did not happen, this method will be called repeatedly until batchSequenceNumber = latestSequenceNumber. It's recommended that batchSequenceNumber be saved so if the sync is interupted the process can be continued.
 @param things collection of Things to be synchronized.
 @param recordId the owner record of the Things.
 @param batchSequenceNumber the sequence number with the highest value for all sequences included in the batch.
 @param latestSequenceNumber the newest sequence number for all sequences.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSInteger updateItemCount the number of Things successfully syncronized. NSError error a detailed error if the synchronization process could not be completed.
 */
- (void)synchronizeThings:(NSArray<MHVThing *> *)things
                 recordId:(NSString *)recordId
      batchSequenceNumber:(NSInteger)batchSequenceNumber
     latestSequenceNumber:(NSInteger)latestSequenceNumber
               completion:(void (^)(NSInteger synchronizedItemCount, NSError *_Nullable error))completion;

/**
 This method is called BEFORE issuing a given request to HealthVault and AFTER cacheStatusForRecordId:completion:. Once a cache for a given record has been syncronized, queries will be issued to the cache only.
 @note Before calling this method, cacheStatusForRecordId:completion: will be called to check the status of the cache, If MHVCacheStatusProtocol.isCacheValid == NO or MHVCacheStatusProtocol.lastCacheConsistencyDate == nil, the query will be made directly to HealthVault.
 
 @param query The GetThings query
 @param recordId the owner record of the Things
 @param completion Envoked with the MHVThingQueryResult
 */
- (void)cachedResultForQuery:(MHVThingQuery *)query
                    recordId:(NSString *)recordId
                  completion:(void (^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion;

/**
 This method is called before the start of the sync process to determine which records to sync.
 @note The order the record ids are returned are the order they will be synchronized (The synchronization of each record happens serially).
 
 @param completion MUST be envoked when the operation is complete or an error occurs. NSArray<NSString *> recordIds The record ids that have associated Thing caches. NSError error a detailed error if the operations to get record ids fails.
 */
- (void)fetchCachedRecordIds:(void (^)(NSArray<NSString *> *_Nullable recordIds, NSError *_Nullable error))completion;

/**
 Retrieve status information about a cached record
 
 @param recordId The record ID
 @param completion MUST be envoked when the operation is complete or an error occurs. id<MHVCacheStatusProtocol> status The status of the cache for a given record id. NSError error a detailed error if the operations to get the cache status fails.
 */
- (void)cacheStatusForRecordId:(NSString *)recordId
                    completion:(void (^)(id<MHVCacheStatusProtocol> _Nullable status, NSError *_Nullable error))completion;

/**
 This method is called if a sync operation occurs and there is no new data from HealthVault.
 
 @param lastCompletedSyncDate NSDate the date that the sync operation completed.
 @param lastCacheConsistencyDate NSDate If it can be determined that the cache and HealthVault are consistent after the sync operation this date will be the same as lastCompletedSyncDate. Otherwise it will be nil.
 @param sequenceNumber NSInteger The latest sequence number from HealthVault.
 @param recordId NSString The record Id used to identify a specific cache of Things
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if the update process could not be completed.
 */
- (void)updateLastCompletedSyncDate:(NSDate *_Nullable)lastCompletedSyncDate
           lastCacheConsistencyDate:(NSDate *_Nullable)lastCacheConsistencyDate
                     sequenceNumber:(NSInteger)sequenceNumber
                           recordId:(NSString *)recordId
                         completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called if a CREATE, UPDATE or DELETE operation is attempted while there is no internet connection. If The MHVPendingMethod is cached it will be re-issued at the start of the next synchronization.

 @param pendingMethods NSArray<MHVPendingMethod *> a collection of methods to be cached.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if caching the methods fails.
 */
- (void)cachePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called at the start of the synchronization process to re-issue any MHVPendingMethod requests.
 @note The synchronization process starts by re-issuing pending methods in the original order they were originally issued. Once all pending methods are processed, DELETEs that occured in HealthVault are processed and finally, CREATEs and UPDATEs
 
 @param recordId The record Id used to identify a specific cache of pending methods.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSArray<MHVPendingMethod *> pendingMethods an array of pending methods to be processed. NSError error a detailed error if the fetch process could not be completed.
 */
- (void)fetchPendingMethodsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSArray<MHVPendingMethod *> *_Nullable pendingMethods, NSError *_Nullable error))completion;

/**
 This method is called after an MHVPendingMethod is successfully re-issued, and should be removed from the cache.

 @param pendingMethods NSArray<MHVPendingMethod *> An array of pending methods to be processed. *Note - All MHVPendingMethod objects in the array must have the same recordId.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if caching the method fails.
 */
- (void)deletePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                  completion:(void (^)(NSError *_Nullable error))completion;

/**
 This method is called AFTER a call to createNewThing:recordId:completion: or createNewThings:recordId:completion: occurs and the internet connection is offline. The Thing(s) in the collection should be cached with an identifier that can be used to fetch and delete all 'pending' Things once the internet connection is restored and the database is synced.
 
 @param things A collection of new things to be added to the cache database.
 @param recordId The record Id used to identify a specific cache of pending Things.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if the creation process could not be completed.
 */
- (void)createPendingCachedThings:(NSArray<MHVThing *> *)things
                         recordId:(NSString *)recordId
                       completion:(void (^)(NSError *_Nullable error))completion;

/**
 This called before caching any pending method. If multiple operations are performed on a 'placeholder' Thing before the internet connection is restored, previous pending methods may be updated or deleted.

 @param recordId The record Id used to identify a specific cache of pending Things.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSArray<MHVThing *> things An array of ALL pending Things for a given record id. NSError error A detailed error if the creation process could not be completed.
 */
- (void)fetchPendingThingsForRecordId:(NSString *)recordId
                           completion:(void (^)(NSArray<MHVThing *> *_Nullable things, NSError *_Nullable error))completion;

/**
 This method is called after the database is fully synced to clean-up 'placeholder' Things that may have been created if createNewThing:recordId:completion: or createNewThings:recordId:completion: was called when there was no connection to the internet.
 @note If a create things method call is made when there is no connection to the internet, a pending method will be saved by calling cachePendingMethod: and 'placeholder' Things will be saved by calling createPendingCachedThings:recordId:completion:.
 
 @param recordId NSString The record Id used to identify a specific cache of pending Things.
 @param completion MUST be envoked when the operation is complete or an error occurs. NSError error a detailed error if deleting 'placeholder' Things fails.
 */
- (void)deletePendingThingsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
