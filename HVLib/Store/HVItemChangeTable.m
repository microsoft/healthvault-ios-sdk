//
//  HVItemChangeTable.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVItemChangeTable.h"

static NSString* const c_changeObjectRoot = @"change";

@interface HVItemChangeTable (HVPrivate)

-(BOOL) partitionHasItems:(NSString *) partitionKey;
-(HVItemChange *) loadChangeForTypeID:(NSString *) typeID itemID:(NSString *) itemID;

-(NSMutableArray *) getChangeIDsForTypeID:(NSString *)typeID;

-(void) loadAllChangesInto:(NSMutableArray *) array;
-(void) loadChangesForTypeID:(NSString *) typeID into:(NSMutableArray *) array;
-(void) convertChangesToQueue:(NSMutableArray *) array;

@end

@implementation HVItemChangeTable

-(id)init
{
    return [self initWithObjectStore:nil];
}

-(id)initWithObjectStore:(id<HVObjectStore>)store
{
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_store = [[HVPartitionedObjectStore alloc] initWithRoot:store];
    HVCHECK_NOTNULL(m_store);
        
    return self;

LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_store release];
    
    [super dealloc];
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

-(NSString *) trackChange:(enum HVItemChangeType)changeType forTypeID:(NSString *)typeID andKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    @synchronized(m_store)
    {
        HVItemChange* change = [self getForTypeID:typeID itemID:key.itemID];
        if (change)
        {
            HVCHECK_SUCCESS([HVItemChange updateChange:change withTypeID:typeID key:key changeType:changeType]);
        }
        else
        {
            change = [[[HVItemChange alloc] initWithTypeID:typeID key:key changeType:changeType] autorelease];
            HVCHECK_NOTNULL(change);
        }
 
        HVCHECK_SUCCESS([self put:change]);
        
        return [[change.changeID retain] autorelease];
    }
    
LError:
    return nil;
}

-(HVItemChangeQueue *)getQueue
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [self getAllTypesWithChanges];
        HVCHECK_NOTNULL(changedTypes);
        
        return [[[HVItemChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes] autorelease];
        
    LError:
        return nil;
    }
}

-(HVItemChangeQueue *)getQueueForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [NSMutableArray arrayWithObject:typeID];
        HVCHECK_NOTNULL(changedTypes);
        
        return [[[HVItemChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes] autorelease];
        
    LError:
        return nil;
    }
    
}

-(NSMutableArray *)getAll
{
    @synchronized(m_store)
    {
        NSMutableArray* changes = [[[NSMutableArray alloc] init] autorelease];
        HVCHECK_NOTNULL(changes);
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
        NSMutableArray* typeList = [[[NSMutableArray alloc] init] autorelease];
        HVCHECK_NOTNULL(typeList);
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

-(HVItemChange *)getForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    @synchronized(m_store)
    {
        return [m_store partition:typeID getObjectWithKey:itemID name:c_changeObjectRoot andClass:[HVItemChange class]];
    }
}

-(BOOL)put:(HVItemChange *)change
{
    @synchronized(m_store)
    {
        HVCHECK_NOTNULL(change);
        
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

@implementation HVItemChangeTable (HVPrivate)

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
        HVItemChange* change = [self loadChangeForTypeID:typeID itemID:key];
        if (change != nil)
        {
            [array addObject:change];
        }
    }
}

-(HVItemChange *)loadChangeForTypeID:(NSString *)typeID itemID:(NSString *)itemID
{
    return [m_store partition:typeID getObjectWithKey:itemID name:c_changeObjectRoot andClass:[HVItemChange class]];
}

-(NSMutableArray *)getChangeIDsForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        HVCHECK_STRING(typeID);
        
        NSMutableArray* changes = [[[NSMutableArray alloc] init] autorelease];
        HVCHECK_NOTNULL(changes);
        
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
        HVItemChange* c1 = (HVItemChange *) obj1;
        HVItemChange* c2 = (HVItemChange *) obj2;
        
        return [HVItemChange compareChange:c1 to:c2];
    }];
}

@end


@interface HVItemChangeQueue (HVPrivate)

-(BOOL) loadNextTypeQueue;
-(void) clear;

@end

@implementation HVItemChangeQueue

-(id)init
{
    return [self initWithChangeTable:nil andChangedTypes:nil];
}

-(id)initWithChangeTable:(HVItemChangeTable *)changeTable andChangedTypes:(NSMutableArray *)types
{
    HVCHECK_NOTNULL(changeTable);
    HVCHECK_NOTNULL(types);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_changeTable, changeTable);
    HVRETAIN(m_types, types);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_changeTable release];
    [m_types release];
    [m_currentType release];
    [m_currentQueue release];
    
    [super dealloc];
}

-(id)nextObject
{
    return [self nextChange];
}

-(HVItemChange *)nextChange
{
    do
    {
        NSString* changeID = nil;
        while (m_currentQueue && ((changeID = [m_currentQueue dequeueObject]) != nil))
        {
            HVItemChange* change = [m_changeTable getForTypeID:m_currentType itemID:changeID];
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

@implementation HVItemChangeQueue (HVPrivate)

-(BOOL)loadNextTypeQueue
{
    while (TRUE)
    {
        [self clear];
        
        HVRETAIN(m_currentType, [m_types dequeueObject]);
        if (!m_currentType)
        {
            break;
        }
        HVRETAIN(m_currentQueue, [m_changeTable getChangeIDsForTypeID:m_currentType]);
        if (m_currentQueue)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(void)clear
{
    HVCLEAR(m_currentType);
    HVCLEAR(m_currentQueue);
}

@end

