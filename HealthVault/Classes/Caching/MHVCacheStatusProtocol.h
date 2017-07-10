//
//  MHVCacheStatusProtocol.h
//  Pods
//
//  Created by Nathan Malubay on 7/7/17.
//
//

#import <Foundation/Foundation.h>


@protocol MHVCacheStatusProtocol <NSObject>

/**
 A date representing the last date that a sync operation occured between HealthVault and the cache.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *lastCompletedSyncDate;

/**
 A date representing the last time the data in cache and HealthVault were fully consistent.
 @note Until the lastCacheConsistencyDate is not nil, all GetThings requests will be issued to HealthVault and the cache will be ignored.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *lastCacheConsistencyDate;

/**
 A sequence number representing the current sequence for all Things saved in the cache.
 */
@property (nonatomic, assign, readonly) NSInteger newestCacheSequenceNumber;

/**
 A sequence number representing the current sequence for Things in HealthVault.
 */
@property (nonatomic, assign, readonly) NSInteger newestHealthVaultSequenceNumber;

/**
 A BOOL representing whether the cache is in an invalid state that would cause it to be unusable.
 */
@property (nonatomic, assign, readonly) BOOL isCacheValid;

@end
