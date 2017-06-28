//
//  MHVThingCache.m
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

#import "MHVThingCache.h"
#import "MHVThingCacheConfiguration.h"
#import "MHVThingCacheDatabaseProtocol.h"
#import "MHVConnections.h"
#import "MHVClients.h"
#import "MHVCommon.h"
#import "MHVLogger.h"
#import "MHVTypes.h"
#import "MHVThingTypes.h"
#import "MHVThingCacheDatabase+CoreDataModel.h"
#import "MHVAsyncTask.h"
#import "MHVAsyncTaskResult.h"
#import "MHVNetworkStatusProtocol.h"

typedef void (^MHVBackgroundFetchResultCompletion)(UIBackgroundFetchResult result);

@interface MHVThingCache ()

@property (nonatomic, weak)   id<MHVConnectionProtocol>                             connection;
@property (nonatomic, strong) MHVThingCacheConfiguration                            *cacheConfiguration;
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol>                     database;
@property (nonatomic, strong) id<MHVNetworkStatusProtocol>                          networkStatus;

@property (nonatomic, strong) NSSet<NSString *>                                     *syncTypes;

@property (nonatomic, strong) NSMutableArray<MHVBackgroundFetchResultCompletion>    *syncCompletionHandlers;
@property (nonatomic, strong) NSNumber                                              *isSyncing;

@end

@implementation MHVThingCache

- (instancetype)initWithCacheDatabase:(id<MHVThingCacheDatabaseProtocol>)database
                           connection:(id<MHVConnectionProtocol>)connection
                        networkStatus:(id<MHVNetworkStatusProtocol>)networkStatus
{
    MHVASSERT_PARAMETER(database);
    MHVASSERT_PARAMETER(connection);
    MHVASSERT_PARAMETER(networkStatus);
    MHVASSERT_PARAMETER(connection.configuration.cacheConfiguration);
    MHVASSERT_PARAMETER(connection.configuration.cacheConfiguration.cacheTypeIds);

    self = [super init];
    if (self)
    {
        _database = database;
        _connection = connection;
        _cacheConfiguration = connection.configuration.cacheConfiguration;
        _networkStatus = networkStatus;
        
        _isSyncing = @(NO);
        _syncCompletionHandlers = [NSMutableArray new];
        
        if (_cacheConfiguration.cacheTypeIds.count > 0)
        {
            _syncTypes = [[NSSet alloc] initWithArray:_cacheConfiguration.cacheTypeIds];
        }
        
        //Start a sync so cache will get updated when app launched & user authenticated
        [self syncWithCompletionHandler:^(UIBackgroundFetchResult result) { }];
    }
    return self;
}

- (void)deauthorizedApplication
{
    [self.database deleteDatabase];

    @synchronized (self.syncCompletionHandlers)
    {
        [self.syncCompletionHandlers removeAllObjects];
    }
}

#pragma mark - Cached Results

- (void)cachedResultsForQueries:(MHVThingQueryCollection *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(MHVThingQueryResultCollection *_Nullable resultCollection))completion;
{
    id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId.UUIDString];
    if (!record)
    {
        completion(nil);
        return;
    }

    // If offline, dates don't apply & always use cached data
    if (self.networkStatus.hasNetworkConnection)
    {
        // Check if it's been too long since the last sync
        NSDate *lastSyncDate = [self.database lastSyncDateFromRecord:record];
        if (fabs([lastSyncDate timeIntervalSinceNow]) > self.cacheConfiguration.maxCacheValidSeconds)
        {
            MHVLOG(@"Cache data is too old");
            
            //Start a sync so cache will get updated
            [self syncWithCompletionHandler:^(UIBackgroundFetchResult result) { }];
            
            completion(nil);
            return;
        }
    }
    
    //TODO...use cache
    completion(nil);
}

#pragma mark - Syncing

