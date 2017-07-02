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

static NSString *kPersonInfoKeyPath = @"personInfo";

@interface MHVThingCache ()

@property (nonatomic, weak)   NSObject<MHVConnectionProtocol>                       *connection;
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
        
        [self startObserving];
    }
    return self;
}

- (void)dealloc
{
    [self stopObserving];
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
    
    [self.database deleteDatabaseWithCompletion:^(NSError * _Nullable error)
     {
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
    
    [self.database syncDataForRecordId:recordId.UUIDString
                            completion:^(NSDate * _Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
             return;
         }
         
         if (!isCacheValid)
         {
             completion(nil, [NSError MHVCacheError:@"Cache is not valid for record"]);
             return;
         }
         
         // If last sync date isn't set, cache isn't populated yet
         if (!lastSyncDate)
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
                                   [self.database cachedResultsForQuery:query
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
    
    [self.database addOrUpdateThings:things
                            recordId:recordId.UUIDString
                  lastSequenceNumber:-1
                          completion:^(NSInteger updateItemCount, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void (^)(NSError * _Nullable))completion
{
    [self fillThingsMetadata:things created:NO updated:YES];
    
    [self.database addOrUpdateThings:things
                            recordId:recordId.UUIDString
                  lastSequenceNumber:-1
                          completion:^(NSInteger updateItemCount, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

- (void)deleteThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion
{
    [self.database deleteThingIds:things.thingIDs.toArray
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
            thing.created = [MHVAudit new];
            thing.created.when = date;
            thing.created.personID = self.connection.personInfo.ID;
            thing.created.appID = self.connection.applicationId;
        }
        
        if (updated)
        {
            thing.updated = [MHVAudit new];
            thing.updated.when = date;
            thing.updated.personID = self.connection.personInfo.ID;
            thing.created.appID = self.connection.applicationId;
        }
        
        thing.effectiveDate = date;
    }
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
    //Dispatch so app can continue starting while cache is setup
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
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
                            
                            [self.database setupRecordIds:recordIds completion:^(NSError * _Nullable error)
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
                   });
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
                              [self.database syncDataForRecordId:recordId
                                                      completion:^(NSDate * _Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError * _Nullable error)
                               {
                                   // If the cache last sync time is still valid, don't need to sync yet
                                   if (!lastSyncDate || fabs([lastSyncDate timeIntervalSinceNow]) >= self.cacheConfiguration.syncIntervalSeconds)
                                   {
                                       [self.connection.thingClient getRecordOperations:lastSequenceNumber
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
                                                [self syncRecordOperations:result
                                                                  recordId:recordId
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
                                       MHVLOG(@"ThingCache: Record is up to date, synced %li seconds ago", (long)fabs([lastSyncDate timeIntervalSinceNow]));
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

- (void)syncRecordOperations:(MHVGetRecordOperationsResult *)recordOperations
                    recordId:(NSString *)recordId
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
    
    // Loop through operations to build sets of changes and deletes
    for (MHVRecordOperation *operation in recordOperations.operations)
    {
        if ([operation.operation isEqualToString:@"Delete"])
        {
            [removeThingIds addObject:operation.thingId];
        }
        else if ([self.syncTypes containsObject:operation.typeId])
        {
            [syncThingIds addObject:operation.thingId];
        }
    }
    
    //Make sure deleted things are not in the set to update
    [syncThingIds minusSet:removeThingIds];
    
    if (removeThingIds.count == 0 && syncThingIds.count == 0)
    {
        [self updateRecordWithNoNewData:recordId
                             completion:completion];
    }
    else
    {
        [self updateRecord:recordId
            deleteThingIds:removeThingIds
            updateThingIds:syncThingIds
        lastSequenceNumber:recordOperations.latestRecordOperationSequenceNumber
                completion:completion];
    }
}

- (void)updateRecordWithNoNewData:(NSString *)recordId
                       completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVLOG(@"ThingCache: Cache record has no changes");
    
    // Sync has no changes, update lastSyncDate
    [self.database updateRecordId:recordId
                     lastSyncDate:[NSDate date]
                   sequenceNumber:nil
                       completion:^(NSError * _Nullable error)
     {
         if (error)
         {
             MHVLOG(@"ThingCache: Error updating record: %@", error);
         }
         
         if (completion)
         {
             completion(0, error);
         }
     }];
}

- (void)updateRecord:(NSString *)recordId
      deleteThingIds:(NSSet *)deleteThingIds
      updateThingIds:(NSSet *)updateThingIds
  lastSequenceNumber:(NSInteger)lastSequenceNumber
          completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVLOG(@"ThingCache: Cache record has %li deletes and %li changes", deleteThingIds.count, updateThingIds.count);
    
    //Remove any deleted things from this record
    [self.database deleteThingIds:deleteThingIds.allObjects
                         recordId:recordId
                       completion:^(NSError * _Nullable error)
     {
         if (!error)
         {
             //Sync to add/update things
             [self syncThingIds:updateThingIds.allObjects
                       recordId:recordId
             lastSequenceNumber:lastSequenceNumber
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

- (void)syncThingIds:(NSArray<NSString *> *)thingIds
            recordId:(NSString *)recordId
  lastSequenceNumber:(NSInteger)lastSequenceNumber
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
                                         completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
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
             [weakSelf.database addOrUpdateThings:things
                                         recordId:recordId
                               lastSequenceNumber:lastSequenceNumber
                                       completion:^(NSInteger updateItemCount, NSError * _Nullable error)
              {
                  if (completion)
                  {
                      completion(updateItemCount, error);
                  }
              }];
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

