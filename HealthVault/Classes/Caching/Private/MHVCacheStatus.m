//
//  MHVCacheStatus.m
//  Pods
//
//  Created by Nathan Malubay on 7/7/17.
//
//

#import "MHVCacheStatus.h"
#import "MHVValidator.h"
#import "MHVCachedRecord+Cache.h"

@implementation MHVCacheStatus

@synthesize lastCompletedSyncDate = _lastCompletedSyncDate;
@synthesize lastCacheConsistencyDate = _lastCacheConsistencyDate;
@synthesize newestCacheSequenceNumber = _newestCacheSequenceNumber;
@synthesize newestHealthVaultSequenceNumber = _newestHealthVaultSequenceNumber;
@synthesize isCacheValid = _isCacheValid;

- (instancetype)initWithCachedRecord:(MHVCachedRecord *)cachedRecord
{
    MHVASSERT_PARAMETER(cachedRecord);
    
    self = [super init];
    
    if (self)
    {
        _lastCompletedSyncDate = [cachedRecord.lastSyncDate copy];
        _lastCacheConsistencyDate = [cachedRecord.lastConsistencyDate copy];
        _newestCacheSequenceNumber = cachedRecord.newestCacheSequenceNumber;
        _newestHealthVaultSequenceNumber = cachedRecord.newestHealthVaultSequenceNumber;
        _isCacheValid = cachedRecord.isValid;
    }
    
    return self;
}

@end
