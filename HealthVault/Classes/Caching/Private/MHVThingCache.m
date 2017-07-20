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
#import "NSArray+MHVThing.h"
#import "NSArray+Utils.h"
#import "MHVErrorConstants.h"
#import "MHVServiceResponse.h"
#import "MHVNetworkObserverProtocol.h"

typedef NS_ENUM(NSUInteger, MHVThingOperationType)
{
    MHVThingOpertaionTypeCreate = 0,
    MHVThingOpertaionTypeUpdate,
    MHVThingOpertaionTypeDelete
};

typedef void (^MHVSyncResultCompletion)(NSInteger syncedItemCount, NSError *_Nullable error);

static NSString *const kPersonInfoKeyPath = @"personInfo";
static NSUInteger const kMaxRecordBatchSize = 240;
static NSString *const kCacheStatusKey = @"CacheStatus";
static NSString *const kRecordOperationsKey = @"RecordOperations";
static NSString *const kSyncedItemCountKey = @"SyncedItemCount";

@interface MHVThingCache ()

@property (nonatomic, weak)   NSObject<MHVConnectionProtocol>                       *connection;
@property (nonatomic, strong) id<MHVNetworkObserverProtocol>                        networkObserver;
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
                      networkObserver:(id<MHVNetworkObserverProtocol>)networkObserver
                   automaticStartStop:(BOOL)automaticStartStop
{
    MHVASSERT_PARAMETER(database);
    MHVASSERT_PARAMETER(networkObserver);
    MHVASSERT_PARAMETER(connection);
    MHVASSERT_PARAMETER(connection.cacheConfiguration);
    MHVASSERT_PARAMETER(connection.cacheConfiguration.cacheTypeIds);
    
    self = [super init];
    if (self)
    {
        _database = database;
        _connection = connection;
        _networkObserver = networkObserver;
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

- (void)cachedResultsForQueries:(NSArray<MHVThingQuery *> *)queries
                       recordId:(NSUUID *)recordId
                     completion:(void(^)(NSArray<MHVThingQueryResult *> *_Nullable resultCollection, NSError *_Nullable error))completion;
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
         
         // When all results have been retrieved, build NSArray<MHVThingQueryResult *>
         [MHVAsyncTask waitForAll:tasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
          {
              NSMutableArray<MHVThingQueryResult *> *combinedResults = [NSMutableArray new];
              for (MHVAsyncTaskResult *taskResult in taskResults)
              {
                  if (taskResult.error)
                  {
                      completion(nil, taskResult.error);
                      
                      return nil;
                  }
                  
                  if (taskResult.result)
                  {
                      [combinedResults addObject:taskResult.result];
                  }
              }
              
              if (combinedResults.count != queries.count)
              {
                  //No error, but results not equal to queries (not all quaries are cacheable?), don't return partial results
                  completion(nil, nil);
              }
              else
              {
                  completion(combinedResults, nil);
              }
              
              return nil;
          }];
     }];
}

