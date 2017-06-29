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
#import "NSError+MHVError.h"
#import "MHVTypes.h"
#import "MHVThingTypes.h"
#import "MHVThingCacheDatabase+CoreDataModel.h"
#import "MHVAsyncTask.h"
#import "MHVAsyncTaskResult.h"

typedef void (^MHVSyncResultCompletion)(NSInteger syncedItemCount, NSError *_Nullable error);

@interface MHVThingCache ()

@property (nonatomic, weak)   id<MHVConnectionProtocol>                             connection;
@property (nonatomic, strong) MHVThingCacheConfiguration                            *cacheConfiguration;
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol>                     database;

@property (nonatomic, strong) NSSet<NSString *>                                     *syncTypes;

@property (nonatomic, strong) NSMutableArray<MHVSyncResultCompletion>               *syncCompletionHandlers;
@property (nonatomic, strong) NSNumber                                              *isSyncing;
@property (nonatomic, strong) NSTimer                                               *syncTimer;

@end

@implementation MHVThingCache

- (instancetype)initWithCacheDatabase:(id<MHVThingCacheDatabaseProtocol>)database
                           connection:(id<MHVConnectionProtocol>)connection
{
    MHVASSERT_PARAMETER(database);
    MHVASSERT_PARAMETER(connection);
    MHVASSERT_PARAMETER(connection.cacheConfiguration);
    MHVASSERT_PARAMETER(connection.cacheConfiguration.cacheTypeIds);

    self = [super init];
    if (self)
    {
        _database = database;
        _connection = connection;
        _cacheConfiguration = connection.cacheConfiguration;
        
        _isSyncing = @(NO);
        _syncCompletionHandlers = [NSMutableArray new];
        
        if (_cacheConfiguration.cacheTypeIds.count > 0)
        {
            _syncTypes = [[NSSet alloc] initWithArray:_cacheConfiguration.cacheTypeIds];
        }
    }
    return self;
}

- (void)startCache
{
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:_cacheConfiguration.syncIntervalSeconds
                                                      target:self
                                                    selector:@selector(syncTimerAction)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [self prepareCacheForRecords:self.connection.personInfo.records completion:^(NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error preparing cache: %@", error.localizedDescription);
         }
         
         //Start a sync so cache will get updated when app launched & user authenticated
         [self syncWithCompletionHandler:^(NSInteger syncedItemCount, NSError *error)
          {
              if (error)
              {
                  MHVLOG(@"ThingCache: Error performing sync: %@", error.localizedDescription);
              }
          }];
     }];
}

- (NSError *_Nullable)clearAllCachedData
{
    NSError *error = [self.database deleteDatabase];
    if (error)
    {
        MHVLOG(@"ThingCache: Error deleting database: %@", error.localizedDescription);
    }

    @synchronized (self.syncCompletionHandlers)
    {
        [self.syncCompletionHandlers removeAllObjects];
    }
    
    if (self.syncTimer.isValid)
    {
        [self.syncTimer invalidate];
    }
    
    return error;
}

#pragma mark - Cached Results

- (void)cachedResultsForQueries:(MHVThingQueryCollection *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(MHVThingQueryResultCollection *_Nullable resultCollection, NSError *_Nullable error))completion;
{
    id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId.UUIDString];
    if (!record)
    {
        completion(nil, [NSError error:[NSError MHVNotFound] withDescription:@"recordId not found in cache database"]);
        return;
    }
    
    if (![self.database isCacheValidForRecord:record])
    {
        completion(nil, nil);
        return;
    }

    //TODO...use cache
    completion(nil, nil);
}

#pragma mark - Syncing

- (void)syncTimerAction
{
    MHVLOG(@"ThingCache: Timer triggered sync");
    
    [self syncWithCompletionHandler:^(NSInteger syncedItemCount, NSError *_Nullable error)
    {
        if (error)
        {
            MHVLOG(@"ThingCache: Error performing sync: %@", error.localizedDescription);
        }
    }];
}

- (void)prepareCacheForRecords:(MHVRecordCollection *)records completion:(void (^)(NSError *_Nullable error))completion
{    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                   {
                       for (MHVRecord *record in records)
                       {
                           NSString *recordId = record.ID.UUIDString;
                           
                           id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId];
                           if (!record)
                           {
                               MHVLOG(@"ThingCache: Cache Record not found, adding new Sync record");
                               
                               record = [self.database newRecord:recordId];
                               
                               if (!record)
                               {
                                   if (completion)
                                   {
                                       completion([NSError error:[NSError MHVOperationCannotBePerformed]
                                                 withDescription:@"Record could not be created in Cache database"]);
                                   }
                                   return;
                               }
                           }
                       }

                       completion(nil);
                   });
}

- (void)syncWithCompletionHandler:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);

    [self.database fetchCachedRecords:^(NSArray<id<MHVCachedRecord>> *_Nullable records)
     {
         if (records.count == 0)
         {
             MHVLOG(@"ThingCache: No Records to sync, done");
             if (completion)
             {
                 completion(0, nil);
             }
             return;
         }
         
         [self syncRecords:records completion:completion];
     }];
}

