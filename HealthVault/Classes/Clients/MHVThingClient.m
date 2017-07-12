//
// MHVThingClient.m
// MHVLib
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

#import "MHVThingClient.h"
#import "MHVCommon.h"
#import "MHVMethod.h"
#import "MHVRestRequest.h"
#import "MHVBlobDownloadRequest.h"
#import "MHVServiceResponse.h"
#import "MHVTypes.h"
#import "NSError+MHVError.h"
#import "MHVErrorConstants.h"
#import "MHVConnectionProtocol.h"
#import "MHVPersonalImage.h"
#import "MHVBlobUploadRequest.h"
#import "MHVLogger.h"
#import "MHVThingCacheProtocol.h"
#import "MHVNetworkObserverProtocol.h"
#import "MHVAsyncTask.h"

typedef NS_ENUM(NSUInteger, MHVThingOperationType)
{
    MHVThingOpertaionTypeCreate = 0,
    MHVThingOpertaionTypeUpdate,
    MHVThingOpertaionTypeDelete
};

@interface MHVThingClient ()

@property (nonatomic, weak) id<MHVConnectionProtocol> connection;
@property (nonatomic, strong) id<MHVThingCacheProtocol> cache;

@end

@implementation MHVThingClient

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection
                             cache:(id<MHVThingCacheProtocol> _Nullable)cache
{
    MHVASSERT_PARAMETER(connection);
    
    self = [super init];
    if (self)
    {
        _connection = connection;
        _cache = cache;
    }
    
    return self;
}

- (void)getThingWithThingId:(NSUUID *)thingId
                   recordId:(NSUUID *)recordId
                 completion:(void (^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thingId);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!thingId || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    [self getThingsWithQuery:[[MHVThingQuery alloc] initWithThingID:[thingId UUIDString]]
                    recordId:recordId
                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             completion(things.firstObject, nil);
         }
     }];
}

- (void)getThingsWithQuery:(MHVThingQuery *)query
                  recordId:(NSUUID *)recordId
                completion:(void (^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(query);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!query || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    [self getThingsWithQueries:[[MHVThingQueryCollection alloc] initWithObject:query]
                      recordId:recordId
                    completion:^(MHVThingQueryResultCollection *_Nullable results, NSError *_Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             completion(results.firstObject.things, nil);
         }
     }];
}

