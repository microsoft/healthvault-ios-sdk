//
//  MHVSynchronizationManager.m
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
#import "MHVCommon.h"
#import "MHVSynchronizationManager.h"
#import "MHVCachingObjectStore.h"
#import "MHVSynchronizedType.h"

@interface MHVSynchronizationManager (MHVPrivate)

-(void) releaseReferences;
-(BOOL) setupDataStoreWithCache:(BOOL)useCache;
-(MHVSynchronizedType *) ensureTypeForTypeID:(NSString *) typeID;

@end

@implementation MHVSynchronizationManager

@synthesize store = m_store;
-(MHVRecordReference *)record
{
    return m_store.record;
}

@synthesize data = m_data;
@synthesize changeManager = m_changeManager;

-(id)initForRecordStore:(MHVLocalRecordStore *)store withCache:(BOOL)cache
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_store = store;
    
    MHVCHECK_SUCCESS([self setupDataStoreWithCache:cache]);
    
    m_changeManager = [[MHVThingChangeManager alloc] initOverStore:store.root forRecord:store.record andData:m_data];
    MHVCHECK_NOTNULL(m_changeManager);
    m_changeManager.syncMgr = self;
    
    m_syncTypes = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_syncTypes);
    
    return self;
    
LError:
    MHVALLOC_FAIL;    
}

-(void)dealloc
{
    [self releaseReferences];

    
}

-(void)close
{
    @synchronized(self)
    {
        [self releaseReferences];
    }
}

-(void)reset
{
    @synchronized(self)
    {
        [m_store.root deleteChildStore:[MHVThingChangeManager changeStoreKey]];
        [m_store.root deleteChildStore:[MHVSynchronizationManager dataStoreKey]];
    }
}

-(BOOL)hasPendingChanges
{
    return [m_changeManager hasPendingChanges];
}

-(MHVTask *)commitPendingChangesWithCallback:(MHVTaskCompletion)callback
{
    return [m_changeManager commitChangesWithCallback:callback];
}

-(MHVSynchronizedType *)getTypeForClassName:(NSString *)className
{
    NSString *typeID = [[MHVTypeSystem current] getTypeIDForClassName:className];
    return [self getTypeForTypeID:typeID];
}

-(MHVSynchronizedType *)getTypeForTypeID:(NSString *)typeID
{
    MHVCHECK_STRING(typeID);
    
    return [self ensureTypeForTypeID:typeID];

LError:
    return nil;
}

-(MHVAutoLock *)newLockForThingKey:(MHVThingKey *)key
{
    return [m_changeManager newAutoLockForThingKey:key];
}

-(MHVThing *)getLocalThingWithKey:(MHVThingKey *)key
{
    return [m_data getLocalThingWithKey:key];
}

-(MHVThing *)getLocalThingForEditWithKey:(MHVThingKey *)key
{
    return [[m_data getLocalThingWithKey:key] newDeepClone];
}

-(MHVDownloadThingsTask *)downloadThingWithKey:(MHVThingKey *)key withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(key);
    
    MHVThingKeyCollection* keys = [[MHVThingKeyCollection alloc] initWithKey:key];
    MHVCHECK_NOTNULL(keys);
    
    return [m_data downloadThingsInRecord:self.record forKeys:keys callback:callback];
    
LError:
    return nil;
}

-(BOOL)putNewThing:(MHVThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    MHVCHECK_SUCCESS([thing setKeyToNew]);
    MHVCHECK_SUCCESS([thing ensureEffectiveDate]);

    MHVAutoLock* lock = [self newLockForThingKey:thing.key];
    if (lock)
    {
        [self putThing:thing thingLock:lock];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)putThing:(MHVThing *)thing thingLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(thing);
    
    MHVCHECK_SUCCESS([m_changeManager.locks validateLock:lock]);

    thing.effectiveDate = nil;
    [thing ensureEffectiveDate];
    
    MHVCHECK_SUCCESS([m_changeManager trackPut:thing]);
    MHVCHECK_SUCCESS([m_data.localStore putThing:thing]);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)removeThing:(MHVThing *)thing thingLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(thing);
    
    return [self removeThingWithTypeID:thing.typeID key:thing.key thingLock:lock];
    
LError:
    return FALSE;
}

-(BOOL)removeThingWithTypeID:(NSString *)typeID key:(MHVThingKey *)key thingLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(key);
    
    MHVCHECK_SUCCESS([m_changeManager.locks validateLock:lock]);
    
    [m_data.localStore removeThing:key.thingID];
    MHVCHECK_SUCCESS([m_changeManager trackRemoveForTypeID:typeID andThingKey:key]);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalWithDownloaded:(MHVThing *)thing
{
    BOOL result = false;
    MHVAutoLock* lock = [self newLockForThingKey:thing.key];
    if (lock)
    {
        @try
        {
            if (![m_changeManager hasChangesForThing:thing])
            {
                result = [m_data.localStore putThing:thing];
            }
        }
        @finally
        {
            lock = nil;
        }
    }
    return result;
}

-(BOOL)applyChangeCommitSuccess:(MHVThingChange *)change thingLock:(MHVAutoLock *)lock
{
    if (change.changeType != MHVThingChangeTypePut)
    {
        return TRUE;
    }
    
    MHVSynchronizedType* st = [self getTypeForTypeID:change.typeID];
    if (!st)
    {
        return FALSE;
    }
    
    return [st applyChangeCommitSuccess:change thingLock:lock];
}

+(NSString *)dataStoreKey
{
    return @"Data";
}

-(void)clearCache
{
    NSArray* allTypes;
    @synchronized(self)
    {
        allTypes = m_syncTypes.allValues;
    }
    //
    // Do outside lock.. to prevent deadlocks
    //
    if (allTypes)
    {
        for (MHVSynchronizedType* st in allTypes)
        {
            [st discardContentIfPossible];
        }
    }
    [m_data clearCache];
}

@end

@implementation MHVSynchronizationManager (MHVPrivate)

-(void)releaseReferences
{
    for (MHVSynchronizedType* st in m_syncTypes.objectEnumerator)
    {
        st.syncMgr = nil;
    }
    [m_syncTypes removeAllObjects];
    
    m_changeManager.syncMgr = nil;
    m_data.syncMgr = nil;
    
    m_syncTypes = nil;
    m_store = nil;
}


-(BOOL) setupDataStoreWithCache:(BOOL)useCache
{
    id<MHVObjectStore> dataStore = [m_store.root newChildStore:[MHVSynchronizationManager dataStoreKey]];
    MHVCHECK_NOTNULL(dataStore);
    
    if (useCache)
    {
        id<MHVObjectStore> cachingDataStore = [[MHVCachingObjectStore alloc] initWithObjectStore:dataStore];
        MHVCHECK_NOTNULL(cachingDataStore);
        
        dataStore = cachingDataStore;
    }
    
    m_data = [[MHVSynchronizedStore alloc] initOverStore:dataStore];
    
    MHVCHECK_NOTNULL(m_data);
    m_data.syncMgr = self;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(MHVSynchronizedType *)ensureTypeForTypeID:(NSString *)typeID
{
    @synchronized(self)
    {
        if (!m_store)
        {
            return nil;
        }
        
        MHVSynchronizedType* type = [m_syncTypes objectForKey:typeID];
        if (!type)
        {
            type = [[MHVSynchronizedType alloc] initForTypeID:typeID withMgr:self];
            MHVCHECK_NOTNULL(type);
            
            [m_syncTypes setObject:type forKey:typeID];
            [type endContentAccess];  // To ensure that the cache can remove this object's content
        }
        
        return type;
    
    LError:
        return nil;
    }
}

@end
