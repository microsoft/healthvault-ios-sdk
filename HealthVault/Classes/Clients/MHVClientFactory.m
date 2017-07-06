//
//  MHVClientFactory.m
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

#import "MHVClientFactory.h"
#import "MHVPersonClient.h"
#import "MHVPlatformClient.h"
#import "MHVRemoteMonitoringClient.h"
#import "MHVThingClient.h"
#import "MHVSessionCredentialClient.h"
#import "MHVVocabularyClient.h"
#import "MHVCryptographer.h"
#import "MHVKeychainService.h"
#import "MHVConfiguration.h"
#import "MHVThingCacheConfiguration.h"
#ifdef THING_CACHE
#import "MHVThingCache.h"
#import "MHVThingCacheDatabase.h"
#endif

@implementation MHVClientFactory

- (id<MHVPersonClientProtocol>)personClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVPersonClient alloc] initWithConnection:connection];
}

- (id<MHVPlatformClientProtocol>)platformClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVPlatformClient alloc] initWithConnection:connection];
}

-(id<MHVRemoteMonitoringClientProtocol>)remoteMonitoringClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVRemoteMonitoringClient alloc] initWithConnection:connection];
}

- (id<MHVThingClientProtocol>)thingClientWithConnection:(id<MHVConnectionProtocol>)connection
{
#ifdef THING_CACHE
    //Use database from configuration, or create MHVThingCacheDatabase
    id<MHVThingCacheDatabaseProtocol> database;
    if (connection.cacheConfiguration.database)
    {
        database = connection.cacheConfiguration.database;
    }
    else
    {
        database = [[MHVThingCacheDatabase alloc] initWithKeychainService:[MHVKeychainService new]
                                                              fileManager:[NSFileManager defaultManager]];
    }
    
    MHVThingCache *thingCache = [[MHVThingCache alloc] initWithCacheDatabase:database
                                                                  connection:connection];
        
    return [[MHVThingClient alloc] initWithConnection:connection cache:thingCache];
#else
    return [[MHVThingClient alloc] initWithConnection:connection cache:nil];
#endif
}

- (id<MHVVocabularyClientProtocol>)vocabularyClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVVocabularyClient alloc] initWithConnection:connection];
}

- (id<MHVSessionCredentialClientProtocol>)credentialClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVSessionCredentialClient alloc] initWithConnection:connection
                                                    cryptographer:[MHVCryptographer new]];
}

@end