- (void)getThingsWithQueries:(MHVThingQueryCollection *)queries
                    recordId:(NSUUID *)recordId
                  completion:(void (^)(MHVThingQueryResultCollection *_Nullable results, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(queries);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!queries || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    //Give each query a unique name if it isn't already set
    for (MHVThingQuery *query in queries)
    {
        if ([NSString isNilOrEmpty:query.name])
        {
            query.name = [[NSUUID UUID] UUIDString];
        }
    }
    
#ifdef THING_CACHE
    // Check for cached results for the GetThings queries
    if (self.cache)
    {
        [self.cache cachedResultsForQueries:queries
                                   recordId:recordId
                                 completion:^(MHVThingQueryResultCollection * _Nullable resultCollection, NSError *_Nullable error)
         {
             // If error is because cache not ready or deleted, send request to HealthVault
             if (error && error.code != MHVErrorTypeCacheNotReady && error.code != MHVErrorTypeCacheDeleted)
             {
                 completion(nil, error);
             }
             else if (resultCollection)
             {
                 completion(resultCollection, nil);
             }
             else
             {
                 //No resultCollection or error, query HealthVault
                 [self getThingsWithQueries:queries recordId:recordId currentResults:nil completion:completion];
             }
         }];
    }
    else
    {
        [self getThingsWithQueries:queries recordId:recordId currentResults:nil completion:completion];
    }
    
#else
    // No caching
    [self getThingsWithQueries:queries recordId:recordId currentResults:nil completion:completion];
#endif
}

// Internal method that will fetch more pending items if not all results are returned for the query.
- (void)getThingsWithQueries:(MHVThingQueryCollection *)queries
                    recordId:(NSUUID *)recordId
              currentResults:(MHVThingQueryResultCollection *_Nullable)currentResults
                  completion:(void(^)(MHVThingQueryResultCollection *_Nullable results, NSError *_Nullable error))completion
{
    __block MHVThingQueryResultCollection *results = currentResults;
    
    MHVMethod *method = [MHVMethod getThings];
    method.recordId = recordId;
    method.parameters = [self bodyForQueryCollection:queries];
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             MHVThingQueryResults *queryResults = [self thingQueryResultsFromResponse:response];
             if (!queryResults)
             {
                 completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"MHVThingQueryResults could not be extracted from the server response."]);
                 return;
             }
             
             MHVThingQueryCollection *queriesForPendingThings = [[MHVThingQueryCollection alloc] init];
             
             // Check for any Pending things, and build queries to fetch remaining things
             for (MHVThingQueryResult *result in queryResults.results)
             {
                 if (result.hasPendingThings)
                 {
                     MHVThingKeyCollection *keys = [MHVThingKeyCollection new];
                     
                     for (MHVPendingThing *thing in result.pendingThings)
                     {
                         [keys addObject:thing.key];
                     }
                     
                     MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingKeys:keys];
                     query.name = result.name;
                     [queriesForPendingThings addObject:query];
                 }
             }
             
             // Merge with existing results if needed
             if (results)
             {
                 [results mergeThingQueryResultCollection:queryResults.results];
             }
             else
             {
                 results = queryResults.results;
             }
             
             // If there are queries to get more pending items, repeat; otherwise can call completion
             if (queriesForPendingThings.count > 0)
             {
                 [self getThingsWithQueries:queriesForPendingThings
                                   recordId:recordId
                             currentResults:results
                                 completion:completion];
                 return;
             }
             else
             {
                 completion(results, nil);
             }
         }
     }];
}

- (void)getThingsForThingClass:(Class)thingClass
                         query:(MHVThingQuery *_Nullable)query
                      recordId:(NSUUID *)recordId
                    completion:(void (^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thingClass);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!thingClass || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    MHVThingFilter *filter = [[MHVThingFilter alloc] initWithTypeClass:thingClass];
    if (!filter)
    {
        completion(nil, [NSError MVHInvalidParameter:[NSString stringWithFormat:@"%@ not found in HealthVault thing types", NSStringFromClass(thingClass)]]);
        return;
    }
    
    // Add filter to query argument, or create if argument is nil
    if (query)
    {
        [query.filters addObject:filter];
    }
    else
    {
        query = [[MHVThingQuery alloc] initWithFilter:filter];
    }
    
    [self getThingsWithQuery:query recordId:recordId completion:completion];
}

#pragma mark - Create Things

