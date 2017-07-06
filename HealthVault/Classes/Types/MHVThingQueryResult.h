//
// MHVThingQueryResult.h
// healthvault-ios-sdk
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

#import "MHVType.h"

@class MHVThingCollection;

@interface MHVThingQueryResult : MHVType

/**
 A unique string to identify a given result. When using an MHVThingQueryCollection a unique name can be assigned to each query and the corresponding result will have the same name. If the name property on the MHVThingQuery is not set a GUID will be assigned to the name property.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 A collection of Things resulting from a given query.
 */
@property (nonatomic, strong, readonly) MHVThingCollection *results;

/**
 The number of unfetched Things resulting from a given query. The HealthVault iOS SDK will return a maximum of 500 Things for any given request. The 'remaining' property can be used to determine if there are more Things that can be fetched for a given query so data can be paged. For example, if an MHVThingQuery would result in 800 Things, the maximum of 500 things would be provided in the 'results' collection, and the 'remaining' property would be set to 300. A subsequest query can be made to fetch the remaining Things by setting the MHVThingQuery 'offset' property to 500 and the 'maxResults' property to 300.
 */
@property (nonatomic, assign, readonly) NSInteger remaining;

/**
 Indicates whether the query result is from the cache.
 */
@property (nonatomic, assign, readonly) BOOL isCachedResult;

- (instancetype)initWithName:(NSString *)name
                     results:(MHVThingCollection *)results
                   remaining:(NSInteger)remaining
              isCachedResult:(BOOL)isCachedResult;

@end

@interface MHVThingQueryResultCollection : MHVCollection<MHVThingQueryResult *>

@end
