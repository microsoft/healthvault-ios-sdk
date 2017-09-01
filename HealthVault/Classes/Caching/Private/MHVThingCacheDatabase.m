//
//  MHVThingCacheDatabase.m
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

#import "MHVThingCacheDatabase.h"
#import <Security/Security.h>
#import "MHVValidator.h"
#import "MHVStringExtensions.h"
#import "MHVThingCacheDatabase+CoreDataModel.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVLogger.h"
#import "EncryptedStore.h"
#import "MHVThingTypes.h"
#import "NSError+MHVError.h"
#import "MHVCachedThing+Cache.h"
#import "MHVCachedRecord+Cache.h"
#import "MHVCacheQuery.h"
#import "MHVCacheStatusProtocol.h"
#import "MHVCacheStatus.h"
#import "MHVPendingMethod.h"
#import "NSArray+Utils.h"
#import "NSArray+MHVThing.h"

static NSString *kMHVCachePasswordKey = @"MHVCachePassword";

@interface MHVThingCacheDatabase ()

@property (nonatomic, strong) NSPersistentStoreCoordinator      *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext            *managedObjectContext;
@property (nonatomic, strong) NSURL                             *databaseUrl;
@property (nonatomic, strong) NSObject                          *lockObject;

@property (nonatomic, strong) id<MHVKeychainServiceProtocol>    keychainService;
@property (nonatomic, strong) NSFileManager                     *fileManager;

@end

@implementation MHVThingCacheDatabase

- (instancetype)initWithKeychainService:(id<MHVKeychainServiceProtocol>)keychainService
                            fileManager:(NSFileManager *)fileManager
{
    MHVASSERT_PARAMETER(keychainService);
    MHVASSERT_PARAMETER(fileManager);
    
    self = [super init];
    if (self)
    {
        _keychainService = keychainService;
        _fileManager = fileManager;
        _lockObject = [NSObject new];
    }
    return self;
}

- (BOOL)isDatabaseReady
{
    @synchronized (self.lockObject)
    {
        return (self.persistentStoreCoordinator != nil &&
                self.managedObjectContext != nil);
    }
}

- (void)resetDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;
{
    @synchronized (self.lockObject)
    {
        [self.managedObjectContext performBlockAndWait:^
        {
            NSError *error = nil;
            
            [self.fileManager removeItemAtURL:self.databaseUrl
                                        error:&error];
            
            [self.keychainService removeObjectForKey:kMHVCachePasswordKey];
            
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            _databaseUrl = nil;
        }];
        
        [self openDatabaseWithCompletion:completion];
    }
    return;
}

#pragma mark - Create Objects

- (MHVCachedThing *)newThingForRecord:(MHVCachedRecord *)record
{
    if (!self.isDatabaseReady || !record)
    {
        return nil;
    }
    
    __block MHVCachedThing *thing;
    
    [self.managedObjectContext performBlockAndWait:^
     {
         thing = [NSEntityDescription insertNewObjectForEntityForName:@"MHVCachedThing"
                                               inManagedObjectContext:self.managedObjectContext];
         thing.record = record;
     }];
    
    return thing;
}

- (MHVPendingThingOperation *)newPendingThingOperationForRecord:(MHVCachedRecord *)record
{
    if (!self.isDatabaseReady || !record)
    {
        return nil;
    }
    
    __block MHVPendingThingOperation *operation;
    
    [self.managedObjectContext performBlockAndWait:^
     {
         operation = [NSEntityDescription insertNewObjectForEntityForName:@"MHVPendingThingOperation"
                                                   inManagedObjectContext:self.managedObjectContext];
         operation.record = record;
     }];
    
    return operation;
}