- (void)createNewThing:(MHVThing *)thing
              recordId:(NSUUID *)recordId
            completion:(void(^_Nullable)(MHVThingKey *_Nullable thingKey, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion(nil, [NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    [self createNewThings:[[MHVThingCollection alloc] initWithThing:thing]
                 recordId:recordId
               completion:^(MHVThingKeyCollection * _Nullable thingKeys, NSError * _Nullable error)
    {
        completion([thingKeys firstKey], error);
    }];
}

- (void)createNewThings:(MHVThingCollection *)things
               recordId:(NSUUID *)recordId
             completion:(void(^_Nullable)(MHVThingKeyCollection *_Nullable thingKeys, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion(nil, [NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    for (MHVThing *thing in things)
    {
        [thing prepareForNew];

        //Check if thing is valid
        if (![self isValidObject:thing])
        {
            if (completion)
            {
                completion(nil, [NSError MVHInvalidParameter:[NSString stringWithFormat:@"Thing is not valid, code %li", [thing validate].error]]);
            }
            
            return;
        }
    }
    
    MHVMethod *method = [MHVMethod putThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingCollection:things];
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
         MHVThingKeyCollection *keys = [self thingKeyResultsFromResponse:response];
         
#ifdef THING_CACHE
         
         // If the connection is offline cache the pending request.
         if ([self isOfflineError:error])
         {
             [self cachePendingMethod:method
                               things:things
                        operationType:MHVThingOpertaionTypeCreate
                         networkError:error
                          completion:^(NSError * _Nullable error)
             {
                 if (completion)
                 {
                     completion(keys, error);
                 }
             }];
            
            return;
         }
         
         if (keys.count == things.count)
         {
             // Set Key on the added things
             for (NSInteger i = 0; i < things.count; i++)
             {
                 things[i].key = keys[i];
             }
             
             if (!error && self.cache)
             {
                 [self.cache addThings:things
                              recordId:recordId
                            completion:^(NSError * _Nullable error)
                  {
                      if (completion)
                      {
                          completion(keys, error);
                      }
                  }];
                 return;
             }
         }
         else
         {
             MHVASSERT_MESSAGE(@"Mismatch between added Thing count and Thing Keys");
         }
#endif
         if (completion)
         {
             completion(keys, error);
         }
     }];
}

#pragma mark - Update Things

- (void)updateThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    [self updateThings:[[MHVThingCollection alloc] initWithThing:thing]
              recordId:recordId
            completion:completion];
}

- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    for (MHVThing *thing in things)
    {
        [thing prepareForUpdate];

        //Check if thing is valid
        if (![self isValidObject:thing])
        {
            if (completion)
            {
                completion([NSError MVHInvalidParameter:[NSString stringWithFormat:@"Thing is not valid, code %li", [thing validate].error]]);
            }
            
            return;
        }
    }
    
    MHVMethod *method = [MHVMethod putThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingCollection:things];
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
#ifdef THING_CACHE
         // If the connection is offline cache the pending request.
         if ([self isOfflineError:error])
         {
             [self cachePendingMethod:method
                               things:things
                        operationType:MHVThingOpertaionTypeUpdate
                         networkError:error
                           completion:completion];
             
             return;
         }
         
         if (!error && self.cache)
         {
             [self.cache updateThings:things
                             recordId:recordId
                           completion:^(NSError * _Nullable error)
              {
                  if (completion)
                  {
                      completion(error);
                  }
              }];
             return;
         }
#endif
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Remove Things

- (void)removeThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    [self removeThings:[[MHVThingCollection alloc] initWithThing:thing]
              recordId:recordId
            completion:completion];
}

- (void)removeThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    MHVMethod *method = [MHVMethod removeThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingIdsFromThingCollection:things];
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
#ifdef THING_CACHE
         // If the connection is offline cache the pending request.
         if ([self isOfflineError:error])
         {
             [self cachePendingMethod:method
                               things:things
                        operationType:MHVThingOpertaionTypeDelete
                         networkError:error
                           completion:completion];
             
             return;
         }
         
         if (!error && self.cache)
         {
             [self.cache deleteThings:things
                             recordId:recordId
                           completion:^(NSError * _Nullable error)
              {
                  if (completion)
                  {
                      completion(error);
                  }
              }];
             return;
         }
#endif
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Cache Pending Thing Operations

- (void)cachePendingMethod:(MHVMethod *)method
                    things:(MHVThingCollection *)things
             operationType:(MHVThingOperationType)operationType
              networkError:(NSError *)networkError
                completion:(void (^)(NSError *_Nullable error))completion
{
    if (!self.cache)
    {
        if (completion)
        {
            completion(networkError);
        }
        
        return;
    }
    
    // Add the method call to the cache...
    MHVAsyncTask<id, NSError *> *cacheMethodTask = [self taskForCacheMethod:method];
    
    MHVAsyncTask<id, NSError *> *addUpdateOrDeleteTask;

    if (operationType == MHVThingOpertaionTypeCreate)
    {
        // Add things to the cache (with no keys - They will be purged the next sync)
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskForAddPendingThings:things method:method]];
        
    }
    else if (operationType == MHVThingOpertaionTypeUpdate)
    {
        // Update things in the cache
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskForUpdatePendingThings:things method:method]];
    }
    else if (operationType == MHVThingOpertaionTypeDelete)
    {
        // Delete things from the cache
        addUpdateOrDeleteTask = [cacheMethodTask continueWithOptions:MHVTaskContinueIfPreviousTaskWasNotCanceled
                                                                task:[self taskForDeletePendingThings:things method:method]];
    }
    
    // If an error occurs during the caching process we need to cleanup the cache by removing the cached method.
    MHVAsyncTask<NSError *, NSArray<NSError *> *> *failureTask = [addUpdateOrDeleteTask continueWithTask:[self taskForFailureToCacheMethod:method]];
    
    [failureTask continueWithBlock:^id(NSArray<NSError *> *errors)
    {
        if (errors)
        {
            for (NSError *error in errors)
            {
                // Print any errors that occur during the process of caching a method or things
                MHVASSERT_MESSAGE(error.localizedDescription);
            }
            
            // Complete with the original network error, so caching does not interfere with the normal app behavior for no network.
            completion(networkError);
        }
        else
        {
            completion(nil)
        }
    }];
    
}

