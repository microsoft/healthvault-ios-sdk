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
#import "MHVThingQueryResult.h"
#import "MHVCacheStatusProtocol.h"
#import "MHVPendingMethod.h"

typedef void (^MHVSyncResultCompletion)(NSInteger syncedItemCount, NSError *_Nullable error);

static NSString *const kPersonInfoKeyPath = @"personInfo";
static NSUInteger const kMaxRecordBatchSize = 240;

@interface MHVThingCache ()

@property (nonatomic, weak)   NSObject<MHVConnectionProtocol>                       *connection;
@property (nonatomic, strong) MHVThingCacheConfiguration                            *cacheConfiguration;
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol>                     database;
@property (nonatomic, assign) BOOL                                                  automaticStartStop;

@property (nonatomic, strong) NSSet<NSString *>                                     *syncTypes;

@property (nonatomic, strong) NSMutableArray<MHVSyncResultCompletion>               *syncCompletionHandlers;
@property (nonatomic, strong) NSNumber                                              *isSyncing;
@property (nonatomic, strong) NSTimer                                               *syncTimer;

@end

@implementation MHVThingCache

- (instancetype)initWithCacheDatabase:(id<MHVThingCacheDatabaseProtocol>)database
                           connection:(id<MHVConnectionProtocol>)connection
                   automaticStartStop:(BOOL)automaticStartStop
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
        _automaticStartStop = automaticStartStop;
        
        _isSyncing = @(NO);
        _syncCompletionHandlers = [NSMutableArray new];
        
        if (self.automaticStartStop)
        {
            [self startObserving];
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.automaticStartStop)
    {
        [self stopObserving];
    }
}

- (void)startCache
{
    MHVLOG(@"ThingCache: Starting Cache");
    
    [self prepareCacheForRecords:self.connection.personInfo.records
                      completion:^(NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error preparing cache: %@", error.localizedDescription);
             return;
         }
         
         //Start a sync so cache will get updated when app launched & user authenticated
         [self syncWithOptions:MHVCacheOptionsForeground
                    completion:^(NSInteger syncedItemCount, NSError *error)
          {
              if (error)
              {
                  MHVLOG(@"ThingCache: Error performing sync: %@", error.localizedDescription);
              }
          }];
     }];
}