- (void)setupCacheForRecordIds:(NSArray<NSString *> *)recordIds
                    completion:(void (^)(NSError *_Nullable error))completion
{
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    if ([NSArray isNilOrEmpty:recordIds])
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         for (NSString *recordId in recordIds)
         {
             MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
             if (!record)
             {
                 // Create new record
                 record = [NSEntityDescription insertNewObjectForEntityForName:@"MHVCachedRecord"
                                                        inManagedObjectContext:self.managedObjectContext];
                 if (!record)
                 {
                     if (completion)
                     {
                         completion([NSError MHVCacheError:@"Could not create cache for record"]);
                     }
                     return;
                 }
                 record.recordId = [recordId lowercaseString];
                 record.newestHealthVaultSequenceNumber = 1;
                 record.newestCacheSequenceNumber = 0;
                 record.lastSyncDate = nil;
                 record.lastConsistencyDate = nil;
                 record.isValid = YES;
                 
                 NSError *error = [self saveContext];
                 if (error)
                 {
                     if (completion)
                     {
                         completion(error);
                     }
                     return;
                 }
             }
         }
         
         if (completion)
         {
             completion(nil);
         }
     }];
}

- (void)createCachedThings:(NSArray<MHVThing *> *)things
                  recordId:(NSString *)recordId
                completion:(void (^)(NSError *_Nullable error))completion
{
    [self synchronizeThings:things
                   recordId:recordId
        batchSequenceNumber:-1
       latestSequenceNumber:-1
                 completion:^(NSInteger synchronizedItemCount, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Delete

- (void)deleteCacheForRecordId:(NSString *)recordId
                    completion:(void (^)(NSError *_Nullable error))completion;
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        completion(error);
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
         if (record)
         {
             [self.managedObjectContext deleteObject:record];
             error = [self saveContext];
         }
         
         if (completion)
         {
             completion(error);
         }
     }];
    
}

- (void)deleteCachedThingsWithThingIds:(NSArray<NSString *> *)thingIds
                              recordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion;
{
    MHVASSERT_PARAMETER(thingIds);
    
    if ([NSArray isNilOrEmpty:thingIds])
    {
        //Nothing to delete
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
         
         NSMutableArray<NSString *> *where = [NSMutableArray new];
         for (NSString *thingId in thingIds)
         {
             [where addObject:[thingId lowercaseString]];
         }
         
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"thingId IN %@ AND record.recordId == %@", where, [recordId lowercaseString]];
         [fetchRequest setPredicate:predicate];
         
         NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
         for (MHVCachedRecord *record in fetchedObjects)
         {
             [self.managedObjectContext deleteObject:record];
         }
         
         error = [self saveContext];
         
         if (error)
         {
             MHVLOG(@"ThingCacheDatabase: Setting record as invalid, error deleting things %@", error);
             [self setCacheInvalidForRecordId:recordId
                                   completion:nil];
         }
         
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Read

- (void)cachedResultForQuery:(MHVThingQuery *)query
                    recordId:(NSString *)recordId
                  completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion
{
    NSDate *startDate = [NSDate date];
    
    //If no completion, don't need to do the query
    if (!completion)
    {
        return;
    }
    
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        completion(nil, error);
        return;
    }
    
    MHVCacheQuery *cacheQuery = [[MHVCacheQuery alloc] initWithQuery:query];
    
    if (!cacheQuery.canQueryCache)
    {
        completion(nil, cacheQuery.error);
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         //Create query to filter & order Things
         NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"record.recordId == %@", [recordId lowercaseString]],
                                                                                               cacheQuery.predicate]];
         
         NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
         fetchRequest.predicate = predicate;
         fetchRequest.propertiesToFetch = @[@"xmlString"];
         fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"effectiveDate" ascending:NO]];
         
         NSUInteger fetchCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
         if (error)
         {
             completion(nil, [NSError MHVCacheError:@"Could not calculate thing count for fetch."]);
             return;
         }
         
         NSMutableArray<MHVThing *> *thingCollection = [NSMutableArray new];
         
         if (cacheQuery.fetchLimit > 0 &&
             fetchCount != NSNotFound &&
             fetchCount > cacheQuery.fetchOffset)
         {
             fetchRequest.fetchLimit = cacheQuery.fetchLimit;
             fetchRequest.fetchOffset = cacheQuery.fetchOffset;
             
             NSArray<MHVCachedThing *> *fetchedThings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
             if (error)
             {
                 completion(nil, [NSError MHVCacheError:@"Could not fetch things from cache database"]);
                 return;
             }
             
             //Convert cached things back into MHVThings
             for (MHVCachedThing *cachedThing in fetchedThings)
             {
                 MHVThing *thing = [cachedThing toThing];
                 if (thing)
                 {
                     [thingCollection addObject:thing];
                 }
                 else
                 {
                     completion(nil, [NSError MHVCacheError:@"Could not convert database object back to a Thing"]);
                     return;
                 }
             }
         }
         
         MHVThingQueryResult *queryResult = [[MHVThingQueryResult alloc] initWithName:query.name
                                                                               things:thingCollection
                                                                                count:fetchCount
                                                                       isCachedResult:YES];
         NSDate *endDate = [NSDate date];
         
         MHVLOG(@"ThingCacheDatabase: Returning %li cached things in %0.4f seconds", queryResult.things.count, [endDate timeIntervalSinceDate:startDate]);
         
         completion(queryResult, nil);
     }];
}

