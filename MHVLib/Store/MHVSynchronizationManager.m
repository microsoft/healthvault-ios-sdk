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

@interface MHVSynchronizationManager (HVPrivate)

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
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_store = store;
    
    HVCHECK_SUCCESS([self setupDataStoreWithCache:cache]);
    
    m_changeManager = [[MHVItemChangeManager alloc] initOverStore:store.root forRecord:store.record andData:m_data];
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
        [m_store.root deleteChildStore:[MHVItemChangeManager changeStoreKey]];
        [m_store.root deleteChildStore:[MHVSynchronizationManager dataStoreKey]];
    }
}

-(BOOL)hasPendingChanges
{
    return [m_changeManager hasPendingChanges];
}

-(MHVTask *)commitPendingChangesWithCallback:(HVTaskCompletion)callback
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
    HVCHECK_STRING(typeID);
    
    return [self ensureTypeForTypeID:typeID];

LError:
    return nil;
}

-(MHVAutoLock *)newLockForItemKey:(MHVItemKey *)key
{
    return [m_changeManager newAutoLockForItemKey:key];
}

-(MHVItem *)getLocalItemWithKey:(MHVItemKey *)key
{
    return [m_data getLocalItemWithKey:key];
}

-(MHVItem *)getLocalItemForEditWithKey:(MHVItemKey *)key
{
    return [[m_data getLocalItemWithKey:key] newDeepClone];
}

-(MHVDownloadItemsTask *)downloadItemWithKey:(MHVItemKey *)key withCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(key);
    
    MHVItemKeyCollection* keys = [[MHVItemKeyCollection alloc] initWithKey:key];
    HVCHECK_NOTNULL(keys);
    
    return [m_data downloadItemsInRecord:self.record forKeys:keys callback:callback];
    
LError:
    return nil;
}

-(BOOL)putNewItem:(MHVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    HVCHECK_SUCCESS([item setKeyToNew]);
    HVCHECK_SUCCESS([item ensureEffectiveDate]);

    MHVAutoLock* lock = [self newLockForItemKey:item.key];
    if (lock)
    {
        [self putItem:item itemLock:lock];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)putItem:(MHVItem *)item itemLock:(MHVAutoLock *)lock
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

-(BOOL)removeItem:(MHVItem *)item itemLock:(MHVAutoLock *)lock
{
    HVCHECK_NOTNULL(item);
    
    return [self removeItemWithTypeID:item.typeID key:item.key itemLock:lock];
    
LError:
    return FALSE;
}

-(BOOL)removeItemWithTypeID:(NSString *)typeID key:(MHVItemKey *)key itemLock:(MHVAutoLock *)lock
{
    HVCHECK_NOTNULL(key);
    
    HVCHECK_SUCCESS([m_changeManager.locks validateLock:lock]);
    
    [m_data.localStore removeItem:key.itemID];
    HVCHECK_SUCCESS([m_changeManager trackRemoveForTypeID:typeID andItemKey:key]);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalWithDownloaded:(MHVItem *)item
{
    BOOL result = false;
    MHVAutoLock* lock = [self newLockForItemKey:item.key];
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

-(BOOL)applyChangeCommitSuccess:(MHVItemChange *)change itemLock:(MHVAutoLock *)lock
{
    if (change.changeType != HVItemChangeTypePut)
    {
        return TRUE;
    }
    
    MHVSynchronizedType* st = [self getTypeForTypeID:change.typeID];
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
        for (MHVSynchronizedType* st in allTypes)
        {
            [st discardContentIfPossible];
        }
    }
    [m_data clearCache];
}

@end

@implementation MHVSynchronizationManager (HVPrivate)

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
    HVCHECK_NOTNULL(dataStore);
    
    if (useCache)
    {
        id<MHVObjectStore> cachingDataStore = [[MHVCachingObjectStore alloc] initWithObjectStore:dataStore];
        HVCHECK_NOTNULL(cachingDataStore);
        
        dataStore = cachingDataStore;
    }
    
    m_data = [[MHVSynchronizedStore alloc] initOverStore:dataStore];
    
    HVCHECK_NOTNULL(m_data);
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