// Adds a method to the cache to be re-issued next sync
- (MHVAsyncTask<id, NSError *> *)taskForCacheMethod:(MHVMethod *)method
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(NSError *), void (^cancel)(NSError *))
            {
                [self.cache cacheMethod:method
                             completion:^(NSError * _Nullable error)
                 {
                     if (error)
                     {
                         cancel(error);
                     }
                     else
                     {
                         finish(nil);
                     }
                 }];
            }];
}

// Adds new things to the cache. *Note - These new things will have no keys and will be purged during the next sync.
- (MHVAsyncTask<id, NSError *> *)taskForAddPendingThings:(MHVThingCollection *)things
                                                  method:(MHVMethod *)method
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(NSError *), void (^cancel)(NSError *))
    {
        [self.cache addThings:things
                     recordId:method.recordId
                   completion:^(NSError * _Nullable error)
         {
             if (error)
             {
                 cancel(error);
             }
             else
             {
                 finish(nil);
             }
         }];
    }];
}

// Updates existing things in the cache.
- (MHVAsyncTask<id, NSError *> *)taskForUpdatePendingThings:(MHVThingCollection *)things
                                                     method:(MHVMethod *)method
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(NSError *), void (^cancel)(NSError *))
    {
        [self.cache updateThings:things
                        recordId:method.recordId
                      completion:^(NSError * _Nullable error)
         {
             if (error)
             {
                 cancel(error);
             }
             else
             {
                 finish(nil);
             }
         }];
    }];
}

// Deletes things from the cache.
- (MHVAsyncTask<id, NSError *> *)taskForDeletePendingThings:(MHVThingCollection *)things
                                                     method:(MHVMethod *)method
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(id input, void (^finish)(NSError *), void (^cancel)(NSError *))
    {
        [self.cache deleteThings:things
                        recordId:method.recordId
                      completion:^(NSError * _Nullable error)
         {
             if (error)
             {
                 cancel(error);
             }
             else
             {
                 finish(nil);
             }
         }];
    }];
}

