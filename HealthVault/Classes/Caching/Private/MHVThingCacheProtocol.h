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
#import "MHVCacheConstants.h"

@class MHVThingCacheConfiguration, MHVThingQuery, MHVThingQueryCollection, MHVThingQueryResultCollection, MHVThingCollection, MHVMethod, MHVPendingMethod;
@protocol MHVConnectionProtocol, MHVNetworkObserverProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheProtocol <NSObject>

/**
 Retrieve the cached results for a query collection
 
 @param queries The collection of queries for things
 @param recordId The record ID of the person
 @param completion Returns the results
 */
- (void)cachedResultsForQueries:(MHVThingQueryCollection *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(MHVThingQueryResultCollection *_Nullable resultCollection, NSError *_Nullable error))completion;

/**
 Add things to the cache for a recordId

 @param things The things to be added
 @param recordId The record ID of the person
 @param completion Envoked when adding is complete, with any error that occurred
 */
- (void)addThings:(MHVThingCollection *)things
         recordId:(NSUUID *)recordId
       completion:(void(^)(NSError *_Nullable error))completion;

/**
 Update things in cache for a recordId
 
 @param things The things to be update
 @param recordId The record ID of the person
 @param completion Envoked when updating is complete, with any error that occurred
 */
- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion;

/**
 Delete things to the cache for a recordId
 
 @param things The things to be deleted
 @param recordId The record ID of the person
 @param completion Envoked when deleting is complete, with any error that occurred
 */
- (void)deleteThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion;

/**
 Sync the HealthVault database
 This should be called via the MHVConnection performBackgroundTasks and performForegroundTasks
 
 @param options Any options set for the sync process
 @param completion The callback to indicate the results of background syncing
 */
- (void)syncWithOptions:(MHVCacheOptions)options
             completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion;

/**
 Adds a method call to the cache to be replayed when the connection is online. This method is called if there is a 'PutThings' or 'RemoveThings' method request when there is no connection to the internet.

 @param method MHVMethod The method to be re-issued.
 @param completion Envoked once the process of caching the method has completed or an error occured. MHVPendingMethod pendingMethod The pending method that was cached. NSError error A detailed error about the operation failure.
 */
- (void)cacheMethod:(MHVMethod *)method completion:(void (^)(MHVPendingMethod *_Nullable pendingMethod, NSError *_Nullable error))completion;

/**
 Adds 'placeholder' things to the cache for a recordId.
 @note A 'placeholder' thing is a thing that was created while offline. Once the internet connection is restored the original thing creation request will be issued to the cloud and the 'placeholder' will be replaced with the HealthVault version of the thing. 'placeholder' Things do not have a Thing Key property set.
 
 @param things The things to be added
 @param recordId The record ID of the person
 @param completion Envoked when adding is complete, with any error that occurred
 */
- (void)addPendingThings:(MHVThingCollection *)things
                recordId:(NSUUID *)recordId
              completion:(void(^)(NSError *_Nullable error))completion;

/**
 Deletes a pending method call that was previously added to the cache.
 
 @param pendingMethod MHVPendingMethod The pending method to be deleted.
 @param completion Envoked once the process of deleting the pending method has completed or an error occured. NSError error A detailed error about the operation failure.
 */
- (void)deletePendingMethod:(MHVPendingMethod *)pendingMethod completion:(void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
