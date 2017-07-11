//
//  MHVThingCacheConfigurationProtocol.h
//  Pods
//
//  Created by Michael Burford on 7/11/17.
//
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
@property (nonatomic, strong) NSArray<NSString *> *cacheTypeIds;

/**
 A timer will sync the database with this time interval while the app is active
 
 The default time is 1 hour
 */
@property (nonatomic, assign) NSInteger syncIntervalSeconds;

/**
 Database to use for caching
 
 The default is nil, so MHVThingCacheDatabase will be used
 */
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol> database;

@end