// If an error occurs during a previous step, the method that was added is deleted 
- (MHVAsyncTask<NSError *, NSArray<NSError *> *> *)taskForFailureToCacheMethod:(MHVMethod *)method
{
    return [[MHVAsyncTask alloc] initWithIndeterminateBlock:^(NSError *inputError, void (^finish)(NSArray<NSError *> *>), void (^cancel)(NSArray<NSError *> *>))
    {
        NSMutableArray *errors = [NSMutableArray new];
        
        if (inputError)
        {
            [errors addObject:inputError];
            
            [self.cache deleteMethod:method
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
            finish(nil);
        }
    }];
}

#pragma mark - Blobs: URL Refresh

- (void)refreshBlobUrlsForThing:(MHVThing *)thing
                       recordId:(NSUUID *)recordId
                     completion:(void (^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion(nil, [NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    [self refreshBlobUrlsForThings:[[MHVThingCollection alloc] initWithThing:thing]
                          recordId:recordId
                        completion:^(MHVThingCollection *_Nullable resultThings, NSError *_Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             // Update the blobs on original thing & return that to the completion
             thing.blobs = resultThings.firstObject.blobs;
             
             completion(thing, nil);
         }
     }];
}

- (void)refreshBlobUrlsForThings:(MHVThingCollection *)things
                        recordId:(NSUUID *)recordId
                      completion:(void (^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion(nil, [NSError MVHRequiredParameterIsNil]);
        }
        
        return;
    }
    
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithThingIDs:[things thingIDs]];
    query.view.sections = MHVThingSection_Standard | MHVThingSection_Blobs;
    
    [self getThingsWithQuery:query
                    recordId:recordId
                  completion:^(MHVThingCollection *_Nullable resultThings, NSError *_Nullable error)
     {
         // Update the blobs on original thing collection & return that to the completion
         for (MHVThing *thing in resultThings)
         {
             NSUInteger index = [things indexOfThingID:thing.thingID];
             if (index != NSNotFound)
             {
                 things[index].blobs = thing.blobs;
             }
         }
         
         if (completion)
         {
             completion(things, error);
         }
     }];
}

#pragma mark - Blobs: Download

- (void)downloadBlobData:(MHVBlobPayloadThing *)blobPayloadThing
              completion:(void (^)(NSData *_Nullable data, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(blobPayloadThing);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!blobPayloadThing)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    // If blob has inline base64 encoded data, can return it immediately
    if (blobPayloadThing.inlineData)
    {
        completion(blobPayloadThing.inlineData, nil);
        return;
    }
    
    MHVBlobDownloadRequest *request = [[MHVBlobDownloadRequest alloc] initWithURL:[NSURL URLWithString:blobPayloadThing.blobUrl]
                                                                       toFilePath:nil];
    
    // Download from the URL
    [self.connection executeHttpServiceOperation:request
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             completion(response.responseData, nil);
         }
     }];
}

