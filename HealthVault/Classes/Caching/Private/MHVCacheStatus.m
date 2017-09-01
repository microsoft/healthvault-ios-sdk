//
// MHVCacheStatus.m
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
        _newestCacheSequenceNumber = (NSInteger)cachedRecord.newestCacheSequenceNumber;
        _newestHealthVaultSequenceNumber = (NSInteger)cachedRecord.newestHealthVaultSequenceNumber;
        _isCacheValid = cachedRecord.isValid;
    }
    
    return self;
}

@end