- (void)addThings:(NSArray<MHVThing *> *)things
         recordId:(NSUUID *)recordId
       completion:(void (^)(NSError * _Nullable))completion
{
    // Validate the input parameters
    NSError *error = [self errorForAddUpdateDeleteThings:things recordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    // Add Thing metadata
    [self fillThingsMetadata:things created:YES updated:YES];
    
    [self.database createCachedThings:things
                             recordId:recordId.UUIDString
                           completion:completion];
}

- (void)updateThings:(NSArray<MHVThing *> *)things
            recordId:(NSUUID *)recordId
          completion:(void (^)(NSError * _Nullable))completion
{
    NSError *error = [self errorForAddUpdateDeleteThings:things recordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    // Add Thing metadata
    [self fillThingsMetadata:things created:NO updated:YES];
    
    [self.database updateCachedThings:things
                             recordId:recordId.UUIDString
                           completion:^(NSError * _Nullable error)
    {
        // Check if any of the Things have a pending method (A Thing who's thingID property is the same as a pendingMethods
        // identifier property has not been synchronized with HealthVault.)
        [self pendingMethodsForThings:things
                             recordId:recordId
                         shouldUpdate:YES
                           completion:^(NSArray<MHVPendingMethod *> * _Nullable pendingMethods, NSError * _Nullable error)
         {
             if (error)
             {
                 if (completion)
                 {
                     completion(error);
                 }
                 return;
             }
             else if (pendingMethods.count > 0)
             {
                 // Update any pending methods in the cache. The pending Thing has been updated before a synchronization has
                 // occured - Update the pending method to ensure the local cache and HealthVault remain in sync.
                 [self.database cachePendingMethods:pendingMethods
                                         completion:completion];
                 return;
             }
             
             if (completion)
             {
                 completion(nil);
             }
         }];
    }];
}

- (void)deleteThings:(NSArray<MHVThing *> *)things
            recordId:(NSUUID *)recordId
          completion:(void(^)(NSError *_Nullable error))completion
{
    // Validate the input parameters
    NSError *error = [self errorForAddUpdateDeleteThings:things recordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    // Delete the things from the cache
    [self.database deleteCachedThingsWithThingIds:[things arrayOfThingIds]
                                         recordId:recordId.UUIDString
                                       completion:^(NSError * _Nullable error)
    {
        // Check if any of the Things have a pending method (A Thing who's thingID property is the same as a pendingMethods
        // identifier property has not been synchronized with HealthVault.)
        [self pendingMethodsForThings:things
                             recordId:recordId
                         shouldUpdate:NO
                           completion:^(NSArray<MHVPendingMethod *> * _Nullable pendingMethods, NSError * _Nullable error)
        {
            if (error)
            {
                if (completion)
                {
                    completion(error);
                }
                return;
            }
            else if (pendingMethods.count > 0)
            {
                // Delete any pending methods in the cache. The pending Thing has been deleted before a synchronization has
                // occured - Delete the pending method to ensure the local cache and HealthVault remain in sync.
                [self.database deletePendingMethods:pendingMethods
                                         completion:completion];
                return;
            }
            
            if (completion)
            {
                completion(nil);
            }
        }];
    }];
}

- (void)pendingMethodsForThings:(NSArray<MHVThing *> *)things
                       recordId:(NSUUID *)recordId
                   shouldUpdate:(BOOL)shouldUpdate
                     completion:(void (^)(NSArray<MHVPendingMethod *> *_Nullable pendingMethods, NSError *_Nullable error))completion
{
    [self.database fetchPendingMethodsForRecordId:recordId.UUIDString
                                       completion:^(NSArray<MHVPendingMethod *> * _Nullable pendingMethods, NSError * _Nullable error)
     {
         NSMutableArray<MHVPendingMethod *> *methods = [NSMutableArray new];
         
         for (MHVPendingMethod *method in pendingMethods)
         {
             for (MHVThing *thing in things)
             {
                 if ([thing.thingID isEqualToString:method.identifier])
                 {
                     if (shouldUpdate)
                     {
                         // Remove the temporary key
                         thing.key = nil;
                         
                         // Create new parameters
                         XWriter *writer = [XWriter new];
                         [writer writeStartElement:@"info"];
                         [XSerializer serialize:thing withRoot:@"thing" toWriter:writer];
                         [writer writeEndElement];
                         method.parameters = [writer newXmlString];
                     }
                     
                     [methods addObject:method];
                 }
             }
         }
         
         if (completion)
         {
             completion(methods, error);
         }
         
     }];
}

- (NSError *)errorForAddUpdateDeleteThings:(NSArray<MHVThing *> *)things
                                  recordId:(NSUUID *)recordId
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_TRUE(things.count > 0);
    MHVASSERT_PARAMETER(recordId);
    
    if ([NSArray isNilOrEmpty:things])
    {
        return [NSError MVHInvalidParameter:@"The 'things' collection is nil or empty."];
    }
    
    if (!recordId)
    {
        return[NSError MVHInvalidParameter:@"The 'recordId' parameter is nil"];
    }
    
    return nil;
}

- (void)fillThingsMetadata:(NSArray<MHVThing *> *)things created:(BOOL)created updated:(BOOL)updated
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

- (void)addPendingThings:(NSArray<MHVThing *> *)things
                recordId:(NSUUID *)recordId
              completion:(void(^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_TRUE(things.count > 0);
    MHVASSERT_PARAMETER(recordId);
    
    if ([NSArray isNilOrEmpty:things])
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter:@"The 'things' collection is nil or empty."]);
        }
        return;
    }
    
    if (!recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter:@"The 'recordId' parameter is nil"]);
        }
        return;
    }
    
    [self fillThingsMetadata:things created:YES updated:YES];
    
    [self.database createPendingCachedThings:things
                                    recordId:recordId.UUIDString
                                  completion:completion];
}

- (void)deletePendingMethod:(MHVPendingMethod *)pendingMethod completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(pendingMethod);
    
    if (!pendingMethod)
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