- (void)startSyncingForRecordId:(NSUUID *)recordId completion:(void (^_Nullable)(BOOL success))completion
{
    MHVASSERT_PARAMETER(recordId);
    
    if (!recordId)
    {
        if (completion)
        {
            completion(NO);
        }
        return;
    }
    
    id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId.UUIDString];
    if (!record)
    {
        MHVLOG(@"Record not found, adding new Sync record %@", [recordId.UUIDString substringToIndex:4]);
        
        record = [self.database newRecord:recordId.UUIDString];
    
        // Start syncing the new record; or if a sync is in progress it will wait until that completes before syncing the record
        [self runBlockWhenNotSyncing:^(UIBackgroundFetchResult result)
         {
             [self syncRecords:@[record] completion:^(UIBackgroundFetchResult result)
              {
                  if (completion)
                  {
                      completion(result != UIBackgroundFetchResultFailed);
                  }
              }];
         }];
    }
    else
    {
        if (completion)
        {
            completion(YES);
        }
    }
}

- (void)stopSyncingForRecordId:(NSUUID *)recordId
{
    MHVASSERT_PARAMETER(recordId);

    if (!recordId)
    {
        return;
    }
    [self.database deleteRecord:recordId.UUIDString];
}

- (void)syncWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    MHVASSERT_PARAMETER(completionHandler);

    [self.database fetchCachedRecords:^(NSArray<id<MHVCachedRecord>> *_Nullable records)
     {
         if (records.count == 0)
         {
             MHVLOG(@"No Records to sync, done");
             completionHandler(UIBackgroundFetchResultNoData);
             return;
         }
         
         [self syncRecords:records completion:completionHandler];
     }];
}