#pragma mark - Update

- (void)updateCachedThings:(NSArray<MHVThing *> *)things
                  recordId:(NSString *)recordId
                completion:(void (^)(NSError *_Nullable error))completion
{
    [self synchronizeThings:things
                   recordId:recordId
        batchSequenceNumber:-1
       latestSequenceNumber:-1
                 completion:^(NSInteger synchronizedItemCount, NSError * _Nullable error)
    {
        if (completion)
        {
            completion(error);
        }
    }];
}

#pragma mark - Synchronize

- (void)synchronizeThings:(NSArray<MHVThing *> *)things
                 recordId:(NSString *)recordId
      batchSequenceNumber:(NSInteger)batchSequenceNumber
     latestSequenceNumber:(NSInteger)latestSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(0, error);
        }
        return;
    }
    
    if ([NSArray isNilOrEmpty:things])
    {
        //No things to add or update
        if (completion)
        {
            completion(0, nil);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
         if (!record)
         {
             if (completion)
             {
                 completion(0, [NSError MHVCacheError:@"Record could not be found"]);
             }
             return;
         }
         
         for (MHVThing *thing in things)
         {
             MHVCachedThing *cachedThing = [record thingWithThingId:thing.thingID];
             if (!cachedThing)
             {
                 //Not found, need to create...
                 cachedThing = [self newThingForRecord:record];
                 if (!cachedThing)
                 {
                     MHVLOG(@"ThingCacheDatabase: Setting record as invalid, error creating thing");
                     [self setCacheInvalidForRecordId:recordId
                                           completion:nil];
                     if (completion)
                     {
                         completion(0, [NSError MHVCacheError:@"New cache thing could not be created"]);
                     }
                     return;
                 }
             }
             
             [cachedThing populateWithThing:thing];
         }
         
         // Sync complete, update record with date and sequence number
         // Will be < 0 for PutThing that shouldn't update the sync info
         if (batchSequenceNumber >= 0 && latestSequenceNumber >= 0)
         {
             NSDate *now = [NSDate date];
             
             record.newestHealthVaultSequenceNumber = latestSequenceNumber;
             record.newestCacheSequenceNumber = batchSequenceNumber;
             record.lastSyncDate = now;
             record.isValid = YES;
             
             // Consistency has been achieved when the latest sequence is equal to the batch sequence
             if (latestSequenceNumber == batchSequenceNumber)
             {
                 record.lastConsistencyDate = now;
             }
         }
         
         error = [self saveContext];
         
         if (error)
         {
             MHVLOG(@"ThingCacheDatabase: Setting record as invalid, error updating %@", error);
             [self setCacheInvalidForRecordId:recordId
                                   completion:nil];
             
             if (completion)
             {
                 completion(0, error);
             }
         }
         else
         {
             MHVLOG(@"ThingCacheDatabase: Cache record updated %li things", things.count);
             if (completion)
             {
                 completion(things.count, nil);
             }
         }
     }];
}

- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable recordIds, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion(nil, [NSError MHVCacheDeleted]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedRecord"];
         
         NSError *error = nil;
         NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
         if (error)
         {
             MHVLOG(@"ThingCacheDatabase: Error fetching objects: %@", error);
             
             if (completion)
             {
                 completion(nil, error);
             }
             return;
         }
         
         NSMutableArray<NSString *> *recordIds = [NSMutableArray new];
         
         for (MHVCachedRecord *record in results)
         {
             if (record.recordId)
             {
                 [recordIds addObject:record.recordId];
             }
         }
         
         if (recordIds.count == 0)
         {
             error = [NSError MHVCacheError:@"No records could be found"];
         }
         
         if (completion)
         {
             completion(recordIds, error);
         }
     }];
    
}

