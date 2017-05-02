//
//  HVPartitionedStore.m
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
#import "HVCommon.h"
#import "HVPartitionedStore.h"

@interface HVPartitionedObjectStore (HVPrivate)

-(id<HVObjectStore>) ensurePartition:(NSString *) partitionKey shouldCreate:(BOOL) shouldCreate;

@end

@implementation HVPartitionedObjectStore

-(id)init
{
    return [self initWithRoot:nil];
}

-(id)initWithRoot:(id<HVObjectStore>)root
{
    HVCHECK_NOTNULL(root);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_partitions = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_partitions);
    
    m_rootStore = [root retain];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_rootStore release];
    [m_partitions release];
    
    [super dealloc];
}

-(BOOL)partition:(NSString *)partitionKey keyExists:(NSString *)key
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return FALSE;
    }
    
    return [store keyExists:key];
    
LError:
    return FALSE;
}

-(id)partition:(NSString *)partitionKey getObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return nil;
    }
    
    return [store getObjectWithKey:key name:name andClass:cls];
    
LError:
    return nil;
}

-(BOOL)partition:(NSString *)partitionKey putObject:(id)obj withKey:(NSString *)key andName:(NSString *)name
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:TRUE];
    HVCHECK_NOTNULL(store);
    
    return [store putObject:obj withKey:key andName:name];
    
LError:
    return FALSE;
}

-(BOOL)partition:(NSString *) partitionKey deleteKey:(NSString *)key
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return FALSE;
    }
    
    return [store deleteKey:key];
    
LError:
    return FALSE;
}

-(BOOL)deletePartition:(NSString *)partitionKey
{
    @synchronized(m_partitions)
    {
        [m_partitions removeObjectForKey:partitionKey];
        [m_rootStore deleteChildStore:partitionKey];
        return TRUE;
    }
}

-(NSDate *)partition:(NSString *)partitionKey createDateForKey:(NSString *)key
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return nil;
    }
    
    return [store createDateForKey:key];
    
LError:
    return nil;
}

-(NSDate *)partition:(NSString *)partitionKey updateDateForKey:(NSString *)key
{
    HVCHECK_NOTNULL(partitionKey);
    HVCHECK_NOTNULL(key);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return nil;
    }
    
    return [store updateDateForKey:key];
    
LError:
    return nil;
}

-(NSEnumerator *)allKeysInPartition:(NSString *)partitionKey
{
    HVCHECK_NOTNULL(partitionKey);
    
    id<HVObjectStore> store = [self ensurePartition:partitionKey shouldCreate:FALSE];
    if (!store)
    {
        return nil;
    }
    
    return [store allKeys];
    
LError:
    return nil;
}

-(NSEnumerator *)allPartitionKeys
{
    return [m_rootStore allChildStoreNames];
}

-(void)clearCache
{
    @synchronized(m_partitions)
    {
        [m_partitions removeAllObjects];
    }
}

@end

@implementation HVPartitionedObjectStore (HVPrivate)

-(id<HVObjectStore>)ensurePartition:(NSString *)partitionKey shouldCreate:(BOOL)shouldCreate
{
    @synchronized(m_partitions)
    {
        id<HVObjectStore> store = [m_partitions objectForKey:partitionKey];
        if (store == nil)
        {
            if (!shouldCreate && ![m_rootStore childStoreExists:partitionKey])
            {
                return nil;
            }
            store = [m_rootStore newChildStore:partitionKey];
            [m_partitions setObject:store forKey:partitionKey];
            [store release];
        }
        
        return store;
    }
}

@end