- (void)syncRecords:(NSArray<id<MHVCachedRecord>> *_Nullable)records
         completion:(void (^)(UIBackgroundFetchResult result))completion
{
    MHVASSERT_PARAMETER(completion);

    [self addSyncCompletion:completion];
    
    @synchronized (self.isSyncing)
    {
        if (self.isSyncing.boolValue)
        {
            MHVLOG(@"Sync is already in progress!");
            
            return;
        }
        
        self.isSyncing = @(YES);
    }
    
    NSMutableArray<MHVAsyncTask *> *tasks = [NSMutableArray new];
    
    MHVLOG(@"%li Records to sync", records.count);
    
    // Create array of tasks, one sync process for each Record
    for (id<MHVCachedRecord> record in records)
    {
        [tasks addObject:[[[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
                           {
                               [self.connection.thingClient getRecordOperations:[self.database lastSequenceNumberFromRecord:record]
                                                                       recordId:[[NSUUID alloc] initWithUUIDString:[self.database recordIdFromRecord:record]]
                                                                     completion:^(MHVGetRecordOperationsResult * _Nullable result, NSError * _Nullable error)
                                {
                                    if (error)
                                    {
                                        finish([MHVAsyncTaskResult withError:error]);
                                    }
                                    else
                                    {
                                        [self syncRecordOperations:result
                                                          recordId:[self.database recordIdFromRecord:record]
                                                        completion:^(UIBackgroundFetchResult result)
                                         {
                                             finish([MHVAsyncTaskResult withResult:@(result)]);
                                         }];
                                    }
                                }];
                           }] start]];
    }
    
    // Wait for all sync processes to complete, then merge the results
    [MHVAsyncTask waitForAll:tasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
    {
        UIBackgroundFetchResult fetchResult = UIBackgroundFetchResultNoData;
        
        for (MHVAsyncTaskResult<NSNumber *> *result in taskResults)
        {
            if (result.error)
            {
                fetchResult = UIBackgroundFetchResultFailed;
            }
            else if (fetchResult == UIBackgroundFetchResultNoData &&
                     result.result.integerValue == UIBackgroundFetchResultNewData)
            {
                fetchResult = UIBackgroundFetchResultNewData;
            }
        }
        
        MHVLOG(@"Completed syncing with result %li", fetchResult);

        // Done, turn off syncing flag and call completions
        @synchronized (self.isSyncing)
        {
            self.isSyncing = @(NO);
        }
        
        [self performSyncCompletionsWithResult:fetchResult];
        
        return nil;
    }];
}

- (void)runBlockWhenNotSyncing:(MHVBackgroundFetchResultCompletion)completion
{
    MHVASSERT_PARAMETER(completion);
    if (!completion)
    {
        return;
    }

    @synchronized (self.isSyncing)
    {
        if (self.isSyncing.boolValue)
        {
            [self addSyncCompletion:completion];
            return;
        }
    }

    completion(UIBackgroundFetchResultNoData);
}

- (void)addSyncCompletion:(MHVBackgroundFetchResultCompletion)completion
{
    MHVASSERT_PARAMETER(completion);
    if (!completion)
    {
        return;
    }
    
    @synchronized (self.syncCompletionHandlers)
    {
        [self.syncCompletionHandlers addObject:completion];
    }
}

- (void)performSyncCompletionsWithResult:(UIBackgroundFetchResult)result
{
    @synchronized (self.syncCompletionHandlers)
    {
        for (MHVBackgroundFetchResultCompletion completion in self.syncCompletionHandlers)
        {
            completion(result);
        }
        
        [self.syncCompletionHandlers removeAllObjects];
    }
}

- (void)syncRecordOperations:(MHVGetRecordOperationsResult *)recordOperations
                    recordId:(NSString *)recordId
                  completion:(void (^)(UIBackgroundFetchResult result))completion
{
    MHVASSERT_PARAMETER(recordOperations);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);

    NSMutableSet *syncThingIds = [NSMutableSet new];
    NSMutableSet *removeThingIds = [NSMutableSet new];
    
    // Loop through operations to build sets of changes and deletes
    for (MHVRecordOperation *operation in recordOperations.operations)
    {
        if ([operation.operation isEqualToString:@"Delete"])
        {
            [removeThingIds addObject:operation.thingId];
            [syncThingIds removeObject:operation.thingId];
        }
        else if ([self.syncTypes containsObject:operation.typeId])
        {
            [syncThingIds addObject:operation.thingId];
        }
    }
    
    if (removeThingIds.count == 0 && syncThingIds.count == 0)
    {
        MHVLOG(@"Record %@ has no changes", [recordId substringToIndex:4]);
        
        //Synced with no changes, update lastSyncDate
        id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId];
        if (record)
        {
            [self.database updateRecord:record lastSyncDate:[NSDate date] sequenceNumber:nil];
        }

        completion(UIBackgroundFetchResultNoData);
    }
    else
    {
        MHVLOG(@"Record %@ has %li deletes and %li changes", [recordId substringToIndex:4], removeThingIds.count, syncThingIds.count);
        
        //Remove any deleted things from this record
        [self.database deleteThingIds:removeThingIds.allObjects recordId:recordId];
        
        //Sync to add/update things
        [self syncThingIds:syncThingIds.allObjects
                  recordId:recordId
        lastSequenceNumber:recordOperations.latestRecordOperationSequenceNumber
                completion:completion];
    }
}

- (void)syncThingIds:(NSArray<NSString *> *)thingIds
            recordId:(NSString *)recordId
  lastSequenceNumber:(NSInteger)lastSequenceNumber
          completion:(void (^)(UIBackgroundFetchResult result))completion
{
    MHVASSERT_PARAMETER(thingIds);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);

    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingIDs:thingIds];
    
    [self.connection.thingClient getThingsWithQuery:query
                                           recordId:[[NSUUID alloc] initWithUUIDString:recordId]
                                         completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
     {
         if (error)
         {
             completion(UIBackgroundFetchResultFailed);
         }
         else
         {
             [self.database addOrUpdateThings:things recordId:recordId lastSequenceNumber:lastSequenceNumber completion:^(BOOL success)
             {
                 completion(success ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultFailed);
             }];
         }
     }];
}

@end

