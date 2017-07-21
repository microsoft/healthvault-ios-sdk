//
//  MHVMockDatabase.m
//  healthvault-ios-sdk
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVMockDatabase.h"
#import "NSError+MHVError.h"

#pragma mark - Mock Database Record

@interface MHVMockRecord ()

@property (nonatomic, strong) NSDate *lastSyncDate;
@property (nonatomic, strong) NSDate *lastConsistencyDate;
@property (nonatomic, assign) NSInteger lastCacheSequenceNumber;
@property (nonatomic, assign) NSInteger lastHealthVaultSequenceNumber;
@property (nonatomic, assign) BOOL isValid;

@property (nonatomic, strong) NSMutableArray<MHVThing *> *thingsInternal;

@end

@implementation MHVMockRecord

- (NSArray<MHVThing *> *)things
{
    return _thingsInternal;
}

- (NSMutableArray<MHVThing *> *)thingsInternal
{
    if (!_thingsInternal)
    {
        _thingsInternal = [NSMutableArray new];
    }
    return _thingsInternal;
}

#pragma mark MHVCacheStatusProtocol

- (NSDate *)lastCompletedSyncDate;
{
    return self.lastSyncDate;
}

- (NSDate *)lastCacheConsistencyDate;
{
    return self.lastConsistencyDate;
}

- (NSInteger)newestCacheSequenceNumber;
{
    return self.lastCacheSequenceNumber;
}

- (NSInteger)newestHealthVaultSequenceNumber;
{
    return self.lastHealthVaultSequenceNumber;
}

- (BOOL)isCacheValid
{
    return self.isValid;
}

@end

#pragma mark - Mock Database

@interface MHVMockDatabase ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MHVMockRecord *> *database;

@end

@implementation MHVMockDatabase

- (instancetype)initWithRecordIds:(NSArray<NSString *> *)recordIds
                        hasSynced:(BOOL)hasSynced
                 shouldHaveThings:(BOOL)shouldHaveThings
{
    self = [super init];
    if (self)
    {
        _database = [NSMutableDictionary new];
        
        for (NSString *recordIdString in recordIds)
        {
            NSString *recordId = [recordIdString lowercaseString];
            
            MHVMockRecord *record = [MHVMockRecord new];
            record.isValid = YES;
            
            if (hasSynced)
            {
                NSDate *now = [NSDate date];
                record.lastCacheSequenceNumber = 1;
                record.lastHealthVaultSequenceNumber = 1;
                record.lastSyncDate = now;
                record.lastConsistencyDate = now;
            }
            
            if (shouldHaveThings)
            {
                MHVThing *thing = [MHVAllergy newThing];
                MHVAllergy *allergy = thing.allergy;
                thing.key = [[MHVThingKey alloc] initWithID:@"thing-id-1"
                                                 andVersion:@"version-id-1"];
                
                allergy.name = [MHVCodableValue fromText:@"Allergy to Shellfish"];
                allergy.allergenType = [MHVCodableValue fromText:@"food"];
                allergy.reaction = [MHVCodableValue fromText:@"anaphylactic shock"];
                
                [record.thingsInternal addObject:thing];
            }
            
            _database[[recordId lowercaseString]] = record;
        }
    }
    return self;
}

- (void)setupDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion
{
    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    if (!self.database)
    {
        self.database = [NSMutableDictionary new];
    }
    completion(nil);
}

- (void)resetDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion
{
    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    if (self.ignoreDeletes)
    {
        completion(nil);
        return;
    }
    
    self.database = [NSMutableDictionary new];
    completion(nil);
}

- (void)setupCacheForRecordIds:(NSArray<NSString *> *)recordIds
                    completion:(void (^)(NSError *_Nullable error))completion
{
    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    for (NSString *recordIdString in recordIds)
    {
        NSString *recordId = [recordIdString lowercaseString];
        
        if (!self.database[recordId])
        {
            self.database[recordId] = [MHVMockRecord new];
        }
    }
    completion(nil);
}

- (void)deleteCacheForRecordId:(NSString *)recordId
          completion:(void (^)(NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];

    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion([NSError MHVCacheError:@"Record could not be found"]);
        return;
    }
    
    self.database[recordId] = nil;
    completion(nil);
}

- (void)deleteCachedThingsWithThingIds:(NSArray<NSString *> *)thingIds
                              recordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];

    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion([NSError MHVCacheError:@"Record could not be found"]);
        return;
    }
    
    for (NSString *thingId in thingIds)
    {
        NSInteger index = [self.database[recordId].thingsInternal indexOfThingID:thingId];
        if (index != NSNotFound)
        {
            [self.database[recordId].thingsInternal removeObjectAtIndex:index];
        }
    }
    
    completion(nil);
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