- (void)downloadBlob:(MHVBlobPayloadThing *)blobPayloadThing
          toFilePath:(NSString *)filePath
          completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(blobPayloadThing);
    MHVASSERT_PARAMETER(filePath);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!blobPayloadThing || !filePath)
    {
        completion([NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    // If blob has inline base64 encoded data, can write to the desired file and return immediately
    if (blobPayloadThing.inlineData)
    {
        if ([blobPayloadThing.inlineData writeToFile:filePath atomically:YES])
        {
            completion(nil);
        }
        else
        {
            completion([NSError error:[NSError MHVIOError]
                      withDescription:@"Blob data could not be written to the file path"]);
        }
        return;
    }
    
    MHVBlobDownloadRequest *request = [[MHVBlobDownloadRequest alloc] initWithURL:[NSURL URLWithString:blobPayloadThing.blobUrl]
                                                                       toFilePath:filePath];
    
    // Download from the URL
    [self.connection executeHttpServiceOperation:request
                                      completion:^(MHVServiceResponse *_Nullable response, NSError *_Nullable error)
     {
         completion(error);
     }];
}

- (void)getPersonalImageWithRecordId:(NSUUID *)recordId
                          completion:(void (^)(UIImage *_Nullable image, NSError *_Nullable error))completion
{
    if (!completion)
    {
        return;
    }
    
    // Get the personalImage thing, including the blob section
    MHVThingFilter *filter = [[MHVThingFilter alloc] initWithTypeID:MHVPersonalImage.typeID];
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithFilter:filter];
    query.view.sections = MHVThingSection_Blobs;
    
    [self getThingsWithQuery:query
                    recordId:recordId
                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
     {
         // Get the defaultBlob from the first thing in the result collection; can be nil if no image has been set
         MHVThing *thing = [things firstObject];
         if (!thing)
         {
             completion(nil, nil);
             return;
         }
         
         MHVBlobPayloadThing *blob = [thing.blobs getDefaultBlob];
         if (!blob)
         {
             completion(nil, nil);
             return;
         }
         
         [self downloadBlobData:blob
                     completion:^(NSData *_Nullable data, NSError *_Nullable error)
          {
              if (error || !data)
              {
                  completion(nil, error);
              }
              else
              {
                  UIImage *personImage = [UIImage imageWithData:data];
                  if (personImage)
                  {
                      completion(personImage, nil);
                  }
                  else
                  {
                      completion(nil, [NSError error:[NSError MHVUnknownError]
                                     withDescription:@"Blob data could not be converted to UIImage"]);
                  }
              }
          }];
     }];
}

- (void)setPersonalImage:(NSData *)imageData
             contentType:(NSString *)contentType
                recordId:(NSUUID *)recordId
              completion:(void (^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(imageData);
    MHVASSERT_PARAMETER(contentType);
    MHVASSERT_PARAMETER(recordId);
    
    if (!imageData || !contentType || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    if (![contentType isEqualToString:@"image/jpg"] &&
        ![contentType isEqualToString:@"image/jpeg"] &&
        ![contentType isEqualToString:@"image/png"] &&
        ![contentType isEqualToString:@"image/gif"])
    {
        if (completion)
        {
            completion([NSError error:[NSError MVHInvalidParameter]
                      withDescription:@"Personal image must be a standard image content-type"]);
        }
        return;
    }

    // Get the personalImage thing, including the blob section
    MHVThingFilter *filter = [[MHVThingFilter alloc] initWithTypeID:MHVPersonalImage.typeID];
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithFilter:filter];
    query.view.sections = MHVThingSection_Blobs;
    
    [self getThingsWithQuery:query
                    recordId:recordId
                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
     {
         // Get the first thing in the result collection; can be nil if no personal image has been set
         MHVThing *thing = [things firstObject];
         if (!thing)
         {
             MHVLOG(@"No current personal image");
             thing = [MHVPersonalImage newThing];
         }
         
         MHVBlobMemorySource *memorySource = [[MHVBlobMemorySource alloc] initWithData:imageData];
         
         [self addBlobSource:memorySource
                     toThing:thing
                        name:@""
                 contentType:contentType
                    recordId:recordId
                  completion:^(MHVThing * _Nullable thing, NSError * _Nullable error)
         {
             if (completion)
             {
                 completion(error);
             }
         }];
     }];
}

- (void)addBlobSource:(id<MHVBlobSourceProtocol>)blobSource
              toThing:(MHVThing *)toThing
                 name:(NSString *_Nullable)name
          contentType:(NSString *)contentType
             recordId:(NSUUID *)recordId
           completion:(void(^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion
{
    // Use empty string for name if not specified
    if (!name)
    {
        name = @"";
    }
    
    MHVASSERT_PARAMETER(blobSource);
    MHVASSERT_PARAMETER(toThing);
    MHVASSERT_PARAMETER(contentType);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!blobSource || !toThing || !contentType || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }

    // 1. Get the location where to upload a new blob
    MHVMethod *putMethod = [MHVMethod beginPutBlob];
    putMethod.recordId = recordId;
    
    [self.connection executeHttpServiceOperation:putMethod
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            return;
        }
        
        MHVBlobPutParameters *putParams = [self blobPutParametersResultsFromResponse:response];

        if (!putParams.url)
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"Blob upload parameters did not have a URL"]);
            return;
        }
        
        if (blobSource.length > putParams.maxSize)
        {
            completion(nil, [NSError error:[NSError MHVIOError] withDescription:@"Blob size is to large to save to HealthVault"]);
            return;
        }

        // 2. Upload the blob to the URL retrieved
        MHVBlobUploadRequest *uploadRequest = [[MHVBlobUploadRequest alloc] initWithBlobSource:blobSource
                                                                                destinationURL:[NSURL URLWithString:putParams.url]
                                                                                     chunkSize:putParams.chunkSize];
        
        [self.connection executeHttpServiceOperation:uploadRequest
                                          completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error)
             {
                 completion(nil, error);
                 return;
             }
             
             // 3. Commit and save the blob by attaching it to the Thing
             MHVBlobPayloadThing *blob = [[MHVBlobPayloadThing alloc] initWithBlobName:name
                                                                           contentType:contentType
                                                                                length:blobSource.length
                                                                                andUrl:putParams.url];
             [toThing.blobs addOrUpdateBlob:blob];
             
             [self updateThing:toThing
                      recordId:recordId
                    completion:^(NSError * _Nullable error)
             {
                 completion(error == nil ? toThing : nil, error);
             }];
         }];
    }];
}

