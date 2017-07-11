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

@protocol MHVThingCacheDatabaseProtocol;

@protocol MHVThingCacheConfigurationProtocol <NSObject>

/**
 An array of typeIds to be cached.
 To avoid downloading data that will never be used, this should be set with
 the data types used by the app.  If nil or empty, no data will be cached.
 
 The default is empty and no caching.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *cacheTypeIds;

/**
 A timer will sync the database with this time interval while the app is active
 
 The default time is 1 hour
 */
@property (nonatomic, assign) NSInteger syncIntervalSeconds;

/**
 Database to use for caching, allowing a custom database to be implemented
 
 The default is nil, so MHVThingCacheDatabase will be used
 */
@property (nonatomic, strong, nullable) id<MHVThingCacheDatabaseProtocol> database;

@end