- (MHVCachedRecord *)fetchCachedRecord:(NSString *)recordId
{
    if (!self.isDatabaseReady)
    {
        return nil;
    }
    
    __block MHVCachedRecord *record;
    
    [self.managedObjectContext performBlockAndWait:^
     {
         NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedRecord"];
         request.predicate = [NSPredicate predicateWithFormat:@"recordId == %@", [recordId lowercaseString]];
         
         NSError *error = nil;
         NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
         if (error)
         {
             MHVLOG(@"ThingCacheDatabase: Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
         }
         record = results.firstObject;
         [record awakeFromFetch];
     }];
    
    return record;
}

#pragma mark - Properties

- (void)cacheStatusForRecordId:(NSString *)recordId
                    completion:(void (^)(id<MHVCacheStatusProtocol> _Nullable status, NSError *_Nullable error))completion
{
    if (!completion)
    {
        return;
    }
    
    NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(nil, error);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         MHVCachedRecord *record = [self fetchCachedRecord:recordId];
         
         if (record)
         {
             completion([[MHVCacheStatus alloc] initWithCachedRecord:record], nil);
         }
         else
         {
             completion(nil, [NSError MHVCacheError:@"Record does not exist"]);
         }
     }];
}

- (void)setCacheInvalidForRecordId:(NSString *)recordId completion:(void (^_Nullable)(NSError *_Nullable error))completion;
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
    if (record)
    {
        [self.managedObjectContext performBlock:^
         {
             MHVCachedRecord *cachedRecord = (MHVCachedRecord *)record;
             
             cachedRecord.isValid = NO;
             cachedRecord.lastSyncDate = nil;
             cachedRecord.lastConsistencyDate = nil;
             cachedRecord.newestCacheSequenceNumber = 0;
             cachedRecord.newestHealthVaultSequenceNumber = 1;
             cachedRecord.things = [NSSet new];
             
             error = [self saveContext];
             
             if (error)
             {
                 MHVLOG(@"ThingCacheDatabase: Error setting record as invalid %@", error);
                 
                 // If can't set record as invalid, something is wrong
                 // Delete database and reset so will not be returning invalid data
                 [self resetDatabaseWithCompletion:^(NSError * _Nullable deleteError)
                  {
                      if (deleteError)
                      {
                          MHVLOG(@"ThingCacheDatabase: Error deleting database %@", deleteError);
                      }
                      
                      if (completion)
                      {
                          completion(error ? error : deleteError);
                      }
                  }];
             }
             else
             {
                 if (completion)
                 {
                     completion(nil);
                 }
             }
         }];
    }
}

- (void)updateLastCompletedSyncDate:(NSDate *_Nullable)lastCompletedSyncDate
           lastCacheConsistencyDate:(NSDate *_Nullable)lastCacheConsistencyDate
                     sequenceNumber:(NSInteger)sequenceNumber
                           recordId:(NSString *)recordId
                         completion:(void (^)(NSError *_Nullable error))completion
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    // Make sure properties are updated with the correct context
    [self.managedObjectContext performBlock:^
     {
         MHVCachedRecord *cachedRecord = [self fetchCachedRecord:recordId];
         if (!cachedRecord)
         {
             error = [NSError MHVCacheError:@"Record could not be found"];
         }
         else
         {
             if (lastCompletedSyncDate)
             {
                 cachedRecord.lastSyncDate = lastCompletedSyncDate;
             }
             if (lastCacheConsistencyDate)
             {
                 cachedRecord.lastConsistencyDate = lastCacheConsistencyDate;
             }
             
             cachedRecord.newestCacheSequenceNumber = sequenceNumber;
             cachedRecord.newestHealthVaultSequenceNumber = sequenceNumber;
             cachedRecord.isValid = YES;
             
             error = [self saveContext];
         }
         
         if (completion)
         {
             completion(error);
         }
     }];
}

