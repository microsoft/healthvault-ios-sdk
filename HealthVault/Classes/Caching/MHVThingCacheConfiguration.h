//
//  MHVThingCacheConfiguration.h
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

@protocol MHVThingCacheDatabaseProtocol;

@interface MHVThingCacheConfiguration : NSObject

/**
 An array of typeIds to be cached.  
 To avoid downloading data that will never be used, this should be set with 
 the data types used by the app.  If nil or empty, no data will be cached.
 */
@property (nonatomic, strong) NSArray<NSString *> *cacheTypeIds;

/**
 A timer will sync the database with this time interval while the app is active
 */
@property (nonatomic, assign) NSInteger syncIntervalSeconds;

/**
 Database to use for caching, if nil MHVThingCacheDatabase will be used
 */
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol> database;

@end
