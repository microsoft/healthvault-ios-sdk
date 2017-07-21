//
// MHVThingCacheSynchronizerProtocol.h
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
//

#import <Foundation/Foundation.h>
#import "MHVCacheConstants.h"

@protocol MHVThingCacheDatabaseProtocol, MHVConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheSynchronizerProtocol <NSObject>

@property (nonatomic, strong, readonly) id<MHVThingCacheDatabaseProtocol> database;

@property (nonatomic, weak) NSObject<MHVConnectionProtocol> *connection;

/**
 Sync the HealthVault database
 This should be called via the MHVConnection performBackgroundTasks and performForegroundTasks
 
 @param options Any options set for the sync process
 @param completion The callback to indicate the results of background syncing
 */
- (void)syncWithOptions:(MHVCacheOptions)options
             completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