#pragma mark - Method caching

- (void)cacheMethod:(MHVMethod *)method
             things:(NSArray<MHVThing *> *)things
         completion:(void (^)(NSArray<MHVThingKey *> *_Nullable keys, NSError *_Nullable error))completion
{
    MHVThingOperationType operationType = [self operationTypeForMethod:method things:things];
    
    // 1. Prepare the method by removing any 'placeholder' Things.
    MHVAsyncTask *prepareMethodTask = [[self taskToPrepareMethod:method
                                                   operationType:operationType
                                                   thingsToCache:things] start];
    
    // 2. Add the method call to the cache.
    MHVAsyncTask *cacheMethodTask = [prepareMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                      task:[self taskToCacheMethods]];
    
    // 3. Add, update, or delete things from the cache.
    MHVAsyncTask *addUpdateOrDeleteTask;
    
    if (operationType == MHVThingOpertaionTypeCreate)
    {
        // Add things to the cache (with no keys - They will be purged the next sync)
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskToAddPendingThings:things recordId:method.recordId]];
        
    }
    else if (operationType == MHVThingOpertaionTypeUpdate)
    {
        // Update things in the cache
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskToUpdatePendingThings:things recordId:method.recordId]];
    }
    else if (operationType == MHVThingOpertaionTypeDelete)
    {
        // Delete things from the cache
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskToDeletePendingThings:things recordId:method.recordId]];
    }
    
    // 4. If an error occurs during the caching process we need to cleanup the cache by removing the cached methods.
    MHVAsyncTask *failureTask = [addUpdateOrDeleteTask continueWithTask:[self taskForFailureToCacheMethod]];
    
    // 5. Complete with any errors
    [failureTask continueWithBlock:^id(NSArray<NSError *> *errors)
    {
        NSError *error = nil;
        
        NSMutableArray<MHVThingKey *> *keys = nil;
        
        if (errors)
        {
            NSMutableString *errorMessage = [NSMutableString new];
            for (NSError *error in errors)
            {
                // Print any errors that occur during the process of caching a method or things
                MHVASSERT_MESSAGE(error.localizedDescription);
                
                [errorMessage appendFormat:@"%@ ", error.localizedDescription];
            }
            
            error = [NSError MHVCacheError:errorMessage];
        }
        else
        {
            keys = [NSMutableArray new];
            
            for (int i = 0; i < things.count; i++)
            {
                MHVThingKey *key = things[i].key;
                
                if (key)
                {
                    [keys addObject:things[i].key];
                }
            }
        }
        
        if (completion)
        {
            completion(keys, error);
        }
        
        return nil;
    }];
}

// Creates new, cacheble method for the things in a given thing collection.
// A thing collection might contain 'placeholder' Things (Newly created things that have been added to the cache but
// not synchronized with HealthVault). References to 'placeholder' Things will be removed from the method, and the
// original pending method will be updated or deleted.
- (MHVAsyncTask*)taskToPrepareMethod:(MHVMethod *)method
                       operationType:(MHVThingOperationType)operationType
                       thingsToCache:(NSArray<MHVThing *> *)thingsToCache
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
    {
        NSDate *now = [NSDate date];
        NSMutableArray<MHVPendingMethod *> *pendingMethods = [NSMutableArray new];
        
        // To support updating and deleting Things that have been created locally ('placeholder' Things), if there are multiple things
        // in a things collection, they must be separated into individual methods.
        if (operationType == MHVThingOpertaionTypeCreate)
        {
            for (int i = 0; i < thingsToCache.count; i++)
            {
                MHVPendingMethod *pendingMethod = [[MHVPendingMethod alloc] initWithOriginalRequestDate:now
                                                                                                 method:method];
                
                MHVThing *newThing = thingsToCache[i];

                // Create new method parameters for a single Thing create.
                pendingMethod.parameters = [self parametersForThings:@[newThing]];
                
                // Associate the thing and the pending method by setting the thing id to the pending method identifier.
                newThing.key = [[MHVThingKey alloc] initWithID:pendingMethod.identifier];
                
                [pendingMethods addObject:pendingMethod];
            }
            
            finish([MHVAsyncTaskResult withResult:pendingMethods]);
            return;
        }
        
        // Fetch the 'placeholder' Things for the record id.
        [self.database fetchPendingThingsForRecordId:method.recordId.UUIDString
                                          completion:^(NSArray<MHVThing *> * _Nullable things, NSError * _Nullable error)
        {
            if (error)
            {
                cancel([MHVAsyncTaskResult withError:error]);
            }
            else
            {
                NSMutableArray<MHVThing *> *thingsArray = [NSMutableArray new];
                
                // Check all Things to cache for any 'placeholder' Things so they can be removed from the method parameters
                for (MHVThing *thingToCache in thingsToCache)
                {
                    if (![things containsThingID:thingToCache.thingID])
                    {
                        [thingsArray addObject:thingToCache];
                    }
                }
                
                if (thingsArray.count == 0)
                {
                    // If all Things to cache are 'placeholder' Things do not cache the method. (Just finish with nil).
                    finish([MHVAsyncTaskResult withResult:nil]);
                    return;
                }
                else if (thingsArray.count < thingsToCache.count)
                {
                    // If a Thing to cache has been removed re-create the method parameters without 'placeholder' Things.
                    if (operationType == MHVThingOpertaionTypeDelete)
                    {
                        method.parameters = [self parameterOfThingIdsFromThings:thingsArray];
                    }
                    else
                    {
                        method.parameters = [self parametersForThings:thingsArray];
                    }
                }
                
                [pendingMethods addObject:[[MHVPendingMethod alloc] initWithOriginalRequestDate:now method:method]];
                
                finish([MHVAsyncTaskResult withResult:pendingMethods]);
            }
        }];
    }];
}