- (void)synchronizeThings:(NSArray<MHVThing *> *)things
                 recordId:(NSString *)recordId
      batchSequenceNumber:(NSInteger)batchSequenceNumber
       latestSequenceNumber:(NSInteger)latestSequenceNumber
               completion:(void (^)(NSInteger synchronizedItemCount, NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];

    if (self.errorToReturn)
    {
        completion(0, self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion(0, [NSError MHVCacheError:@"Record could not be found"]);
        return;
    }
    
    for (MHVThing *thing in things)
    {
        NSInteger index = [self.database[recordId].thingsInternal indexOfThingID:thing.key.thingID];
        if (index == NSNotFound)
        {
            //Add
            [self.database[recordId].thingsInternal addObject:thing];
        }
        else
        {
            //Update
            self.database[recordId].thingsInternal[index] = thing;
        }
    }
    
    completion(things.count, nil);
}

- (void)cachedResultForQuery:(MHVThingQuery *)query
                    recordId:(NSString *)recordId
                completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];

    if (self.errorToReturn)
    {
        completion(nil, self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion(nil, [NSError MHVCacheError:@"Record could not be found"]);
        return;
    }
    
    // For testing cache, not database so return all things
    MHVThingQueryResult *result = [[MHVThingQueryResult alloc] initWithName:query.name
                                                                     things:self.database[recordId].thingsInternal
                                                                      count:self.database[recordId].thingsInternal.count
                                                             isCachedResult:YES];
    completion(result, nil);
}

- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable recordIds, NSError *_Nullable error))completion
{
    if (self.errorToReturn)
    {
        completion(nil, self.errorToReturn);
        return;
    }
    
    completion(self.database.allKeys, nil);
}

- (void)cacheStatusForRecordId:(NSString *)recordId
                    completion:(void (^)(id<MHVCacheStatusProtocol> _Nullable status, NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];
    
    if (self.errorToReturn)
    {
        completion(nil, self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion(nil, [NSError MHVCacheError:@"Record does not exist"]);
        return;
    }
    
    MHVMockRecord *record = self.database[recordId];
    
    completion(record, nil);
}

- (void)updateLastCompletedSyncDate:(NSDate *)lastCompletedSyncDate
           lastCacheConsistencyDate:(NSDate *)lastCacheConsistencyDate
                     sequenceNumber:(NSInteger)sequenceNumber
                           recordId:(NSString *)recordId
                         completion:(void (^)(NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];

    if (self.errorToReturn)
    {
        completion(self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion([NSError MHVCacheError:@"Record could not be found"]);
        return;
    }
    
    MHVMockRecord *record = self.database[recordId];
    record.lastSyncDate = lastCompletedSyncDate;
    record.lastConsistencyDate = lastCacheConsistencyDate;
    record.lastCacheSequenceNumber = sequenceNumber;
    record.lastHealthVaultSequenceNumber = sequenceNumber;
    
    completion(nil);
}

- (void)cachePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                 completion:(void (^)(NSError *_Nullable error))completion;
{
    if (completion)
    {
        completion(self.errorToReturn);
    }
}

- (void)fetchPendingMethodsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSArray<MHVPendingMethod *> *_Nullable methods, NSError *_Nullable error))completion
{
    if (completion)
    {
        completion(self.database[recordId].methods, self.errorToReturn);
    }
}

- (void)deletePendingMethods:(NSArray<MHVPendingMethod *> *)pendingMethods
                  completion:(void (^)(NSError *_Nullable error))completion;
{
    if (completion)
    {
        completion(self.errorToReturn);
    }
}

- (void)createPendingCachedThings:(NSArray<MHVThing *> *)things
                         recordId:(NSString *)recordId
                       completion:(void (^)(NSError *_Nullable error))completion;
{
    if (completion)
    {
        completion(self.errorToReturn);
    }
}

- (void)fetchPendingThingsForRecordId:(NSString *)recordId
                           completion:(void (^)(NSArray<MHVThing *> *_Nullable things, NSError *_Nullable error))completion
{
    if (completion)
    {
        completion(self.database[recordId].things, self.errorToReturn);
    }
}

-(void)deletePendingThingsForRecordId:(NSString *)recordId
                            completion:(void (^)(NSError *_Nullable error))completion;
{
    if (completion)
    {
        completion(self.errorToReturn);
    }
}

@end
