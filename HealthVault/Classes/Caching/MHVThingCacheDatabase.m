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

static NSString *kMHVCachePasswordKey = @"MHVCachePassword";

@interface MHVThingCacheDatabase ()

@property (nonatomic, strong) NSPersistentStoreCoordinator      *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel              *objectModel;
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
        
        [self.keychainService setString:nil forKey:kMHVCachePasswordKey];
        
        _persistentStoreCoordinator = nil;
        _objectModel = nil;
        _managedObjectContext = nil;
        _databaseUrl = nil;
        
        _deleted = YES;
    }
    
    return error;
}

#pragma mark - Create Objects

- (MHVCachedThing *)newThingForRecord:(MHVCachedRecord *)record
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

- (MHVCachedRecord *)newRecord:(NSString *)recordId
{
    if (self.deleted || !recordId)
    {
        return nil;
    }
    
    __block MHVCachedRecord *record;
    
    [self.managedObjectContext performBlockAndWait:^
     {
         record = [NSEntityDescription insertNewObjectForEntityForName:@"MHVCachedRecord"
                                                inManagedObjectContext:self.managedObjectContext];
         record.recordId = recordId;
         record.lastOperationSequenceNumber = 0;
         record.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0];
         record.isValid = YES;
         
         [self saveContext];
     }];
    
    return record;
}

#pragma mark - Delete

- (void)deleteRecord:(NSString *)recordId
{
    MHVASSERT_PARAMETER(recordId);
    
    if (self.deleted || !recordId)
    {
        return;
    }
    
    [self.managedObjectContext performBlockAndWait:^
     {
         MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
         if (record)
         {
             [self.managedObjectContext deleteObject:record];
             [self saveContext];
         }
     }];
}