// Add methods to the cache to be re-issued next sync
- (MHVAsyncTask *)taskToCacheMethods
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult *input, void (^finish)(id), void (^cancel)(id))
    {
        NSArray<MHVPendingMethod *> *pendingMethods = input.result;
        
        if (pendingMethods && pendingMethods.count > 0)
        {
            [self.database cachePendingMethods:pendingMethods
                                    completion:^(NSError * _Nullable error)
            {
                MHVAsyncTaskResult *result = [MHVAsyncTaskResult withError:error];
                
                if (error)
                {
                    cancel(result);
                }
                else
                {
                    result.result = pendingMethods;
                    finish(result);
                }
            }];
        }
        else
        {
            finish(input);
        }
    }];
}

// Adds new things to the cache. *Note - These new things will have no keys and will be purged during the next sync.
- (MHVAsyncTask *)taskToAddPendingThings:(NSArray<MHVThing *> *)things
                                recordId:(NSUUID *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult *input, void (^finish)(id), void (^cancel)(id))
    {
        [self addPendingThings:things
                      recordId:recordId
                    completion:^(NSError * _Nullable error)
         {
             input.error = error;
             
             if (error)
             {
                 cancel(input);
             }
             else
             {
                 finish(input);
             }
         }];
    }];
}

// Updates existing things in the cache.
- (MHVAsyncTask *)taskToUpdatePendingThings:(NSArray<MHVThing *> *)things
                                   recordId:(NSUUID *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult *input, void (^finish)(id), void (^cancel)(id))
    {
        [self updateThings:things
                  recordId:recordId
                completion:^(NSError * _Nullable error)
         {
             input.error = error;
             
             if (error)
             {
                 cancel(input);
             }
             else
             {
                 finish(input);
             }
         }];
    }];
}

// Deletes things from the cache.
- (MHVAsyncTask *)taskToDeletePendingThings:(NSArray<MHVThing *> *)things
                                   recordId:(NSUUID *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult *input, void (^finish)(id), void (^cancel)(id))
    {
        [self deleteThings:things
                  recordId:recordId
                completion:^(NSError * _Nullable error)
         {
             input.error = error;
             
             if (error)
             {
                 cancel(input);
             }
             else
             {
                 finish(input);
             }
         }];
    }];
}

// If an error occurs during a previous step, the method that was added is deleted
- (MHVAsyncTask *)taskForFailureToCacheMethod
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult *input, void (^finish)(id), void (^cancel)(id))
    {
        if (input.error)
        {
            NSMutableArray *errors = [NSMutableArray new];
            
            [errors addObject:input.error];
            
            if (input.result)
            {
                [self.database deletePendingMethods:input.result
                                         completion:^(NSError * _Nullable error)
                 {
                     if (error)
                     {
                         [errors addObject:error];
                     }
                     
                     cancel(errors);
                 }];
            }
            else
            {
                cancel(errors);
            }
        }
        else
        {
            finish(nil);
        }
    }];
}

