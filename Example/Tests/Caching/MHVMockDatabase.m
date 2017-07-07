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
@property (nonatomic, assign) NSInteger lastSequenceNumber;

@property (nonatomic, strong) MHVThingCollection *things;

@end

@implementation MHVMockRecord

- (MHVThingCollection *)things
{
    if (!_things)
    {
        _things = [MHVThingCollection new];
    }
    return _things;
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
            
            if (hasSynced)
            {
                record.lastSequenceNumber = 1;
                record.lastSyncDate = [NSDate date];
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
                
                [record.things addObject:thing];
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

- (void)setupRecordIds:(NSArray<NSString *> *)recordIds
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

- (void)deleteRecord:(NSString *)recordId
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

- (void)deleteThingIds:(NSArray<NSString *> *)thingIds
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
        NSInteger index = [self.database[recordId].things indexOfThingID:thingId];
        if (index != NSNotFound)
        {
            [self.database[recordId].things removeObjectAtIndex:index];
        }
    }
    
    completion(nil);
}

- (void)addOrUpdateThings:(MHVThingCollection *)things
                 recordId:(NSString *)recordId
       lastSequenceNumber:(NSInteger)lastSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion
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
        NSInteger index = [self.database[recordId].things indexOfThingID:thing.key.thingID];
        if (index == NSNotFound)
        {
            //Add
            [self.database[recordId].things addObject:thing];
        }
        else
        {
            //Update
            [self.database[recordId].things setObject:thing atIndexedSubscript:index];
        }
    }
    
    completion(things.count, nil);
}

- (void)cachedResultsForQuery:(MHVThingQuery *)query
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
    MHVThingQueryResult *result = [[MHVThingQueryResult alloc] init];
    result.things = self.database[recordId].things;
    result.isCachedResult = YES;
    result.name = query.name;
    
    completion(result, nil);
}

- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable records, NSError *_Nullable error))completion
{
    if (self.errorToReturn)
    {
        completion(nil, self.errorToReturn);
        return;
    }
    
    completion(self.database.allKeys, nil);
}

- (void)cacheStatusForRecordId:(NSString *)recordId
                    completion:(void (^)(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error))completion
{
    recordId = [recordId lowercaseString];
    
    if (self.errorToReturn)
    {
        completion(nil, 0, NO, self.errorToReturn);
        return;
    }
    
    if (self.database[recordId] == nil)
    {
        completion(nil, 0, NO, [NSError MHVCacheError:@"Record does not exist"]);
        return;
    }
    
    MHVMockRecord *record = self.database[recordId];
    completion(record.lastSyncDate, record.lastSequenceNumber, YES, nil);
}

- (void)updateRecordId:(NSString *)recordId
          lastSyncDate:(NSDate *_Nullable)lastSyncDate
        sequenceNumber:(NSNumber *_Nullable)sequenceNumber
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
    record.lastSyncDate = lastSyncDate;
    record.lastSequenceNumber = sequenceNumber.integerValue;
    completion(nil);
}

@end
