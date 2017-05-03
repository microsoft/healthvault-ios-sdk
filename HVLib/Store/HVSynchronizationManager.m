//
//  HVSynchronizationManager.m
//  HVLib
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
#import "HVCommon.h"
#import "HVSynchronizationManager.h"
#import "HVCachingObjectStore.h"
#import "HVSynchronizedType.h"

@interface HVSynchronizationManager (HVPrivate)

-(void) releaseReferences;
-(BOOL) setupDataStoreWithCache:(BOOL)useCache;
-(HVSynchronizedType *) ensureTypeForTypeID:(NSString *) typeID;

@end

@implementation HVSynchronizationManager

@synthesize store = m_store;
-(HVRecordReference *)record
{
    return m_store.record;
}

@synthesize data = m_data;
@synthesize changeManager = m_changeManager;

-(id)initForRecordStore:(HVLocalRecordStore *)store withCache:(BOOL)cache
{
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_store = store;
    
    HVCHECK_SUCCESS([self setupDataStoreWithCache:cache]);
    
    m_changeManager = [[HVItemChangeManager alloc] initOverStore:store.root forRecord:store.record andData:m_data];
    HVCHECK_NOTNULL(m_changeManager);
    m_changeManager.syncMgr = self;
    
    m_syncTypes = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_syncTypes);
    
    return self;
    
LError:
    HVALLOC_FAIL;    
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
        [m_store.root deleteChildStore:[HVItemChangeManager changeStoreKey]];
        [m_store.root deleteChildStore:[HVSynchronizationManager dataStoreKey]];
    }
}

-(BOOL)hasPendingChanges
{
    return [m_changeManager hasPendingChanges];
}

-(HVTask *)commitPendingChangesWithCallback:(HVTaskCompletion)callback
{
    return [m_changeManager commitChangesWithCallback:callback];
}

-(HVSynchronizedType *)getTypeForClassName:(NSString *)className
{
    NSString *typeID = [[HVTypeSystem current] getTypeIDForClassName:className];
    return [self getTypeForTypeID:typeID];
}

-(HVSynchronizedType *)getTypeForTypeID:(NSString *)typeID
{
    HVCHECK_STRING(typeID);
    
    return [self ensureTypeForTypeID:typeID];

LError:
    return nil;
}

-(HVAutoLock *)newLockForItemKey:(HVItemKey *)key
{
    return [m_changeManager newAutoLockForItemKey:key];
}

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
{
    return [m_data getLocalItemWithKey:key];
}

-(HVItem *)getLocalItemForEditWithKey:(HVItemKey *)key
{
    return [[m_data getLocalItemWithKey:key] newDeepClone];
}

-(HVDownloadItemsTask *)downloadItemWithKey:(HVItemKey *)key withCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(key);
    
    HVItemKeyCollection* keys = [[HVItemKeyCollection alloc] initWithKey:key];
    HVCHECK_NOTNULL(keys);
    
    return [m_data downloadItemsInRecord:self.record forKeys:keys callback:callback];
    
LError:
    return nil;
}

-(BOOL)putNewItem:(HVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    HVCHECK_SUCCESS([item setKeyToNew]);
    HVCHECK_SUCCESS([item ensureEffectiveDate]);

    HVAutoLock* lock = [self newLockForItemKey:item.key];
    if (lock)
    {
        [self putItem:item itemLock:lock];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)putItem:(HVItem *)item itemLock:(HVAutoLock *)lock
{
    HVCHECK_NOTNULL(item);
    
    HVCHECK_SUCCESS([m_changeManager.locks validateLock:lock]);

    item.effectiveDate = nil;
    [item ensureEffectiveDate];
    
    HVCHECK_SUCCESS([m_changeManager trackPut:item]);
    HVCHECK_SUCCESS([m_data.localStore putItem:item]);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)removeItem:(HVItem *)item itemLock:(HVAutoLock *)lock
{
    HVCHECK_NOTNULL(item);
    
    return [self removeItemWithTypeID:item.typeID key:item.key itemLock:lock];
    
LError:
    return FALSE;
}

-(BOOL)removeItemWithTypeID:(NSString *)typeID key:(HVItemKey *)key itemLock:(HVAutoLock *)lock
{
    HVCHECK_NOTNULL(key);
    
    HVCHECK_SUCCESS([m_changeManager.locks validateLock:lock]);
    
    [m_data.localStore removeItem:key.itemID];
    HVCHECK_SUCCESS([m_changeManager trackRemoveForTypeID:typeID andItemKey:key]);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalWithDownloaded:(HVItem *)item
{
    BOOL result = false;
    HVAutoLock* lock = [self newLockForItemKey:item.key];
    if (lock)
    {
        @try
        {
            if (![m_changeManager hasChangesForItem:item])
            {
                result = [m_data.localStore putItem:item];
            }
        }
        @finally
        {
            lock = nil;
        }
    }
    return result;
}

-(BOOL)applyChangeCommitSuccess:(HVItemChange *)change itemLock:(HVAutoLock *)lock
{
    if (change.changeType != HVItemChangeTypePut)
    {
        return TRUE;
    }
    
    HVSynchronizedType* st = [self getTypeForTypeID:change.typeID];
    if (!st)
    {
        return FALSE;
    }
    
    return [st applyChangeCommitSuccess:change itemLock:lock];
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
        for (HVSynchronizedType* st in allTypes)
        {
            [st discardContentIfPossible];
        }
    }
    [m_data clearCache];
}

@end

@implementation HVSynchronizationManager (HVPrivate)

-(void)releaseReferences
{
    for (HVSynchronizedType* st in m_syncTypes.objectEnumerator)
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
    id<HVObjectStore> dataStore = [m_store.root newChildStore:[HVSynchronizationManager dataStoreKey]];
    HVCHECK_NOTNULL(dataStore);
    
    if (useCache)
    {
        id<HVObjectStore> cachingDataStore = [[HVCachingObjectStore alloc] initWithObjectStore:dataStore];
        HVCHECK_NOTNULL(cachingDataStore);
        
        dataStore = cachingDataStore;
    }
    
    m_data = [[HVSynchronizedStore alloc] initOverStore:dataStore];
    
    HVCHECK_NOTNULL(m_data);
    m_data.syncMgr = self;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(HVSynchronizedType *)ensureTypeForTypeID:(NSString *)typeID
{
    @synchronized(self)
    {
        if (!m_store)
        {
            return nil;
        }
        
        HVSynchronizedType* type = [m_syncTypes objectForKey:typeID];
        if (!type)
        {
            type = [[HVSynchronizedType alloc] initForTypeID:typeID withMgr:self];
            HVCHECK_NOTNULL(type);
            
            [m_syncTypes setObject:type forKey:typeID];
            [type endContentAccess];  // To ensure that the cache can remove this object's content
        }
        
        return type;
    
    LError:
        return nil;
    }
}

@end