- (MHVThingOperationType)operationTypeForMethod:(MHVMethod *)method
                                         things:(NSArray<MHVThing *> *)things
{
    if ([method.name isEqualToString:@"RemoveThings"])
    {
        return MHVThingOpertaionTypeDelete;
    }
    else if (things.firstObject.key)
    {
        return MHVThingOpertaionTypeUpdate;
    }
    
    return MHVThingOpertaionTypeCreate;
}

- (NSString *)parametersForThings:(NSArray<MHVThing *> *)things
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    {
        for (MHVThing *thing in things)
        {
            if ([self isValidObject:thing])
            {
                [XSerializer serialize:thing withRoot:@"thing" toWriter:writer];
            }
        }
    }
    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (NSString *)parameterOfThingIdsFromThings:(NSArray<MHVThing *> *)things
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    {
        for (MHVThing *thing in things)
        {
            if ([self isValidObject:thing.key])
            {
                [XSerializer serialize:thing.key withRoot:@"thing-id" toWriter:writer];
            }
        }
    }
    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (BOOL)isValidObject:(id)obj
{
    if ([obj respondsToSelector:@selector(validate)])
    {
        MHVClientResult *validationResult = [obj validate];
        if (validationResult.isError)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Syncing

- (void)startSyncTimer
{
    if (self.syncTimer.isValid)
    {
        [self.syncTimer invalidate];
    }
    
    self.syncTimer = [NSTimer timerWithTimeInterval:self.cacheConfiguration.syncIntervalSeconds
                                             target:self
                                           selector:@selector(syncTimerAction)
                                           userInfo:nil
                                            repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.syncTimer forMode:NSDefaultRunLoopMode];
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

- (void)prepareCacheForRecords:(NSArray<MHVRecord *> *)records
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
    
    if (self.networkObserver.currentNetworkStatus == MHVNetworkStatusNoNetwork)
    {
        MHVLOG(@"\nCould not complete sync because the internet connection is offline.\n");
        
        if (completion)
        {
            completion(0, [NSError error:[NSError MHVNetworkError] withDescription:@"The internet connection is offline."]);
        }
        
        // Sync complete, start timer for next sync
        [self startSyncTimer];
        
        return;
    }
    
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
    
    NSMutableArray<MHVAsyncTask *> *endTasks = [NSMutableArray new];
    
    MHVLOG(@"ThingCache: %li Records to sync", recordIds.count);
    
    // Create array of tasks, one complete sync group for each Record. If any task within a group cancels (if there is an error) all the remaining tasks
    // are cancelled.
    for (NSString *recordId in recordIds)
    {
        MHVAsyncTask *cacheStatusTask = nil;
        
        MHVAsyncTask *lastTask = [endTasks lastObject];
        
        if (lastTask)
        {
            // If there is more than one record, append the start of the next record sync task group to the end of the previous sync task group
            cacheStatusTask = [lastTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                       task:[self taskForCacheStatusWithRecordId:recordId]];
        }
        else
        {
            // 1. Check the status of the cache and pass the status object to the next task or cancel with an error.
            cacheStatusTask = [[self taskForCacheStatusWithRecordId:recordId] start];
        }
        
        // 2. Check for any pending method requests, execute them and delete the pending method after successful execution. Pass
        //    The status object onto the next task, or cancel with an error (if any occur).
        MHVAsyncTask *pendingMethodsTask = [cacheStatusTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                           task:[self taskForPendingMethodsWithRecordId:recordId]];
        
        // 3. Fetch the latest record operations since the last sync. Finish and pass the status object and record operations to the next task. Cancel
        // with an error should an error occur.
        MHVAsyncTask *recordOperationsTask = [pendingMethodsTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                                task:[self taskForRecordOperationsWithRecordId:recordId]];
        
        // 4. Sync the record operations. Finish with the count of the items synced or cancel with an error.
        MHVAsyncTask *syncRecordsTask = [recordOperationsTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                             task:[self taskForSyncRecordOperationsWithRecordId:recordId]];
        // 5. Delete any 'placeholder' things from the cache and
        MHVAsyncTask *clearPlaceholderThingsTask = [syncRecordsTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                                   task:[self taskForClearingPlaceholderThings:recordId]];
        
        // Add the last task of each sync group so the total number of synced items can be calculated at the end of ALL sync groups
        [endTasks addObject:clearPlaceholderThingsTask];
    }
    
    // Wait for all sync groups to complete, then merge the results *Note there shold only be one error as all tasks are set to continue
    // only if the previous task was not cancelled.
    [MHVAsyncTask waitForAll:endTasks beforeBlock:^id(NSArray<MHVAsyncTaskResult<NSDictionary *> *> *taskResults)
    {
         NSError *error = nil;
         NSInteger syncedItemTotal = 0;
         
         for (MHVAsyncTaskResult<NSDictionary *> *result in taskResults)
         {
             if (result.error)
             {
                 error = result.error;
             }
             else
             {
                 NSNumber *syncedItemTotalNumber = result.result[kSyncedItemCountKey];
                 
                 if (syncedItemTotalNumber)
                 {
                     syncedItemTotal += syncedItemTotalNumber.integerValue;
                 }
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

#pragma mark - Sync Tasks

// Task to get the status of the cache. Will CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<NSDictionary *>.
- (MHVAsyncTask *)taskForCacheStatusWithRecordId:(NSString *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
    {
        MHVLOG(@"\nChecking the status of the Thing cache...\n");
        
        [self.database cacheStatusForRecordId:recordId
                                   completion:^(id<MHVCacheStatusProtocol> _Nullable status, NSError * _Nullable error)
        {
            if (error)
            {
                MHVLOG(@"\nThe Thing cache returned an error while checking the status:%@\n", error.localizedDescription);
                
                cancel([MHVAsyncTaskResult withError:error]);
            }
            if (!status)
            {
                MHVLOG(@"\nThe Thing cache failed to return a valid id<MHVCacheStatusProtocol> object.");
                
                cancel([MHVAsyncTaskResult withError:[NSError MHVCacheError:@"The call to fetch the cache status failed to return a valid id<MHVCacheStatusProtocol> object."]]);
            }
            else
            {
                MHVLOG(@"\nThe Thing cache status check completed successfully. The cache is %@ and the last sync date was %@.\n", status.isCacheValid ? @"valid" : @"invalid", status.lastCompletedSyncDate);
                
                // Create a new mutable dictionary that will be passed through to the next tasks.
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:status forKey:kCacheStatusKey];
                
                finish([MHVAsyncTaskResult withResult:result]);
            }
        }];
    }];
}

// Task to get pending methods. Will CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<NSDictionary *>.
- (MHVAsyncTask *)taskForPendingMethodsWithRecordId:(NSString *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult<NSMutableDictionary *> *input, void (^finish)(id), void (^cancel)(id))
    {
        MHVLOG(@"\nChecking the Thing cache for pending methods...\n");
        
        [self.database fetchPendingMethodsForRecordId:recordId
                                           completion:^(NSArray<MHVPendingMethod *> * _Nullable pendingMethods, NSError * _Nullable error)
        {
            if (error)
            {
                MHVLOG(@"\nThe Thing cache returned an error while checking for pending methods:%@\n", error.localizedDescription);
                
                cancel([MHVAsyncTaskResult withError:error]);
            }
            else
            {
                if (pendingMethods.count < 1)
                {
                    MHVLOG(@"\nThe Thing cache has no pending methods.\n");
                    
                    // Pass the database status to the next task
                    finish(input);
                    return;
                }
                
                MHVLOG(@"\nFound %li pending %@. Preparing for execution.\n", pendingMethods.count, pendingMethods.count == 1 ? @"method" : @"methods");
                
                // Make sure the methods are sorted in the order they were originally attempted.
                NSArray<MHVPendingMethod *> *methods = [pendingMethods sortedArrayUsingComparator:^NSComparisonResult(MHVPendingMethod *method1, MHVPendingMethod *method2)
                {
                    return [method1.originalRequestDate compare:method2.originalRequestDate];
                }];
                
                NSMutableArray<MHVAsyncTask *> *methodsTasks = [NSMutableArray new];
                
                for (int i = 0; i < methods.count; i++)
                {
                    MHVPendingMethod *method = methods[i];
                    
                    [methodsTasks addObject:[self taskToExecutePendingMethod:method]];
                }
                
                // Execute the sequence of methods in order. If a task is cancelled (an error occurs) stop execution
                [MHVAsyncTask startSequenceOfTasks:methodsTasks withContinuationOption:MHVTaskContinueIfPreviousTaskWasNotCanceled];
                
                [MHVAsyncTask waitForAll:methodsTasks beforeBlock:^id(NSArray<MHVAsyncTaskResult *> *taskResults)
                {
                    for (MHVAsyncTaskResult *taskResult in taskResults)
                    {
                        if (taskResult.error)
                        {
                            cancel(taskResult);
                            return nil;
                        }
                    }
                    
                    // Set the synced item count and pass the dictionary containing the database status to the next task.
                    [input.result setObject:@(pendingMethods.count) forKey:kSyncedItemCountKey];
                    
                    finish(input);
                    return nil;
                }];
            }
        }];
    }];
}

// Task to execute pending methods. Will CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<nil>.
- (MHVAsyncTask *)taskToExecutePendingMethod:(MHVPendingMethod *)pendingMethod
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(id), void (^cancel)(id))
    {
        MHVLOG(@"\nExecuting pending method %@ with identifier: %@.\n", pendingMethod.name, pendingMethod.identifier);
        
        [self.connection executeHttpServiceOperation:pendingMethod
                                          completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
        {
            if (error)
            {
                MHVLOG(@"\nAn error occured while attempting to execute the pending method:%@\n", error.localizedDescription);
            }

            MHVLOG(@"\nDeleting the pending method from the Thing cache.\n");
            
            [self.database deletePendingMethods:@[pendingMethod]
                                     completion:^(NSError * _Nullable error)
            {
                if (error)
                {
                    MHVLOG(@"\nAn error occured while attempting to delete the pending method:%@\n", error.localizedDescription);
                    
                    cancel([MHVAsyncTaskResult withError:error]);
                }
                else
                {
                    MHVLOG(@"\nPending method deleted.\n");
                    
                    finish([MHVAsyncTaskResult withResult:nil]);
                }
            }];
        }];
    }];
}

