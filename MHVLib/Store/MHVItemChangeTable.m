//
//  MHVItemChangeTable.m
//  MHVLib
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
//

#import "MHVCommon.h"
#import "MHVItemChangeTable.h"

static NSString* const c_changeObjectRoot = @"change";

@interface MHVItemChangeTable (MHVPrivate)

-(BOOL) partitionHasItems:(NSString *) partitionKey;
-(MHVItemChange *) loadChangeForTypeID:(NSString *) typeID itemID:(NSString *) itemID;

-(NSMutableArray *) getChangeIDsForTypeID:(NSString *)typeID;

-(void) loadAllChangesInto:(NSMutableArray *) array;
-(void) loadChangesForTypeID:(NSString *) typeID into:(NSMutableArray *) array;
-(void) convertChangesToQueue:(NSMutableArray *) array;

@end

@implementation MHVItemChangeTable

-(id)init
{
    return [self initWithObjectStore:nil];
}

-(id)initWithObjectStore:(id<MHVObjectStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_store = [[MHVPartitionedObjectStore alloc] initWithRoot:store];
    MHVCHECK_NOTNULL(m_store);
        
    return self;

LError:
    MHVALLOC_FAIL;
}


-(BOOL)hasChangesForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    @synchronized(m_store)
    {
        return  [m_store partition:typeID keyExists:itemID];
    }
}

-(BOOL)hasChangesForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        return [self partitionHasItems:typeID];
    }
}

-(BOOL)hasChanges
{
    @synchronized(m_store)
    {
        NSEnumerator* partitions = [m_store allPartitionKeys];
        for (NSString *typeID in partitions)
        {
            NSEnumerator* keys = [m_store allKeysInPartition:typeID];
            if (keys.nextObject != nil)
            {
                return TRUE;
            }
        }
    }
    return FALSE;
}

-(NSString *) trackChange:(enum MHVItemChangeType)changeType forTypeID:(NSString *)typeID andKey:(MHVItemKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    @synchronized(m_store)
    {
        MHVItemChange* change = [self getForTypeID:typeID itemID:key.itemID];
        if (change)
        {
            MHVCHECK_SUCCESS([MHVItemChange updateChange:change withTypeID:typeID key:key changeType:changeType]);
        }
        else
        {
            change = [[MHVItemChange alloc] initWithTypeID:typeID key:key changeType:changeType];
            MHVCHECK_NOTNULL(change);
        }
 
        MHVCHECK_SUCCESS([self put:change]);
        
        return change.changeID;
    }
    
LError:
    return nil;
}

-(MHVItemChangeQueue *)getQueue
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [self getAllTypesWithChanges];
        MHVCHECK_NOTNULL(changedTypes);
        
        return [[MHVItemChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes];
        
    LError:
        return nil;
    }
}

-(MHVItemChangeQueue *)getQueueForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [NSMutableArray arrayWithObject:typeID];
        MHVCHECK_NOTNULL(changedTypes);
        
        return [[MHVItemChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes];
        
    LError:
        return nil;
    }
    
}

-(NSMutableArray *)getAll
{
    @synchronized(m_store)
    {
        NSMutableArray* changes = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(changes);
        @autoreleasepool
        {
            [self loadAllChangesInto:changes];
        }
        
        return changes;
        
    LError:
        return nil;
    }
}

-(NSMutableArray *)getAllTypesWithChanges
{
    @synchronized(m_store)
    {
        NSMutableArray* typeList = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(typeList);
        @autoreleasepool
        {
            NSEnumerator* partitions = [m_store allPartitionKeys];
            for (NSString *typeID in partitions)
            {
                if ([self partitionHasItems:typeID])
                {
                    [typeList addObject:typeID];
                }
            }
        }
        
        return typeList;
        
    LError:
        return nil;
    }
}

-(MHVItemChange *)getForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    @synchronized(m_store)
    {
        return [m_store partition:typeID getObjectWithKey:itemID name:c_changeObjectRoot andClass:[MHVItemChange class]];
    }
}

