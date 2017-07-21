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

@class MHVThingQuery, MHVThingQueryResult, MHVThing, MHVMethod, MHVThingKey;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheProtocol <NSObject>

/**
 Retrieve the cached results for a query collection
 
 @param queries The collection of queries for things
 @param recordId The record ID of the person
 @param completion Returns the results
 */
- (void)cachedResultsForQueries:(NSArray<MHVThingQuery *> *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(NSArray<MHVThingQueryResult *> *_Nullable resultCollection, NSError *_Nullable error))completion;

/**
 Add things to the cache for a recordId

 @param things The things to be added
 @param recordId The record ID of the person
 @param completion Envoked when adding is complete, with any error that occurred
 */
- (void)addThings:(NSArray<MHVThing *> *)things
         recordId:(NSUUID *)recordId
       completion:(void(^)(NSError *_Nullable error))completion;

/**
 Update things in cache for a recordId
 
 @param things The things to be update
 @param recordId The record ID of the person
 @param completion Envoked when updating is complete, with any error that occurred
 */
- (void)updateThings:(NSArray<MHVThing *> *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion;

/**
 Delete things to the cache for a recordId
 
 @param things The things to be deleted
 @param recordId The record ID of the person
 @param completion Envoked when deleting is complete, with any error that occurred
 */
- (void)deleteThings:(NSArray<MHVThing *> *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion;

/**
 Adds a method call to the cache to be replayed when the connection is online and adds or deletes Things from the cache. This method is called if there is a 'PutThings' or 'RemoveThings' method request when there is no connection to the internet.

 @param method MHVMethod The method to be re-issued.
 @param things NSArray<MHVThing *> The Things to be added to the cache
 @param completion Envoked once the process of caching the method has completed or an error occured. NSArray<MHVThingKey *> keys A collection of keys for the things that have been added to the cache. NSError error A detailed error about the operation failure.
 */

- (void)cacheMethod:(MHVMethod *)method
             things:(NSArray<MHVThing *> *)things
         completion:(void (^)(NSArray<MHVThingKey *> *_Nullable keys, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