// Task to get the record operations since the last sync. Will CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<NSNumber *>.
- (MHVAsyncTask *)taskForRecordOperationsWithRecordId:(NSString *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult<NSMutableDictionary *> *input, void (^finish)(id), void (^cancel)(id))
    {
        id<MHVCacheStatusProtocol> status = input.result[kCacheStatusKey];
        
        if (!status)
        {
            cancel([MHVAsyncTaskResult withError:[NSError MHVCacheError:@"Could not determine the status of the cache database."]]);
            return;
        }
        
        // If the lastCacheConsistencyDate value is set and the time between now and the lastCompletedSyncDate is < syncIntervalSeconds don't sync.
        if (status.lastCacheConsistencyDate && fabs([status.lastCompletedSyncDate timeIntervalSinceNow]) < self.cacheConfiguration.syncIntervalSeconds)
        {
            MHVLOG(@"ThingCache: Record is up to date, synced %li seconds ago", (long)fabs([status.lastCompletedSyncDate timeIntervalSinceNow]));
            
            finish([MHVAsyncTaskResult withResult:nil]);
            return;
        }
        
        MHVLOG(@"\nChecking HealthVault for new record operations created since %@.\n", status.lastCacheConsistencyDate);
        
        [self.connection.thingClient getRecordOperations:status.newestCacheSequenceNumber
                                                recordId:[[NSUUID alloc] initWithUUIDString:recordId]
                                              completion:^(MHVGetRecordOperationsResult * _Nullable result, NSError * _Nullable error)
        {
            if (error)
            {
                MHVLOG(@"\nAn error occured while attempting to fetch the record operations:%@\n", error.localizedDescription);
                
                cancel([MHVAsyncTaskResult withError:error]);
            }
            else if (!result.operations)
            {
                MHVLOG(@"\nNo new record operations were found.\n");
                
                // No record operations object
                finish(input);
            }
            else
            {
                MHVLOG(@"\nFound %li new record %@\n", result.operations.count, result.operations.count == 1 ? @"operation" : @"operations");
                
                // Add the result operations to the result dictionary.
                [input.result setObject:result.operations forKey:kRecordOperationsKey];
                
                finish(input);
            }
        }];
    }];
}

