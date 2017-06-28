//
//  MHVThingCacheProtocol.h
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
@class MHVThingCacheConfiguration, MHVThingQuery, MHVThingQueryCollection, MHVThingQueryResultCollection, MHVThingCollection, MHVHostReachability;
@protocol MHVConnectionProtocol, MHVNetworkStatusProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheProtocol <NSObject>

/**
 The application has been deauthorized.  All data for the caching should be deleted
 */
- (void)deauthorizedApplication;

/**
 Retrieve the cached results for a query collection
 
 @param queries The collection of queries for things
 @param recordId The record ID of the person
 @param completion Returns the results
 */
- (void)cachedResultsForQueries:(MHVThingQueryCollection *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(MHVThingQueryResultCollection *_Nullable resultCollection))completion;

/**
 Indicate a record should be added to the sync process
 
 @param recordId The record to be synced
 @param completion Envoked when the first sync for the record is complete
 */
- (void)startSyncingForRecordId:(NSUUID *)recordId completion:(void (^_Nullable)(BOOL success))completion;

/**
 Indicate a record should be removed to the sync process
 
 @param recordId The record to be removed
 */
- (void)stopSyncingForRecordId:(NSUUID *)recordId;

/**
 Sync the HealthVault database
 This should be called by your UIApplicationDelegate's application:performFetchWithCompletionHandler: method.
 You will also need to add "Background fetch" to your app's "Background modes" capabilities
 
 @param completionHandler The callback to indicate the results of background syncing
 */
- (void)syncWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end

NS_ASSUME_NONNULL_END