- (void)clearAllCachedDataWithCompletion:(void (^)(NSError *_Nullable error))completion
{
    MHVLOG(@"ThingCache: Deleting Cache");
    
    [self.database resetDatabaseWithCompletion:^(NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error deleting database: %@", error.localizedDescription);
         }
         
         [self performSyncCompletionsWithSyncedCount:0
                                               error:[NSError MHVCacheDeleted]];
         
         if (self.syncTimer.isValid)
         {
             [self.syncTimer invalidate];
         }
         
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Cached Results

- (void)cachedResultsForQueries:(MHVThingQueryCollection *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(MHVThingQueryResultCollection *_Nullable resultCollection, NSError *_Nullable error))completion;
{
    // No completion, don't need to do a query that won't be returned
    if (!completion)
    {
        return;
    }
    
    [self.database cacheStatusForRecordId:recordId.UUIDString
                               completion:^(id<MHVCacheStatusProtocol> _Nullable status, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
             return;
         }
         
         if (!status.isCacheValid)
         {
             completion(nil, [NSError MHVCacheError:@"Cache is not valid for record"]);
             return;
         }
         
         // If last sync date isn't set, cache isn't populated yet
         if (!status.lastCacheConsistencyDate)
         {
             MHVLOG(@"ThingCache: ThingQuery before Cache is populated");
             completion(nil, [NSError MHVCacheNotReady]);
             return;
         }
         
         NSMutableArray<MHVAsyncTask *> *tasks = [NSMutableArray new];
         
         // Make array of tasks to get results from the database
         for (MHVThingQuery *query in queries)
         {
             [tasks addObject:[[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
                               {
                                   [self.database cachedResultForQuery:query
                                                              recordId:recordId.UUIDString
                                                            completion:^(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error)
                                    {
                                        if (error)
                                        {
                                            finish([MHVAsyncTaskResult withError:error]);
                                        }
                                        else
                                        {
                                            finish([MHVAsyncTaskResult withResult:queryResult]);
                                        }
                                    }];
                               }]];
         }
         
         // Run them in a sequence
         [MHVAsyncTask startSequenceOfTasks:tasks];
         
         // When all results have been retrieved, build MHVThingQueryResultCollection
         [MHVAsyncTask waitForAll:tasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
          {
              MHVThingQueryResultCollection *resultCollection = [MHVThingQueryResultCollection new];
              for (MHVAsyncTaskResult *taskResult in taskResults)
              {
                  if (taskResult.error)
                  {
                      completion(nil, taskResult.error);
                      
                      return nil;
                  }
                  
                  [resultCollection addObject:taskResult.result];
              }
              
              if (resultCollection.count != queries.count)
              {
                  //No error, but results not equal to queries (not all quaries are cacheable?), don't return partial results
                  completion(nil, nil);
              }
              else
              {
                  completion(resultCollection, nil);
              }
              
              return nil;
          }];
     }];
}

- (void)addThings:(MHVThingCollection *)things
         recordId:(NSUUID *)recordId
       completion:(void (^)(NSError * _Nullable))completion
{
    [self fillThingsMetadata:things created:YES updated:YES];
    
    [self.database createCachedThings:things
                             recordId:recordId.UUIDString
                           completion:completion];
}

- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void (^)(NSError * _Nullable))completion
{
    [self fillThingsMetadata:things created:NO updated:YES];
    
    [self.database updateCachedThings:things
                             recordId:recordId.UUIDString
                           completion:completion];
}

- (void)deleteThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion
{
    [self.database deleteCachedThingsWithThingIds:things.thingIDs.toArray
                                         recordId:recordId.UUIDString
                                       completion:completion];
}

- (void)fillThingsMetadata:(MHVThingCollection *)things created:(BOOL)created updated:(BOOL)updated
{
    for (MHVThing *thing in things)
    {
        NSDate *date = [NSDate date];
        if (created)
        {
            thing.created = thing.created ?: [MHVAudit new];
            thing.created.when = thing.created.when ?: date;
            thing.created.personID = self.connection.personInfo.ID;
            thing.created.appID = self.connection.applicationId;
        }
        
        if (updated)
        {
            thing.updated = thing.updated ?: [MHVAudit new];
            thing.updated.when = thing.updated.when ?: date;
            thing.updated.personID = self.connection.personInfo.ID;
            thing.created.appID = self.connection.applicationId;
        }
        
        thing.effectiveDate = thing.effectiveDate ?: date;
    }
}

- (void)cacheMethod:(MHVMethod *)method completion:(void (^)(MHVPendingMethod *_Nullable pendingMethod, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(method);
    
    if (method)
    {
        if (completion)
        {
            completion(nil, [NSError error:[NSError MVHInvalidParameter] withDescription:@"'method' is a required parameter."]);
        }
        
        return;
    }
    
    __block MHVPendingMethod *pendingMethod = [[MHVPendingMethod alloc] initWithOriginalRequestDate:[NSDate date]
                                                                                             method:method];
    
    [self.database cachePendingMethod:pendingMethod
                           completion:^(NSError * _Nullable error)
    {
        if (error)
        {
            pendingMethod = nil;
        }
        
        if (completion)
        {
            completion(pendingMethod, error);
        }
    }];
}

- (void)deletePendingMethod:(MHVPendingMethod *)pendingMethod completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(pendingMethod);
    
    if (pendingMethod)
    {
        if (completion)
        {
            completion([NSError error:[NSError MVHInvalidParameter] withDescription:@"'pendingMethod' is a required parameter."]);
        }
        
        return;
    }
    
    [self.database deletePendingMethods:@[pendingMethod]
                             completion:completion];
}

#pragma mark - Syncing

- (void)startSyncTimer
{
    if (self.syncTimer.isValid)
    {
        [self.syncTimer invalidate];
    }
    
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:_cacheConfiguration.syncIntervalSeconds
                                                      target:self
                                                    selector:@selector(syncTimerAction)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)syncTimerAction
{
    MHVLOG(@"ThingCache: Timer triggered sync");
    
    [self syncWithOptions:MHVCacheOptionsForeground | MHVCacheOptionsTimer
               completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error performing sync: %@", error.localizedDescription);
         }
     }];
}