// Task to sync record operations. Will CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<NSDictionary *>.
- (MHVAsyncTask *)taskForSyncRecordOperationsWithRecordId:(NSString *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult<NSMutableDictionary *> *input, void (^finish)(id), void (^cancel)(id))
    {
        id<MHVCacheStatusProtocol> status = [input.result objectForKey:kCacheStatusKey];
        NSArray<MHVRecordOperation *> *operations = [input.result objectForKey:kRecordOperationsKey];
        NSInteger syncedCount = ([input.result objectForKey:kSyncedItemCountKey] != nil) ? ((NSNumber *)input.result[kSyncedItemCountKey]).integerValue : 0;
        
        // If there are bo operations there is no data to be synced, update the last sync dates and finish with a count of 0.
        if (!operations)
        {
            NSDate *now = [NSDate date];
            
            MHVLOG(@"\nNo new record operations were found, updating cache sync date %@.\n", now);
            
            [self.database updateLastCompletedSyncDate:now
                              lastCacheConsistencyDate:now
                                        sequenceNumber:status.newestHealthVaultSequenceNumber
                                              recordId:recordId
                                            completion:^(NSError * _Nullable error)
            {
                if (error)
                {
                    MHVLOG(@"ThingCache: Error updating record: %@", error);
                    
                    cancel([MHVAsyncTaskResult withError:error]);
                    return;
                }
                
                MHVLOG(@"\nUpdating cache's last sync date was successful.\n");
                
                finish(input);
            }];
        }
        else
        {
            MHVLOG(@"\nStarting cache synchronization...\n");
            
            [self syncRecordOperations:operations
                              recordId:recordId
                       syncedItemCount:0
                        sequenceNumber:status.newestCacheSequenceNumber
                            completion:^(NSInteger syncedItemCount, NSError *_Nullable error)
             {
                 if (error)
                 {
                     MHVLOG(@"ThingCache: Error syncing records: %@", error);
                     
                     cancel([MHVAsyncTaskResult withError:error]);
                 }
                 else
                 {
                     MHVLOG(@"\nSuccessfully synchronized %li %@.\n", syncedItemCount, syncedItemCount == 1 ? @"Thing" : @"Things");
                     
                     // Add the synced items.
                     [input.result setObject:@(syncedCount + syncedItemCount) forKey:kSyncedItemCountKey];
                     
                     finish(input);
                 }
             }];
        }
    }];
}