- (void)getRecordOperations:(NSUInteger)sequenceNumber
                   recordId:(NSUUID *)recordId
                 completion:(void (^)(MHVGetRecordOperationsResult *_Nullable result, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion || !recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }

    MHVMethod *method = [MHVMethod getRecordOperations];
    method.recordId = recordId;
    method.parameters = [NSString stringWithFormat:@"<info><record-operation-sequence-number>%li</record-operation-sequence-number></info>", sequenceNumber];
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
             return;
         }
         
         XReader *reader = [[XReader alloc] initFromString:response.infoXml];
         
         MHVGetRecordOperationsResult *result = (MHVGetRecordOperationsResult *)[NSObject newFromReader:reader
                                                                                               withRoot:@"info"
                                                                                                asClass:[MHVGetRecordOperationsResult class]];
         completion(result, nil);
     }];
}

#pragma mark - Internal methods

- (MHVThingQueryResults *)thingQueryResultsFromResponse:(MHVServiceResponse *)response
{
    XReader *reader = [[XReader alloc] initFromString:response.infoXml];
    
    return (MHVThingQueryResults *)[NSObject newFromReader:reader
                                                  withRoot:@"info"
                                                   asClass:[MHVThingQueryResults class]];
}

- (MHVThingKeyCollection *)thingKeyResultsFromResponse:(MHVServiceResponse *)response
{
    XReader *reader = [[XReader alloc] initFromString:response.infoXml];
    return (MHVThingKeyCollection *)[NSObject newFromReader:reader
                                                   withRoot:@"info"
                                                    asClass:[MHVThingKeyCollection class]];
}

- (MHVBlobPutParameters *)blobPutParametersResultsFromResponse:(MHVServiceResponse *)response
{
    XReader *reader = [[XReader alloc] initFromString:response.infoXml];
    return (MHVBlobPutParameters *)[NSObject newFromReader:reader
                                                  withRoot:@"info"
                                                   asClass:[MHVBlobPutParameters class]];
}

- (NSString *)bodyForQueryCollection:(MHVThingQueryCollection *)queries
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    
    for (MHVThingQuery *query in queries)
    {
        if ([self isValidObject:query])
        {
            [XSerializer serialize:query withRoot:@"group" toWriter:writer];
        }
    }
    
    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (NSString *)bodyForThingCollection:(MHVThingCollection *)things
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

- (NSString *)bodyForThingIdsFromThingCollection:(MHVThingCollection *)things
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

- (BOOL)isOfflineError:(NSError *)error
{    
    return [error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet;
}

@end