-(BOOL)put:(MHVItemChange *)change
{
    @synchronized(m_store)
    {
        MHVCHECK_NOTNULL(change);
        
        return [m_store partition:change.typeID putObject:change withKey:change.itemID andName:c_changeObjectRoot];
    
    LError:
        return false;
    }
}

-(BOOL)removeForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    @synchronized(m_store)
    {
        return [m_store partition:(NSString *) typeID deleteKey:itemID];
    }
}

-(BOOL)removeAllForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        return [m_store deletePartition:typeID];
    }
}

-(void)removeAll
{
    @synchronized(m_store)
    {
        NSEnumerator* partitionNames = [m_store allPartitionKeys];
        for (NSString* name in partitionNames)
        {
            [m_store deletePartition:name];
        }
    }
}


@end

@implementation MHVItemChangeTable (MHVPrivate)

-(BOOL)partitionHasItems:(NSString *)partitionKey
{
    NSEnumerator* keys = [m_store allKeysInPartition:partitionKey];
    return (keys.nextObject != nil);
}

-(void)loadAllChangesInto:(NSMutableArray *)array
{
    NSEnumerator* partitions = [m_store allPartitionKeys];
    for (NSString *typeID in partitions)
    {
        [self loadChangesForTypeID:typeID into:array];
    }
}

-(void)loadChangesForTypeID:(NSString *)typeID into:(NSMutableArray *)array
{
    NSEnumerator* keys = [m_store allKeysInPartition:typeID];
    for (NSString* key in keys)
    {
        MHVItemChange* change = [self loadChangeForTypeID:typeID itemID:key];
        if (change != nil)
        {
            [array addObject:change];
        }
    }
}

-(MHVItemChange *)loadChangeForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    return [m_store partition:typeID getObjectWithKey:itemID name:c_changeObjectRoot andClass:[MHVItemChange class]];
}

-(NSMutableArray *)getChangeIDsForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        MHVCHECK_STRING(typeID);
        
        NSMutableArray* changes = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(changes);
        
        @autoreleasepool
        {
            NSEnumerator* changeIDs = [m_store allKeysInPartition:typeID];
            [changes addFromEnumerator:changeIDs];
        }
        
        return changes;
        
    LError:
        return nil;
    }    
}

-(void)convertChangesToQueue:(NSMutableArray *)array
{
    if (array.count <= 1)
    {
        return;
    }
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MHVItemChange* c1 = (MHVItemChange *) obj1;
        MHVItemChange* c2 = (MHVItemChange *) obj2;
        
        return [MHVItemChange compareChange:c1 to:c2];
    }];
}

@end


@interface MHVItemChangeQueue (MHVPrivate)

-(BOOL) loadNextTypeQueue;
-(void) clear;

@end

@implementation MHVItemChangeQueue

-(id)init
{
    return [self initWithChangeTable:nil andChangedTypes:nil];
}

-(id)initWithChangeTable:(MHVItemChangeTable *)changeTable andChangedTypes:(NSMutableArray *)types
{
    MHVCHECK_NOTNULL(changeTable);
    MHVCHECK_NOTNULL(types);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_changeTable = changeTable;
    m_types = types;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(id)nextObject
{
    return [self nextChange];
}

-(MHVItemChange *)nextChange
{
    do
    {
        NSString* changeID = nil;
        while (m_currentQueue && ((changeID = [m_currentQueue dequeueObject]) != nil))
        {
            MHVItemChange* change = [m_changeTable getForTypeID:m_currentType itemID:changeID];
            if (change)
            {
                return change;
            }
        }
    }
    while ([self loadNextTypeQueue]);
    
    return nil;
}

@end

@implementation MHVItemChangeQueue (MHVPrivate)

-(BOOL)loadNextTypeQueue
{
    while (TRUE)
    {
        [self clear];
        
        m_currentType = [m_types dequeueObject];
        if (!m_currentType)
        {
            break;
        }
        m_currentQueue = [m_changeTable getChangeIDsForTypeID:m_currentType];
        if (m_currentQueue)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(void)clear
{
    m_currentType = nil;
    m_currentQueue = nil;
}

@end