// Task to delete Things that were created in the database as a 'placeholder' for offline use. When creating new things and there is no internet
// connection placeholder things will be created and added to the database. These placeholder things will have a thingid property of nil. Will
// CANCEL with an MHVAsyncTaskResult<NSError *> or FINISH with MHVAsyncTaskResult<NSNumber *> (the total things synced).
- (MHVAsyncTask *)taskForClearingPlaceholderThings:(NSString *)recordId
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(MHVAsyncTaskResult<NSNumber *> *input, void (^finish)(id), void (^cancel)(id))
    {
        MHVLOG(@"\nDeleting 'placeholder' Things from the Thing cache...\n");
        
        [self.database deletePendingThingsForRecordId:recordId
                                           completion:^(NSError * _Nullable error)
        {
            if (error)
            {
                MHVLOG(@"\nAn error occurred while deleting 'placeholder' Things:%@.\n", error.localizedDescription);
                
                cancel([MHVAsyncTaskResult withError:error]);
            }
            else
            {
                MHVLOG(@"\nSuccessfully deleted 'placeholder' Things.\n");
                
                finish(input);
            }
        }];
    }];
}

#pragma mark - Sync Internal

- (void)syncRecordOperations:(NSArray<MHVRecordOperation *> *)recordOperations
                    recordId:(NSString *)recordId
             syncedItemCount:(NSInteger)syncedItemCount
              sequenceNumber:(NSInteger)sequenceNumber
                  completion:(void (^)(NSInteger syncedItemCount, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(recordOperations);
    MHVASSERT_TRUE(recordOperations.count > 0);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if ([NSArray isNilOrEmpty:recordOperations])
    {
        if (completion)
        {
            completion(0, [NSError MVHInvalidParameter:@"The 'recordOperations' collection is nil or empty."]);
        }
        return;
    }
    
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
    NSMutableArray *mutableRecordOperations = [recordOperations mutableCopy];
    
    // Loop through operations to build sets of changes and deletes
    while (syncThingIds.count + removeThingIds.count < count && mutableRecordOperations.count > 0)
    {
        MHVRecordOperation *operation = [mutableRecordOperations firstObject];
        
        [mutableRecordOperations removeObject:operation];
        
        if ([operation.operation isEqualToString:@"Delete"])
        {
            [removeThingIds addObject:operation.thingId];
        }
        else if ([self.syncTypes containsObject:operation.typeId])
        {
            [syncThingIds addObject:operation.thingId];
        }
        
        MHVRecordOperation *nextOperation = [mutableRecordOperations firstObject];
        
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
        if (mutableRecordOperations.count > 0)
        {
            [self syncRecordOperations:mutableRecordOperations
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
            
            if (mutableRecordOperations.count > 0)
            {
                [self syncRecordOperations:mutableRecordOperations
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
    
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingIDs:thingIds];
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

