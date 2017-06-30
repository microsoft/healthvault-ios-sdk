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
@property (nonatomic, assign) BOOL                              deleted;

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

- (NSError *_Nullable)deleteDatabase
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
        
        _deleted = YES;
    }
    
    return error;
}

#pragma mark - Create Objects

- (MHVCachedThing *)newThingForRecord:(MHVCachedRecord *)record
{
    @synchronized (self.lockObject)
    {
        if (self.deleted || !record)
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
}

- (NSError *_Nullable)newRecordForRecordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return [NSError MHVCacheDeleted];
        }
        
        if ([NSString isNilOrEmpty:recordId])
        {
            return [NSError MVHRequiredParameterIsNil];
        }
        
        __block NSError *error;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
             if (record)
             {
                 error = [NSError MHVCacheError:@"Record already exists"];
             }
             else
             {
                 // Create new record
                 record = [NSEntityDescription insertNewObjectForEntityForName:@"MHVCachedRecord"
                                                        inManagedObjectContext:self.managedObjectContext];
                 record.recordId = recordId;
                 record.lastOperationSequenceNumber = 0;
                 record.lastSyncDate = nil;
                 record.isValid = YES;
                 
                 error = [self saveContext];
             }
         }];
        
        return error;
    }
}

#pragma mark - Delete

- (NSError *_Nullable)deleteRecord:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        MHVASSERT_PARAMETER(recordId);
        
        if (self.deleted)
        {
            return [NSError MHVCacheDeleted];
        }
        
        if ([NSString isNilOrEmpty:recordId])
        {
            return [NSError MVHRequiredParameterIsNil];
        }
        
        __block NSError *error;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
             if (record)
             {
                 [self.managedObjectContext deleteObject:record];
                 error = [self saveContext];
             }
         }];
        
        return error;
    }
}

- (NSError *_Nullable)deleteThingIds:(NSArray<NSString *> *)thingIds recordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        MHVASSERT_PARAMETER(thingIds);
        MHVASSERT_PARAMETER(recordId);
        
        if (self.deleted)
        {
            return [NSError MHVCacheDeleted];
        }
        
        if ([NSArray isNilOrEmpty:thingIds])
        {
            //Nothing to delete
            return nil;
        }
        
        if ([NSString isNilOrEmpty:recordId])
        {
            return [NSError MVHRequiredParameterIsNil];
        }
        
        __block NSError *error;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
             
             NSMutableArray<NSString *> *where = [NSMutableArray new];
             for (NSString *thingId in thingIds)
             {
                 [where addObject:thingId];
             }
             
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"thingId IN %@ AND record.recordId = %@", where, recordId];
             [fetchRequest setPredicate:predicate];
             
             NSError *error = nil;
             NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
             for (MHVCachedRecord *record in fetchedObjects)
             {
                 [self.managedObjectContext deleteObject:record];
             }
             
             error = [self saveContext];
         }];
        
        return error;
    }
}

- (void)cachedResultsForQuery:(MHVThingQuery *)query
                     recordId:(NSString *)recordId
                   completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion
{
    NSDate *startDate = [NSDate date];
    
    if (!completion)
    {
        return;
    }
    
    MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
    
    if (self.deleted)
    {
        completion(nil, nil);
        return;
    }
    
    if (!record)
    {
        completion(nil, [NSError MVHRequiredParameterIsNil]);
        return;
    }
    
    MHVCacheQuery *cacheQuery = [[MHVCacheQuery alloc] initWithQuery:query];
    
    if (cacheQuery.error)
    {
        completion(nil, cacheQuery.error);
        return;
    }
    
    if (!cacheQuery.canQueryCache)
    {
        completion(nil, nil);
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"record.recordId ==[c] %@", recordId],
                                                                                               cacheQuery.predicate]];
         
         NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedThing"];
         fetchRequest.predicate = predicate;
         
         NSError *error;
         NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

         //NSSet<MHVCachedThing *> *filteredThings = [record.things filteredSetUsingPredicate:predicate];
         
         NSArray<MHVCachedThing *> *sortedThings = [fetchedObjects sortedArrayUsingComparator:^NSComparisonResult(MHVCachedThing *_Nonnull thing1, MHVCachedThing *_Nonnull thing2)
                                                    {
                                                        return [thing1.updateDate compareDescending:thing2.updateDate];
                                                    }];
         
         if (cacheQuery.fetchLimit > 0 && sortedThings.count > cacheQuery.fetchLimit)
         {
             sortedThings = [sortedThings subarrayWithRange:NSMakeRange(0, cacheQuery.fetchLimit)];
         }
         
         MHVThingCollection *thingCollection = [[MHVThingCollection alloc] init];
         
         for (MHVCachedThing *cachedThing in sortedThings)
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
    @synchronized (self.lockObject)
    {
        if (self.deleted)
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
                         if (completion)
                         {
                             completion(0, [NSError MHVCacheError:@"New cache thing could not be created"]);
                         }
                         return;
                     }
                 }
                 
                 [cachedThing populateWithThing:thing];
             }
             
             //Sync complete, update record with date and sequence number
             record.lastOperationSequenceNumber = lastSequenceNumber;
             record.lastSyncDate = [NSDate date];
             record.isValid = YES;
             
             NSError *error = [self saveContext];
             
             MHVLOG(@"ThingCacheDatabase: Cache record updated %li things", things.count);
             
             if (error)
             {
                 if (completion)
                 {
                     completion(0, error);
                 }
             }
             else
             {
                 if (completion)
                 {
                     completion(things.count, nil);
                 }
             }
         }];
    }
}

- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable records, NSError *_Nullable error))completion
{
    @synchronized (self.lockObject)
    {
        MHVASSERT_PARAMETER(completion);
        
        if (self.deleted)
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
}

- (MHVCachedRecord *)fetchCachedRecord:(NSString *)recordId
{
    // Callers are using @synchronized (self.lockObject)
    __block MHVCachedRecord *record;
    
    if (self.deleted)
    {
        return nil;
    }
    
    [self.managedObjectContext performBlockAndWait:^
     {
         NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedRecord"];
         request.predicate = [NSPredicate predicateWithFormat:@"recordId == %@", recordId];
         
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

#pragma mark - <MHVCachedRecord> properties

- (BOOL)hasRecordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return NO;
        }
        
        __block BOOL hasRecord = NO;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = [self fetchCachedRecord:recordId];
             hasRecord = (record != nil);
         }];
        return hasRecord;
    }
}

- (NSDate *)lastSyncDateFromRecordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return nil;
        }
        
        __block NSDate *date = nil;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = [self fetchCachedRecord:recordId];
             date = record.lastSyncDate;
         }];
        return date;
    }
}

- (NSInteger)lastSequenceNumberFromRecordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return 0;
        }
        
        __block NSInteger sequenceNumber = 0;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = [self fetchCachedRecord:recordId];
             sequenceNumber = record.lastOperationSequenceNumber;
         }];
        return sequenceNumber;
    }
}

- (BOOL)isCacheValidForRecordId:(NSString *)recordId
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return NO;
        }
        
        __block NSInteger isValid = NO;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *record = [self fetchCachedRecord:recordId];
             isValid = record.isValid;
         }];
        return isValid;
    }
}

- (void)setCacheInvalidForRecordId:(NSString *)recordId
{
    __block NSError *error;
    
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return;
        }
        
        MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
        if (record)
        {
            [self.managedObjectContext performBlockAndWait:^
             {
                 MHVCachedRecord *cachedRecord = (MHVCachedRecord *)record;
                 
                 cachedRecord.isValid = NO;
                 cachedRecord.lastSyncDate = nil;
                 cachedRecord.lastOperationSequenceNumber = 0;
                 cachedRecord.things = [NSSet new];
                 
                 error = [self saveContext];
             }];
        }
    }
    
    if (error)
    {
        MHVLOG(@"ThingCacheDatabase: Error setting record as invalid %@", error);
        
        // If can't set record as invalid, something is wrong
        // Delete database and reset so will not be returning invalid data
        [self deleteDatabase];
    }
}

- (NSError *_Nullable)updateRecordId:(NSString *)recordId lastSyncDate:(NSDate *)lastSyncDate sequenceNumber:(NSNumber *)sequenceNumber
{
    @synchronized (self.lockObject)
    {
        if (self.deleted)
        {
            return [NSError MHVCacheDeleted];
        }
        
        __block NSError *error;
        
        // Make sure properties are updated with the correct context
        [self.managedObjectContext performBlockAndWait:^
         {
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
         }];
        
        return error;
    }
}

#pragma mark - Core Data

- (NSError *)saveContext
{
    // Callers are using @synchronized (self.lockObject)
    if (self.deleted)
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

- (NSError *)setupDatabase
{
    NSError *error;
    
    @synchronized (self.lockObject)
    {
        // Check if database already exists
        if (self.managedObjectContext && !self.deleted)
        {
            return nil;
        }
        
        //Setup database URL
        NSURL *applicationSupportURL = [[self.fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        
        [self.fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
        
        self.databaseUrl = [applicationSupportURL URLByAppendingPathComponent:@"mhvcache.db"];
        
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
            return [NSError MHVCacheError:@"Could not create database object model"];
        }
        
        // PersistentSoreCoordinator
        self.persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:@{
                                                                                 EncryptedStorePassphraseKey : [self.keychainService stringForKey:kMHVCachePasswordKey],
                                                                                 EncryptedStoreDatabaseLocation : self.databaseUrl,
                                                                                 }
                                                            managedObjectModel:objectModel];
        if (!self.persistentStoreCoordinator)
        {
            return [NSError MHVCacheError:@"Could not create database storage"];
        }
        
        // Mark database as protected, and that it should not be backed up
        [self.fileManager setAttributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication }
                           ofItemAtPath:self.databaseUrl.path
                                  error:&error];
        if (error)
        {
            return error;
        }
        
        [self.databaseUrl setResourceValue:@(YES)
                                    forKey:NSURLIsExcludedFromBackupKey
                                     error:&error];
        if (error)
        {
            return error;
        }
        
        // NSManagedObjectContext
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        if (!self.managedObjectContext)
        {
            return [NSError MHVCacheError:@"Could not create database managed object context"];
        }
        
        self.deleted = NO;
    }
    
    error = [self saveContext];
    
    return error;
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