- (void)syncRecords:(NSArray<id<MHVCachedRecord>> *_Nullable)records
         completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);

    [self addSyncCompletion:completion];
    
    @synchronized (self.isSyncing)
    {
        if (self.isSyncing.boolValue)
        {
            MHVLOG(@"ThingCache: Sync is already in progress!");
            
            return;
        }
        
        self.isSyncing = @(YES);
    }
    
    NSMutableArray<MHVAsyncTask *> *tasks = [NSMutableArray new];
    
    MHVLOG(@"ThingCache: %li Records to sync", records.count);
    
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
                                                        completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                         {
                                             if (error)
                                             {
                                                 finish([MHVAsyncTaskResult withError:error]);
                                             }
                                             else
                                             {
                                                 finish([MHVAsyncTaskResult withResult:@(syncedItemCount)]);
                                             }
                                         }];
                                    }
                                }];
                           }] start]];
    }
    
    // Wait for all sync processes to complete, then merge the results
    [MHVAsyncTask waitForAll:tasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
    {
        NSError *error;
        NSInteger syncedItemTotal = 0;
        
        for (MHVAsyncTaskResult<NSNumber *> *result in taskResults)
        {
            if (result.error)
            {
                error = result.error;
            }
            else
            {
                syncedItemTotal += result.result.integerValue;
            }
        }
        
        // Done, turn off syncing flag and call completions
        @synchronized (self.isSyncing)
        {
            self.isSyncing = @(NO);
        }
        
        [self performSyncCompletionsWithSyncedCount:syncedItemTotal error:error];
        
        return nil;
    }];
}

- (void)runBlockWhenNotSyncing:(MHVSyncResultCompletion)completion
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

    completion(0, nil);
}

- (void)addSyncCompletion:(MHVSyncResultCompletion)completion
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

- (void)performSyncCompletionsWithSyncedCount:(NSInteger)syncedItemCount error:(NSError *_Nullable)error
{
    @synchronized (self.syncCompletionHandlers)
    {
        for (MHVSyncResultCompletion completion in self.syncCompletionHandlers)
        {
            completion(syncedItemCount, error);
        }
        
        [self.syncCompletionHandlers removeAllObjects];
    }
}

- (void)syncRecordOperations:(MHVGetRecordOperationsResult *)recordOperations
                    recordId:(NSString *)recordId
                  completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
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
        MHVLOG(@"ThingCache: Cache record has no changes");
        
        //Synced with no changes, update lastSyncDate
        id<MHVCachedRecord> record = [self.database fetchCachedRecord:recordId];
        NSError *error = nil;
        if (record)
        {
            error = [self.database updateRecord:record
                                   lastSyncDate:[NSDate date]
                                 sequenceNumber:nil];
        }
        else
        {
            error = [NSError error:[NSError MHVNotFound] withDescription:@"Record not found to update cache database"];
        }

        if (completion)
        {
            completion(0, error);
        }
    }
    else
    {
        MHVLOG(@"ThingCache: Cache record has %li deletes and %li changes", removeThingIds.count, syncThingIds.count);
        
        //Remove any deleted things from this record
        NSError *error = [self.database deleteThingIds:removeThingIds.allObjects recordId:recordId];
        
        if (!error)
        {
            //Sync to add/update things
            [self syncThingIds:syncThingIds.allObjects
                      recordId:recordId
            lastSequenceNumber:recordOperations.latestRecordOperationSequenceNumber
                    completion:completion];
        }
        else
        {
            if (error)
            {
                [self.database setCacheInvalidForRecordId:recordId];
            }
            
            if (completion)
            {
                completion(0, error);
            }
        }
    }
}

- (void)syncThingIds:(NSArray<NSString *> *)thingIds
            recordId:(NSString *)recordId
  lastSequenceNumber:(NSInteger)lastSequenceNumber
          completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thingIds);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);

    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingIDs:[[MHVStringCollection alloc] initWithArray:thingIds]];
    
    __weak __typeof__(self)weakSelf = self;
    
    [self.connection.thingClient getThingsWithQuery:query
                                           recordId:[[NSUUID alloc] initWithUUIDString:recordId]
                                         completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
     {
         if (error)
         {
             if (completion)
             {
                 completion(0, error);
             }
         }
         else
         {
             [weakSelf.database addOrUpdateThings:things
                                         recordId:recordId
                               lastSequenceNumber:lastSequenceNumber
                                       completion:^(NSInteger updateItemCount, NSError * _Nullable error)
              {
                  if (error)
                  {
                      [weakSelf.database setCacheInvalidForRecordId:recordId];
                  }
                  
                  if (completion)
                  {
                      completion(updateItemCount, error);
                  }
              }];
         }
     }];
}

@end

