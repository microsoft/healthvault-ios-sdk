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
#import "MHVValidator.h"
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

typedef NS_ENUM(NSUInteger, MHVThingOperationType)
{
    MHVThingOpertaionTypeCreate = 0,
    MHVThingOpertaionTypeUpdate,
    MHVThingOpertaionTypeDelete
};

@interface MHVThingCache ()

@property (nonatomic, weak)   NSObject<MHVConnectionProtocol>                       *connection;
@property (nonatomic, strong) MHVThingCacheConfiguration                            *cacheConfiguration;
@property (nonatomic, strong) id<MHVThingCacheDatabaseProtocol>                     database;

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
    }
    return self;
}

#pragma mark - Thing Caching

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
    
    NSArray<NSString *> *thingIds = [things arrayOfThingIds];
    
    if ([NSArray isNilOrEmpty:thingIds])
    {
        if (completion)
        {
            completion([NSError MHVCacheError:@"Unable to find valid thignIDs for the items in the 'things' array."]);
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

#pragma mark - Helpers

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

@end