- (void)cachePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                 completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(pendingMethods);
    MHVASSERT_TRUE(pendingMethods.count > 0);
    
    if ([NSArray isNilOrEmpty:pendingMethods])
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter:@"The 'pendingMethods' array is nil or empty."]);
        }
        
        return;
    }
    
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
    {
        MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:pendingMethods[0].recordId.UUIDString];
        
        if (!record)
        {
            if (completion)
            {
                completion([NSError MHVCacheError:@"Record could not be found"]);
            }
            
            return;
        }
        
        for (MHVPendingMethod *pendingMethod in pendingMethods)
        {
            // Support for updating a pending method request - If a pending method with the same identifier exists update rather
            // than creating a new one.
            MHVPendingThingOperation *operation = [record pendingThingOperationWithIdentifier:pendingMethod.identifier];
            
            if (!operation)
            {
                operation = [self newPendingThingOperationForRecord:record];
                
                if (!operation)
                {
                    if (completion)
                    {
                        completion([NSError MHVCacheError:@"Could not create a new MHVPendingThingOperation."]);
                    }
                    return;
                }
                
            }
            
            operation.name = pendingMethod.name;
            operation.version = pendingMethod.version;
            operation.originalRequestDate = pendingMethod.originalRequestDate;
            operation.parameters = pendingMethod.parameters;
            operation.identifier = pendingMethod.identifier;
            operation.correlationId = pendingMethod.correlationId.UUIDString;
        }
        
        NSError *error = [self saveContext];
        
        if (completion)
        {
            completion(error);
        }

    }];
}

- (void)fetchPendingMethodsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSArray<MHVPendingMethod *> *_Nullable methods, NSError *_Nullable error))completion
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(nil, error);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
    {
        //Create query to filter & order Things
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"record.recordId == %@", [recordId lowercaseString]];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVPendingThingOperation"];
        fetchRequest.predicate = predicate;
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"originalRequestDate" ascending:NO]];
        
        NSUInteger fetchCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (error)
        {
            completion(nil, [NSError MHVCacheError:@"Could not calculate the number of pending thing operations."]);
            return;
        }
        
        NSMutableArray<MHVPendingMethod *> *pendingMethods = [NSMutableArray new];
        
        if (fetchCount != NSNotFound && fetchCount > 0)
        {
            NSArray<MHVPendingThingOperation *> *operations = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error)
            {
                completion(nil, [NSError MHVCacheError:@"Could not fetch pending methods from cache database"]);
                return;
            }
            
            for (int i = 0; i < operations.count; i ++)
            {
                MHVPendingThingOperation *operation = operations[i];
                
                MHVPendingMethod *pendingMethod = [[MHVPendingMethod alloc] initWithOriginalRequestDate:operation.originalRequestDate
                                                                                             identifier:operation.identifier
                                                                                             methodName:operation.name];
                pendingMethod.version = (NSInteger)operation.version;
                pendingMethod.correlationId =  [[NSUUID alloc] initWithUUIDString:operation.correlationId];
                pendingMethod.parameters = operation.parameters;
                pendingMethod.recordId = [[NSUUID alloc] initWithUUIDString:recordId];
                
                [pendingMethods addObject:pendingMethod];
            }
        }
        
        completion(pendingMethods, nil);
    }];
}