- (void)prepareCacheForRecords:(MHVRecordCollection *)records
                    completion:(void (^)(NSError *_Nullable error))completion
{
    [self.database setupDatabaseWithCompletion:^(NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error setting up Cache Database: %@", error);
             if (completion)
             {
                 completion(error);
             }
             return;
         }
         
         NSMutableArray<NSString *> *recordIds = [NSMutableArray new];
         for (MHVRecord *record in records)
         {
             NSString *recordId = record.ID.UUIDString;
             if (recordId)
             {
                 [recordIds addObject:recordId];
             }
         }
         
         [self.database setupCacheForRecordIds:recordIds
                                    completion:^(NSError * _Nullable error)
          {
              if (error)
              {
                  MHVLOG(@"ThingCache: Error creating database records: %@", error);
              }
              
              if (completion)
              {
                  completion(error);
              }
          }];
     }];
}

- (void)syncWithOptions:(MHVCacheOptions)options
             completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (self.cacheConfiguration.cacheTypeIds.count > 0)
    {
        self.syncTypes = [[NSSet alloc] initWithArray:self.cacheConfiguration.cacheTypeIds];
    }
    else
    {
        // No types specified, no caching
        MHVLOG(@"ThingCache: No caching, cacheConfiguration.cacheTypeIds is empty");
        if (completion)
        {
            completion(0, nil);
        }
        return;
    }
    
    [self.database fetchCachedRecordIds:^(NSArray<NSString *> *_Nullable recordIds, NSError *_Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error getting records to sync: %@", error);
             if (completion)
             {
                 completion(0, error);
             }
             return;
         }
         
         if (recordIds.count == 0)
         {
             MHVLOG(@"ThingCache: No Records to sync, done");
             if (completion)
             {
                 completion(0, nil);
             }
             return;
         }
         
         [self syncRecordsIds:recordIds completion:completion];
     }];
}