- (NSError *_Nullable)deleteThingIds:(NSArray<NSString *> *)thingIds recordId:(NSString *)recordId
{
    MHVASSERT_PARAMETER(thingIds);
    MHVASSERT_PARAMETER(recordId);
    
    if (self.deleted || !thingIds || thingIds.count == 0)
    {
        return nil;
    }
    
    if (!recordId)
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

- (void)addOrUpdateThings:(MHVThingCollection *)things
                 recordId:(NSString *)recordId
       lastSequenceNumber:(NSInteger)lastSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion
{
    MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
    
    if (self.deleted)
    {
        if (completion)
        {
            completion(0, nil);
        }
        return;
    }
    
    if (!record)
    {
        if (completion)
        {
            completion(0, [NSError MVHRequiredParameterIsNil]);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         for (MHVThing *thing in things)
         {
             MHVCachedThing *cachedThing = [record findThingWithThingId:thing.thingID];
             if (!cachedThing)
             {
                 //Not found, need to create...
                 cachedThing = [self newThingForRecord:record];
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

- (void)fetchCachedRecords:(void(^)(NSArray<id<MHVCachedRecord>> *_Nullable records))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (self.deleted)
    {
        if (completion)
        {
            completion(nil);
        }
        return;
    }
    
    [self.managedObjectContext performBlock:^
     {
         NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MHVCachedRecord"];
         
         NSError *error = nil;
         NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
         if (!results && error)
         {
             MHVLOG(@"ThingCacheDatabase: Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
         }
         
         if (completion)
         {
             completion(results);
         }
     }];
}

- (MHVCachedRecord *)fetchCachedRecord:(NSString *)recordId
{
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

- (NSString *)recordIdFromRecord:(id<MHVCachedRecord>)record
{
    __block NSString *recordId;
    
    // Make sure properties are retrieved with the correct context
    [self.managedObjectContext performBlockAndWait:^
     {
         recordId = ((MHVCachedRecord *)record).recordId;
     }];
    return recordId;
}

- (NSDate *)lastSyncDateFromRecord:(id<MHVCachedRecord>)record
{
    __block NSDate *date;
    
    // Make sure properties are retrieved with the correct context
    [self.managedObjectContext performBlockAndWait:^
     {
         date = ((MHVCachedRecord *)record).lastSyncDate;
     }];
    return date;
}

- (NSInteger)lastSequenceNumberFromRecord:(id<MHVCachedRecord>)record
{
    __block NSInteger sequenceNumber;
    
    // Make sure properties are retrieved with the correct context
    [self.managedObjectContext performBlockAndWait:^
     {
         sequenceNumber = ((MHVCachedRecord *)record).lastOperationSequenceNumber;
     }];
    return sequenceNumber;
}

- (BOOL)isCacheValidForRecord:(id<MHVCachedRecord>)record
{
    __block NSInteger isValid;
    
    // Make sure properties are retrieved with the correct context
    [self.managedObjectContext performBlockAndWait:^
     {
         isValid = ((MHVCachedRecord *)record).isValid;
     }];
    return isValid;
}

- (void)setCacheInvalidForRecordId:(NSString *)recordId
{
    MHVCachedRecord *record = (MHVCachedRecord *)[self fetchCachedRecord:recordId];
    
    if (record)
    {
        __block NSError *error;
        
        [self.managedObjectContext performBlockAndWait:^
         {
             MHVCachedRecord *cachedRecord = (MHVCachedRecord *)record;
             
             cachedRecord.isValid = NO;
             cachedRecord.lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0];
             cachedRecord.lastOperationSequenceNumber = 0;
             
             error = [self saveContext];
         }];
        
        if (error)
        {
            MHVLOG(@"Error setting record as invalid %@", error);
            
            // If can't set record as invalid, something is wrong
            // Delete database and reset so will not be returning invalid data
            [self deleteDatabase];
        }
    }
}

- (NSError *_Nullable)updateRecord:(id<MHVCachedRecord>)record lastSyncDate:(NSDate *)lastSyncDate sequenceNumber:(NSNumber *)sequenceNumber
{
    __block NSError *error = nil;
    
    // Make sure properties are updated with the correct context
    [self.managedObjectContext performBlockAndWait:^
     {
         MHVCachedRecord *cachedRecord = (MHVCachedRecord *)record;
         
         if (lastSyncDate)
         {
             cachedRecord.lastSyncDate = lastSyncDate;
         }
         if (sequenceNumber)
         {
             cachedRecord.lastOperationSequenceNumber = sequenceNumber.integerValue;
         }
         
         cachedRecord.isValid = YES;
         
         error = [self saveContext];
     }];
    
    return error;
}

#pragma mark - Core Data

- (NSError *)saveContext
{
    if (self.deleted)
    {
        return nil;
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

- (NSURL *)databaseUrl
{
    @synchronized(self.lockObject)
    {
        if (self.deleted)
        {
            return nil;
        }
        
        if (!_databaseUrl)
        {
            NSURL *applicationSupportURL = [[self.fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
            
            [self.fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
            
            _databaseUrl = [applicationSupportURL URLByAppendingPathComponent:@"mhvcache.db"];
        }
        return _databaseUrl;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(self.lockObject)
    {
        if (self.deleted)
        {
            return nil;
        }
        
        if (!_persistentStoreCoordinator)
        {
            //If new database, create password
            if (![self.fileManager fileExistsAtPath:self.databaseUrl.path])
            {
                //Generate a new password and store in the keychain
                [self.keychainService setString:[self generateRandomPassword]
                                         forKey:kMHVCachePasswordKey];
            }
            
            _persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:@{
                                                                                 EncryptedStorePassphraseKey : [self.keychainService stringForKey:kMHVCachePasswordKey],
                                                                                 EncryptedStoreDatabaseLocation : self.databaseUrl,
                                                                                 }
                                                            managedObjectModel:[self objectModel]];
            [self saveContext];
            
            // Mark database as protected, and that it should not be backed up
            [self.fileManager setAttributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication }
                               ofItemAtPath:self.databaseUrl.path
                                      error:nil];
            
            [self.databaseUrl setResourceValue:@(YES)
                                        forKey:NSURLIsExcludedFromBackupKey
                                         error:nil];
        }
        return _persistentStoreCoordinator;
    }
}

- (NSManagedObjectModel *)objectModel
{
    @synchronized(self.lockObject)
    {
        if (self.deleted)
        {
            return nil;
        }
        
        if (!_objectModel)
        {
            NSBundle *bundle = [NSBundle bundleForClass:[MHVCachedThing class]];
            NSURL *modelURL = [bundle URLForResource:@"MHVThingCacheDatabase" withExtension:@"momd"];
            
            _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            if(!_objectModel)
            {
                _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
            }
        }
        return _objectModel;
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    @synchronized(self.lockObject)
    {
        if (self.deleted)
        {
            return nil;
        }
        
        if (!_managedObjectContext)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        }
        return _managedObjectContext;
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