- (void)deletePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                  completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(pendingMethods);
    MHVASSERT_TRUE(pendingMethods.count > 0);
    
    if ([NSArray isNilOrEmpty:pendingMethods])
    {
        if (completion)
        {
            completion([NSError error:[NSError MVHInvalidParameter] withDescription:@"The 'pendingsMethods' array must not be nil and must contain at least 1 MHVPendingMethod."]);
        }
        
        return;
    }
    
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
    {
        NSString *recordId = nil;
        NSMutableArray<NSString *> *methodIds = [NSMutableArray new];
    
        for (MHVPendingMethod *pendingMethod in pendingMethods)
        {
            if (recordId != nil && ![recordId isEqualToString:pendingMethod.recordId.UUIDString])
            {
                completion([NSError MHVCacheError:@"There is a recordId mismatch in the array of pending methods. All pending methods within this array must have the same recordId."]);
                return;
            }
            
            recordId = pendingMethod.recordId.UUIDString;
            
            [methodIds addObject:pendingMethod.identifier];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier IN %@ AND record.recordId == %@", methodIds, [recordId lowercaseString]];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVPendingThingOperation"];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error)
        {
            MHVLOG(@"ThingCacheDatabase: Setting record as invalid, error fetching objects when deleting pending thing operation %@", error);
            [self setCacheInvalidForRecordId:recordId
                                  completion:nil];
        }
        
        for (MHVCachedRecord *record in fetchedObjects)
        {
            [self.managedObjectContext deleteObject:record];
        }
        
        error = [self saveContext];
        
        if (error)
        {
            MHVLOG(@"ThingCacheDatabase: Setting record as invalid, saving context when deleting pending thing operation %@", error);
            [self setCacheInvalidForRecordId:recordId
                                  completion:nil];
        }
        
        if (completion)
        {
            completion(error);
        }
    }];
}

- (void)createPendingCachedThings:(NSArray<MHVThing *> *)things
                         recordId:(NSString *)recordId
                       completion:(void (^)(NSError *_Nullable error))completion
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    if ([NSArray isNilOrEmpty:things])
    {
        //No things to add or update
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
    {
        MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
        if (!record)
        {
            if (completion)
            {
                completion([NSError MHVCacheError:@"Record could not be found"]);
            }
            return;
        }
        
        for (MHVThing *thing in things)
        {
            MHVCachedThing *cachedThing = [self newThingForRecord:record];
            if (!cachedThing)
            {
                MHVLOG(@"ThingCacheDatabase: Setting record as invalid, error creating placeholder thing");
                [self setCacheInvalidForRecordId:recordId
                                      completion:nil];
                if (completion)
                {
                    completion([NSError MHVCacheError:@"New cache placeholder thing could not be created"]);
                }
                return;
            }
            
            [cachedThing populateWithThing:thing];
            cachedThing.isPlaceholder = YES;
        }

        error = [self saveContext];
        
        if (completion)
        {
            completion(error);
        }
    }];
}

- (void)fetchPendingThingsForRecordId:(NSString *)recordId
                           completion:(void (^)(NSArray<MHVThing *> *_Nullable things, NSError *_Nullable error))completion
{
    __block NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(nil, error);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPlaceholder == YES && record.recordId == %@", [recordId lowercaseString]];
        [fetchRequest setPredicate:predicate];

        NSArray<MHVCachedThing *> *cachedThings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSMutableArray<MHVThing *> *pendingThings = [NSMutableArray new];
        
        if (!error)
        {
            //Convert cached things back into MHVThings
            for (MHVCachedThing *cachedThing in cachedThings)
            {
                MHVThing *thing = [cachedThing toThing];
                if (thing)
                {
                    [pendingThings addObject:thing];
                }
                else
                {
                    completion(nil, [NSError MHVCacheError:@"Could not convert MHVCachedThing back to a pending Thing"]);
                    return;
                }
            }
        }
        
        if (completion)
        {
            completion(pendingThings, error);
        }
    }];
}

- (void)deletePendingThingsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion
{
    NSError *error = [self databaseErrorWithRecordId:recordId];
    
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    [self fetchPendingThingsForRecordId:recordId
                             completion:^(NSArray<MHVThing *> * _Nullable things, NSError * _Nullable error)
    {
        NSArray<NSString *> *thingIds = [things arrayOfThingIds];
        
        if (error || thingIds.count < 1)
        {
            if (completion)
            {
                completion(error);
            }
            return;
        }
        
        [self deleteCachedThingsWithThingIds:thingIds
                                    recordId:recordId
                                  completion:completion];
    }];
}

#pragma mark - Helpers

- (NSError *)databaseErrorWithRecordId:(NSString *)recordId
{
    if ([NSString isNilOrEmpty:recordId])
    {
        return [NSError MVHInvalidParameter:@"The required 'recordId' parameter is nil or empty."];
    }
    
    if (!self.isDatabaseReady)
    {
        return [NSError error:[NSError MHVCacheDeleted] withDescription:@"The cache database has been deleted or is not ready"];
    }
    
    return nil;
}

#pragma mark - Core Data