- (void)syncRecordsIds:(NSArray<NSString *> *_Nullable)recordIds
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
    
    MHVLOG(@"ThingCache: %li Records to sync", recordIds.count);
    
    // Create array of tasks, one sync process for each Record
    for (NSString *recordId in recordIds)
    {
        [tasks addObject:[[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
                          {
                              [self.database cacheStatusForRecordId:recordId
                                                         completion:^(id<MHVCacheStatusProtocol> _Nullable status, NSError * _Nullable error)
                               {
                                   // If the cache last sync time is still valid, don't need to sync yet
                                   if (!status.lastCacheConsistencyDate || fabs([status.lastCompletedSyncDate timeIntervalSinceNow]) >= self.cacheConfiguration.syncIntervalSeconds)
                                   {
                                       [self.connection.thingClient getRecordOperations:status.newestCacheSequenceNumber
                                                                               recordId:[[NSUUID alloc] initWithUUIDString:recordId]
                                                                             completion:^(MHVGetRecordOperationsResult * _Nullable result, NSError * _Nullable error)
                                        {
                                            if (error)
                                            {
                                                MHVLOG(@"ThingCache: Error performing GetRecordOperations: %@", error);
                                                finish([MHVAsyncTaskResult withError:error]);
                                            }
                                            else
                                            {
                                                [self syncRecordOperations:result.operations
                                                                  recordId:recordId
                                                           syncedItemCount:0
                                                            sequenceNumber:status.newestCacheSequenceNumber
                                                                completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
                                                 {
                                                     if (error)
                                                     {
                                                         MHVLOG(@"ThingCache: Error syncing records: %@", error);
                                                         finish([MHVAsyncTaskResult withError:error]);
                                                     }
                                                     else
                                                     {
                                                         finish([MHVAsyncTaskResult withResult:@(syncedItemCount)]);
                                                     }
                                                 }];
                                            }
                                        }];
                                   }
                                   else
                                   {
                                       //Last sync date is current, done
                                       MHVLOG(@"ThingCache: Record is up to date, synced %li seconds ago", (long)fabs([status.lastCompletedSyncDate timeIntervalSinceNow]));
                                       finish([MHVAsyncTaskResult withResult:@(0)]);
                                   }
                               }];
                          }]];
    }
    
    
    // Sync sequentially, so sync processes are not all accessing HealthVault at once
    [MHVAsyncTask startSequenceOfTasks:tasks];
    
    // Wait for all sync processes to complete, then merge the results
    [MHVAsyncTask waitForAll:tasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
     {
         NSError *error = nil;
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
         
         // Sync complete, start timer for next sync
         [self startSyncTimer];
         
         return nil;
     }];
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

- (void)syncRecordOperations:(MHVRecordOperationCollection *)recordOperations
                    recordId:(NSString *)recordId
             syncedItemCount:(NSInteger)syncedItemCount
              sequenceNumber:(NSInteger)sequenceNumber
                  completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(recordOperations);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if ([NSString isNilOrEmpty:recordId])
    {
        if (completion)
        {
            completion(0, [NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    NSMutableSet *syncThingIds = [NSMutableSet new];
    NSMutableSet *removeThingIds = [NSMutableSet new];
    NSUInteger count = MIN(kMaxRecordBatchSize, recordOperations.count);
    NSInteger batchSequenceNumber = sequenceNumber;
    NSInteger latestSequenceNumber = [recordOperations lastObject].sequenceNumber;
    
    NSInteger totalItemsSynced = syncedItemCount;
    
    // Loop through operations to build sets of changes and deletes
    while (syncThingIds.count + removeThingIds.count < count && recordOperations.count > 0)
    {
        MHVRecordOperation *operation = [recordOperations firstObject];
        
        [recordOperations removeObject:operation];
        
        if ([operation.operation isEqualToString:@"Delete"])
        {
            [removeThingIds addObject:operation.thingId];
        }
        else if ([self.syncTypes containsObject:operation.typeId])
        {
            [syncThingIds addObject:operation.thingId];
        }
        
        MHVRecordOperation *nextOperation = [recordOperations firstObject];
        
        // Several operations may share the same sequence number. To ensure all operations for a
        // given sequence are included in the batch, we increment the batch sequence number only
        // after all operations for a given sequence have been added to the batch.
        if (batchSequenceNumber != nextOperation.sequenceNumber)
        {
            batchSequenceNumber = operation.sequenceNumber;
        }
    }
    
    //Make sure deleted things are not in the set to update
    [syncThingIds minusSet:removeThingIds];
    
    if (removeThingIds.count == 0 && syncThingIds.count == 0)
    {
        if (recordOperations.count > 0)
        {
            [self syncRecordOperations:recordOperations
                              recordId:recordId
                       syncedItemCount:totalItemsSynced
                        sequenceNumber:batchSequenceNumber
                            completion:completion];
        }
        else
        {
            NSDate *now = [NSDate date];
            
            [self.database updateLastCompletedSyncDate:now
                              lastCacheConsistencyDate:now
                                        sequenceNumber:batchSequenceNumber
                                              recordId:recordId
                                            completion:^(NSError * _Nullable error)
             {
                 if (error)
                 {
                     MHVLOG(@"ThingCache: Error updating record: %@", error);
                 }
                 
                 if (completion)
                 {
                     completion(totalItemsSynced, error);
                 }
             }];
        }
        
    }
    else
    {
        [self processDeleteThingIds:removeThingIds
                     updateThingIds:syncThingIds
                           recordId:recordId
                batchSequenceNumber:batchSequenceNumber
               latestSequenceNumber:latestSequenceNumber
                         completion:^(NSInteger syncedItemCount, NSError * _Nullable error)
        {
            NSInteger totalSynced = syncedItemCount + totalItemsSynced;
            
            if (recordOperations.count > 0)
            {
                [self syncRecordOperations:recordOperations
                                  recordId:recordId
                           syncedItemCount:totalSynced
                            sequenceNumber:batchSequenceNumber
                                completion:completion];
            }
            else
            {
                completion(totalSynced, error);
            }
           
        }];
    }
}

- (void)processDeleteThingIds:(NSSet *)deleteThingIds
               updateThingIds:(NSSet *)updateThingIds
                     recordId:(NSString *)recordId
          batchSequenceNumber:(NSInteger)batchSequenceNumber
         latestSequenceNumber:(NSInteger)latestSequenceNumber
                   completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVLOG(@"ThingCache: Cache record has %li deletes and %li changes", deleteThingIds.count, updateThingIds.count);
    
    //Remove any deleted things from this record
    [self.database deleteCachedThingsWithThingIds:deleteThingIds.allObjects
                                         recordId:recordId
                                       completion:^(NSError * _Nullable error)
     {
         if (!error)
         {
             //Sync to add/update things
             [self synchronizeThingIds:updateThingIds.allObjects
                              recordId:recordId
                   batchSequenceNumber:batchSequenceNumber
                  latestSequenceNumber:latestSequenceNumber
                            completion:^(NSInteger syncedItemCount, NSError * _Nullable error)
              {
                  if (error)
                  {
                      completion(deleteThingIds.count, error);
                  }
                  else
                  {
                      completion(syncedItemCount + deleteThingIds.count, nil);
                  }
              }];
         }
         else
         {
             if (completion)
             {
                 completion(0, error);
             }
         }
     }];
}

- (void)synchronizeThingIds:(NSArray<NSString *> *)thingIds
                   recordId:(NSString *)recordId
        batchSequenceNumber:(NSInteger)batchSequenceNumber
       latestSequenceNumber:(NSInteger)latestSequenceNumber
                 completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thingIds);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if ([NSString isNilOrEmpty:recordId])
    {
        if (completion)
        {
            completion(0, [NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    if ([NSArray isNilOrEmpty:thingIds])
    {
        if (completion)
        {
            completion(0, nil);
        }
        return;
    }
    
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingIDs:[[MHVStringCollection alloc] initWithArray:thingIds]];
    query.shouldUseCachedResults = NO;
    
    __weak __typeof__(self)weakSelf = self;
    
    [self.connection.thingClient getThingsWithQuery:query
                                           recordId:[[NSUUID alloc] initWithUUIDString:recordId]
                                         completion:^(MHVThingQueryResult * _Nullable result, NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error performing GetThings: %@", error);
             if (completion)
             {
                 completion(0, error);
             }
         }
         else
         {
             [weakSelf.database synchronizeThings:result.things
                                         recordId:recordId
                              batchSequenceNumber:batchSequenceNumber
                             latestSequenceNumber:latestSequenceNumber
                                       completion:completion];
         }
     }];
}



#pragma mark - KVO on connection's personInfo

- (void)startObserving
{
    if (self.connection)
    {
        [self.connection addObserver:self forKeyPath:kPersonInfoKeyPath options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)stopObserving
{
    if (self.connection)
    {
        [self.connection removeObserver:self forKeyPath:kPersonInfoKeyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.connection && [keyPath isEqual:kPersonInfoKeyPath])
    {
        if (self.connection.personInfo.records.count > 0)
        {
            // The SDK currently can not remove authorization for a record, but can only deauthorize all
            // So could need to add new authorized records (which startCache will do)
            [self startCache];
        }
        else
        {
            [self clearAllCachedDataWithCompletion:nil];
        }
    }
}

@end

