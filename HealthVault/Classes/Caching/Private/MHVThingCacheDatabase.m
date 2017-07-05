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
#import "MHVCommon.h"
#import "MHVThingCacheDatabase+CoreDataModel.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVLogger.h"
#import "EncryptedStore.h"
#import "MHVThingTypes.h"
#import "MHVThingCacheDatabase+CoreDataModel.h"
#import "NSError+MHVError.h"
#import "MHVCachedThing+Cache.h"
#import "MHVCachedRecord+Cache.h"
#import "MHVCacheQuery.h"

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
    NSError *error = nil;
    
    @synchronized (self.lockObject)
    {
        [self.fileManager removeItemAtURL:self.databaseUrl
                                    error:&error];
        
        [self.keychainService removeObjectForKey:kMHVCachePasswordKey];
        
        _persistentStoreCoordinator = nil;
        _managedObjectContext = nil;
        _databaseUrl = nil;
        
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

- (void)setupRecordIds:(NSArray<NSString *> *)recordIds
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
                 record.lastOperationSequenceNumber = 0;
                 record.lastSyncDate = nil;
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

#pragma mark - Delete

- (void)deleteRecord:(NSString *)recordId
          completion:(void (^)(NSError *_Nullable error))completion;
{
    MHVASSERT_PARAMETER(recordId);
    
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    if ([NSString isNilOrEmpty:recordId])
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    __block NSError *error;
    
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

- (void)deleteThingIds:(NSArray<NSString *> *)thingIds
              recordId:(NSString *)recordId
            completion:(void (^)(NSError *_Nullable error))completion;
{
    MHVASSERT_PARAMETER(thingIds);
    MHVASSERT_PARAMETER(recordId);
    
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    if ([NSArray isNilOrEmpty:thingIds])
    {
        //Nothing to delete
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    
    if ([NSString isNilOrEmpty:recordId])
    {
        if (completion)
        {
            completion([NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
         
         NSMutableArray<NSString *> *where = [NSMutableArray new];
         for (NSString *thingId in thingIds)
         {
             [where addObject:thingId];
         }
         
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"thingId IN %@ AND record.recordId == %@", where, [recordId lowercaseString]];
         [fetchRequest setPredicate:predicate];
         
         NSError *error = nil;
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

- (void)cachedResultsForQuery:(MHVThingQuery *)query
                     recordId:(NSString *)recordId
                   completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion
{
    NSDate *startDate = [NSDate date];
    
    //If no completion, don't need to do the query
    if (!completion)
    {
        return;
    }
    
    if (!self.isDatabaseReady)
    {
        completion(nil, nil);
        return;
    }
    
    if (!recordId)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
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
         fetchRequest.fetchLimit = cacheQuery.fetchLimit;
         
         NSError *error;
         NSArray<MHVCachedThing *> *fetchedThings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
         if (error)
         {
             completion(nil, [NSError MHVCacheError:@"Could not fetch things from cache database"]);
             return;
         }
         
         MHVThingCollection *thingCollection = [[MHVThingCollection alloc] init];
         thingCollection.isCachedResult = YES;
         
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
         
         MHVThingQueryResult *queryResult = [MHVThingQueryResult new];
         queryResult.things = thingCollection;
         queryResult.name = query.name;
         queryResult.isCachedResult = YES;
         
         NSDate *endDate = [NSDate date];
         
         MHVLOG(@"ThingCacheDatabase: Returning %li cached things in %0.4f seconds", queryResult.things.count, [endDate timeIntervalSinceDate:startDate]);
         
         completion(queryResult, nil);
     }];
}

- (void)addOrUpdateThings:(MHVThingCollection *)things
                 recordId:(NSString *)recordId
       lastSequenceNumber:(NSInteger)lastSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion
{
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion(0, [NSError MHVCacheDeleted]);
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
    
    if ([MHVCollection isNilOrEmpty:things])
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
             MHVCachedThing *cachedThing = [record findThingWithThingId:thing.thingID];
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
         if (lastSequenceNumber >= 0)
         {
             record.lastOperationSequenceNumber = lastSequenceNumber;
             record.lastSyncDate = [NSDate date];
             record.isValid = YES;
         }
         
         NSError *error = [self saveContext];
         
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

- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable records, NSError *_Nullable error))completion
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
                    completion:(void (^)(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error))completion
{
    if (!completion)
    {
        return;
    }
    
    if (!self.isDatabaseReady)
    {
        completion(nil, 0, NO, [NSError MHVCacheDeleted]);
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         MHVCachedRecord *record = [self fetchCachedRecord:recordId];
         
         if (record)
         {
             completion(record.lastSyncDate, record.lastOperationSequenceNumber, record.isValid, nil);
         }
         else
         {
             completion(nil, 0, NO, [NSError MHVCacheError:@"Record does not exist"]);
         }
     }];
}

- (void)setCacheInvalidForRecordId:(NSString *)recordId completion:(void (^_Nullable)(NSError *_Nullable error))completion;
{
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    __block NSError *error;
    
    MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
    if (record)
    {
        [self.managedObjectContext performBlock:^
         {
             MHVCachedRecord *cachedRecord = (MHVCachedRecord *)record;
             
             cachedRecord.isValid = NO;
             cachedRecord.lastSyncDate = nil;
             cachedRecord.lastOperationSequenceNumber = 0;
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

- (void)updateRecordId:(NSString *)recordId
          lastSyncDate:(NSDate *_Nullable)lastSyncDate
        sequenceNumber:(NSNumber *_Nullable)sequenceNumber
            completion:(void (^)(NSError *_Nullable error))completion;
{
    if (!self.isDatabaseReady)
    {
        if (completion)
        {
            completion([NSError MHVCacheDeleted]);
        }
        return;
    }
    
    // Make sure properties are updated with the correct context
    [self.managedObjectContext performBlock:^
     {
         NSError *error;
         
         MHVCachedRecord *cachedRecord = [self fetchCachedRecord:recordId];
         if (!cachedRecord)
         {
             error = [NSError MHVCacheError:@"Record could not be found"];
         }
         else
         {
             if (lastSyncDate)
             {
                 cachedRecord.lastSyncDate = lastSyncDate;
             }
             if (sequenceNumber >= 0)
             {
                 cachedRecord.lastOperationSequenceNumber = sequenceNumber.integerValue;
             }
             
             cachedRecord.isValid = YES;
             
             error = [self saveContext];
         }
         
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Core Data

- (NSError *)saveContext
{
    if (!self.isDatabaseReady)
    {
        return [NSError MHVCacheDeleted];
    }
    
    __block NSError *error = nil;
    
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