- (NSError *)saveContext
{
    if (!self.isDatabaseReady)
    {
        return [NSError MHVCacheDeleted];
    }
    
    __block NSError *error = nil;
    
    // If CoreData database gets corrupted, it can throw an exception. Catch and return as error
    @try
    {
        [self.managedObjectContext performBlockAndWait:^
         {
             if ([self.managedObjectContext hasChanges])
             {
                 if (![self.managedObjectContext save:&error])
                 {
                     MHVLOG(@"ThingCacheDatabase: Error saving to database: %@", error.localizedDescription);
                 }
             }
         }];
    }
    @catch (NSException *exception)
    {
        error = [NSError MHVCacheError:exception.description];
    }
    
    return error;
}

- (void)setupDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;
{
    // Check if database already exists
    @synchronized (self.lockObject)
    {
        if (self.persistentStoreCoordinator &&
            self.managedObjectContext)
        {
            if (completion)
            {
                completion(nil);
            }
            return;
        }
        
        [self openDatabaseWithCompletion:completion];
    }
}

- (void)openDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion
{
    NSError *error;
    
    //Setup database URL
    NSURL *applicationSupportURL = [[self.fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    
    [self.fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.databaseUrl = [applicationSupportURL URLByAppendingPathComponent:@"mhv-cache.db"];
    
    //If new database, create password
    if (![self.fileManager fileExistsAtPath:self.databaseUrl.path])
    {
        //Generate a new password and store in the keychain
        [self.keychainService setString:[self generateRandomPassword]
                                 forKey:kMHVCachePasswordKey];
    }
    
    //If no password, set one and remove database file
    if (![self.keychainService stringForKey:kMHVCachePasswordKey])
    {
        [self.fileManager removeItemAtURL:self.databaseUrl error:nil];

        //Generate a new password and store in the keychain
        [self.keychainService setString:[self generateRandomPassword]
                                 forKey:kMHVCachePasswordKey];
    }
    
    // Object Model
    NSBundle *bundle = [NSBundle bundleForClass:[MHVCachedThing class]];
    NSURL *modelURL = [bundle URLForResource:@"MHVThingCacheDatabase" withExtension:@"momd"];
    
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if (!objectModel)
    {
        objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    if (!objectModel)
    {
        if (completion)
        {
            completion([NSError MHVCacheError:@"Could not create database object model"]);
        }
        return;
    }
    
    // PersistentSoreCoordinator
    self.persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:@{
                                                                             EncryptedStorePassphraseKey : [self.keychainService stringForKey:kMHVCachePasswordKey],
                                                                             EncryptedStoreDatabaseLocation : self.databaseUrl,
                                                                             }
                                                        managedObjectModel:objectModel];
    if (!self.persistentStoreCoordinator)
    {
        if (completion)
        {
            completion([NSError MHVCacheError:@"Could not create database storage"]);
        }
        return;
    }
    
    // Mark database as protected, and that it should not be backed up
    [self.fileManager setAttributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication }
                       ofItemAtPath:self.databaseUrl.path
                              error:&error];
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    [self.databaseUrl setResourceValue:@(YES)
                                forKey:NSURLIsExcludedFromBackupKey
                                 error:&error];
    if (error)
    {
        if (completion)
        {
            completion(error);
        }
        return;
    }
    
    // NSManagedObjectContext
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    if (!self.managedObjectContext)
    {
        if (completion)
        {
            completion([NSError MHVCacheError:@"Could not create database managed object context"]);
        }
        return;
    }
    
    error = [self saveContext];
    
    if (completion)
    {
        completion(error);
    }
}

- (NSString *)generateRandomPassword
{
    NSMutableData *data = [NSMutableData dataWithLength:256];
    int result = SecRandomCopyBytes(kSecRandomDefault, data.length, data.mutableBytes);
    
    NSString *string = [data base64EncodedStringWithOptions:kNilOptions];
    if (string.length == 0 || result != errSecSuccess)
    {
        //In case random key failed, backup by returning a UUID string so there is always a key
        MHVASSERT_MESSAGE(@"Random key failed!");
        return [NSUUID new].UUIDString;
    }
    return string;
}

@end
