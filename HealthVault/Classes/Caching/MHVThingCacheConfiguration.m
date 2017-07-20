//
//  MHVThingCacheConfiguration.m
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

#import "MHVThingCacheConfiguration.h"
#import "MHVConfigurationConstants.h"

static NSInteger const kDefaultSyncIntervalSeconds = 30 * 10; // 10 minutes

@implementation MHVThingCacheConfiguration

@synthesize cacheTypeIds = _cacheTypeIds;
@synthesize syncIntervalSeconds = _syncIntervalSeconds;
@synthesize database = _database;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _cacheTypeIds = @[];
        _syncIntervalSeconds = kDefaultSyncIntervalSeconds;
    }
    return self;
}

@end
