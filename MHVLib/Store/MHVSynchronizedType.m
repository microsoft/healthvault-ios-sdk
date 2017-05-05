//
//  MHVSynchronizedType.m
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
#import "MHVSynchronizedType.h"

#define BEGINVIEWOP \
    @try { \
        MHVTypeView* view = [self beginViewOp]; \

#define ENDVIEWOP \
    } \
    @finally { \
        [self endViewOp]; \
    }

MHVDEFINE_NOTIFICATION(MHVSynchronizedTypeItemsAvailableNotification);
MHVDEFINE_NOTIFICATION(MHVSynchronizedTypeKeysNotAvailableNotification);
MHVDEFINE_NOTIFICATION(MHVSynchronizedTypeSyncCompletedNotification);
MHVDEFINE_NOTIFICATION(MHVSynchronizedTypeSyncFailedNotification);

@interface MHVSynchronizedType (MHVPrivate)

-(MHVTypeView *) beginViewOp;
-(void) endViewOp;

-(MHVTypeView *) ensureView;
-(MHVTypeView *) loadView;
-(void) releaseView;
-(BOOL) saveView;

-(BOOL) addKeyForItem:(MHVItem *) item;
-(BOOL) updateKeyForItem:(MHVItem *) item;
-(BOOL) replaceItemID:(NSString *) itemID withItem:(MHVItem *) item;
-(BOOL) removeKey:(MHVItemKey *) key;

@end

@interface MHVItemEditOperation (MHVPrivate)

-(id) initForType:(MHVSynchronizedType *) type item:(MHVItem *) item andLock:(MHVAutoLock *) lock;

@end

@implementation MHVSynchronizedType

-(MHVSynchronizationManager *)syncMgr
{
    @synchronized(self)
    {
        return m_syncMgr;
    }
}

-(void)setSyncMgr:(MHVSynchronizationManager *)syncMgr
{
    @synchronized(self)
    {
        [self releaseView];
        if (syncMgr)
        {
            m_syncMgr = syncMgr;
        }
        else
        {
            m_syncMgr = nil;
        }
    }
}

-(BOOL)isLoaded
{
    return (![self isContentDiscarded]);
}

-(NSString *)typeID
{
    return m_typeID;
}

-(MHVRecordReference *)record
{
    @synchronized(self)
    {
        return m_syncMgr.record;
    }
}

-(NSDate *)lastUpdateDate
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return view.lastUpdateDate;
        ENDVIEWOP
    }
}

-(void)setLastUpdateDate:(NSDate *)lastUpdateDate
{
    @synchronized(self)
    {
        BEGINVIEWOP
        view.lastUpdateDate = lastUpdateDate;
        ENDVIEWOP
    }
}

-(NSUInteger)count
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return view.count;
        ENDVIEWOP
    }
}

-(NSInteger)maxItems
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return view.maxItems;
        ENDVIEWOP
    }
}

-(void)setMaxItems:(NSInteger)maxItems
{
    @synchronized(self)
    {
        BEGINVIEWOP
        view.maxItems = maxItems;
        ENDVIEWOP
    }
}

-(NSInteger)readAheadChunkSize
{
    @synchronized(self)
    {
        return m_readAheadChunkSize;
    }
}

-(void)setReadAheadChunkSize:(NSInteger)readAheadChunkSize
{
    @synchronized(self)
    {
        if (readAheadChunkSize > 0)
        {
            m_readAheadChunkSize = readAheadChunkSize;
        }
        else
        {
            m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
        }
        if (m_view)
        {
            m_view.readAheadChunkSize = m_readAheadChunkSize;
        }
    }
}

@synthesize broadcastNotifications = m_broadcastNotifications;

-(id)init
{
    return [self initForTypeID:nil withMgr:nil];
}


-(id)initForTypeID:(NSString *)typeID withMgr:(MHVSynchronizationManager *)syncMgr
{
    MHVCHECK_STRING(typeID);
    MHVCHECK_NOTNULL(syncMgr);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_typeID = typeID;
    m_viewName = [MHVSynchronizedType makeViewNameForTypeID:typeID];
    
    self.syncMgr = syncMgr;
    
    m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    m_broadcastNotifications = TRUE;
    m_accessCount = 1; // As per NSDiscardableContent docs
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void)dealloc
{
    
    [self releaseView];
    
}

-(BOOL)hasPendingChanges
{
    @synchronized(self)
    {
        return [m_syncMgr.changeManager hasChangesForTypeID:m_typeID];
    }
}

-(MHVItemKey *)keyAtIndex:(NSUInteger)index
{
    return [self itemKeyAtIndex:index];
}

-(MHVTypeViewItem *)itemKeyAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view itemKeyAtIndex:index];
        ENDVIEWOP
    }
}

-(NSUInteger)indexOfItemID:(NSString *)itemID
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view indexOfItemID:itemID];
        ENDVIEWOP
    }
}

-(MHVItem *)getItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemAtIndex:index];
        ENDVIEWOP
    }
}

-(MHVItem *)getItemByID:(NSString *)itemID
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemByID:itemID];
        ENDVIEWOP
    }
}

-(MHVItemCollection *)getItemsInRange:(NSRange)range
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemsInRange:range];
        ENDVIEWOP
    }
}

-(MHVItem *)getLocalItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getLocalItemAtIndex:index];
        ENDVIEWOP
    }
}

-(MHVItem *)getLocalItemWithKey:(MHVItemKey *)key
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getLocalItemWithKey:key];
        ENDVIEWOP
    }
}

-(NSArray *)keysOfItemsNeedingDownloadInRange:(NSRange)range
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view keysOfItemsNeedingDownloadInRange:range];
        ENDVIEWOP
    }
}

-(MHVTask *)ensureItemsDownloadedInRange:(NSRange)range withCallback:(MHVTaskCompletion)callback
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view ensureItemsDownloadedInRange:range withCallback:callback];
        ENDVIEWOP
    }
}

-(BOOL)isStale:(NSTimeInterval)maxAge
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view isStale:maxAge];
        ENDVIEWOP
     }
}

-(MHVTask *)refresh
{
    @synchronized(self)
    {
        if ([self hasPendingChanges])
        {
            return nil;
        }
        
        BEGINVIEWOP
        return [view refresh];
        ENDVIEWOP
     }
}

-(MHVTask *)refreshWithCallback:(MHVTaskCompletion)callback
{
    @synchronized(self)
    {
        if ([self hasPendingChanges])
        {
            return nil;
        }
        
        BEGINVIEWOP
        return [view refreshWithCallback:callback];
        ENDVIEWOP
    }
}

-(MHVItemQuery *)getQuery
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getQuery];
        ENDVIEWOP
    }
}

-(BOOL)replaceKeys:(MHVTypeViewItems *)items
{
    @synchronized(self)
    {
        BOOL success = FALSE;
        
        BEGINVIEWOP
        success = [view replaceKeys:items];
        ENDVIEWOP
        
        if (success)
        {
            [self synchronizationCompletedInView:nil];
        }
    }
}

-(MHVTask *)ensureItemDownloadedForKey:(MHVItemKey *)key withCallback:(MHVTaskCompletion)callback
{
    @synchronized(self)
    {
        BEGINVIEWOP
        NSUInteger index = [view indexOfItemID:key.itemID];
        if (index == NSNotFound)
        {
            return nil;
        }
        
        return [view ensureItemsDownloadedInRange:NSMakeRange(index, 1) withCallback:callback];
        ENDVIEWOP
    }
}

-(BOOL)addNewItem:(MHVItem *)item
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(item);
        MHVCHECK_TRUE([item isType:m_typeID]);
        
        MHVClientResult* hr = [item validate];
        MHVCHECK_TRUE(hr.isSuccess);
        
        MHVCHECK_SUCCESS([m_syncMgr putNewItem:item]);
        MHVCHECK_SUCCESS([self addKeyForItem:item]);
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)removeItemWithKey:(MHVItemKey *)key
{
    @synchronized(self)
    {
        BOOL result = FALSE;
        MHVAutoLock* lock = [m_syncMgr.changeManager newAutoLockForItemKey:key];
        if (lock)
        {
            @try
            {
                result = [m_syncMgr removeItemWithTypeID:m_typeID key:key itemLock:lock];
                if (result)
                {
                    [self removeKey:key];
                }
            }
            @finally
            {
                lock = nil;
            }
        }
        
        return result;
    }
}

-(BOOL)removeItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        MHVItemKey* key = nil;
        BEGINVIEWOP
        key = [view itemKeyAtIndex:index];
        ENDVIEWOP
        if (!key)
        {
            return FALSE;
        }
        return [self removeItemWithKey:key];
    }
}

-(MHVItemEditOperation *)openItemForEditWithKey:(MHVItemKey *)key
{
    @synchronized(self)
    {
        MHVItemEditOperation* op = nil;
        MHVAutoLock* lock = [m_syncMgr newLockForItemKey:key];
        if (lock)
        {
            @try
            {
                MHVItem* localItem = [[self beginViewOp] getLocalItemWithKey:key];
                if (localItem)
                {
                    op = [[MHVItemEditOperation alloc] initForType:self item:localItem andLock:lock];
                }
            }
            @finally
            {
                if (op == nil)
                {
                    lock = nil;
                }
                [self endViewOp];
            }
        }
        
        return op;
    }
}

-(MHVItemEditOperation *)openItemForEditAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        MHVItemKey* key = nil;
        BEGINVIEWOP
        key = [view itemKeyAtIndex:index];
        ENDVIEWOP
        
        if (!key)
        {
            return FALSE;
        }
        return [self openItemForEditWithKey:key];
    }
}

-(BOOL)putItem:(MHVItem *)item editLock:(MHVAutoLock *)lock
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(item);
        MHVCHECK_NOTNULL(lock);
        MHVCHECK_TRUE([item isType:m_typeID]);
        
        MHVCHECK_SUCCESS([m_syncMgr putItem:item itemLock:lock]);
        MHVCHECK_SUCCESS([self updateKeyForItem:item]);
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)save
{
    @synchronized(self)
    {
        return [self saveView];
    }
}

-(BOOL)removeAllLocalItems
{
    @synchronized(self)
    {
        BEGINVIEWOP
        [view removeAllLocalItems];
        return [self saveView];
        ENDVIEWOP
    }
}

-(BOOL)applyChangeCommitSuccess:(MHVItemChange *)change itemLock:(MHVAutoLock *)lock
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(change);
        MHVCHECK_SUCCESS([lock validateLock]);
        
        MHVItem* updatedItem = change.updatedItem;
        if (!updatedItem)
        {
            updatedItem = change.localItem;
            updatedItem.key = change.updatedKey;
        }
        
        MHVCHECK_NOTNULL(updatedItem);
        
        [m_syncMgr.data removeLocalItemWithKey:change.itemKey];
        
        MHVCHECK_SUCCESS([m_syncMgr.data putLocalItem:updatedItem]);
        MHVCHECK_SUCCESS([self replaceItemID:change.itemID withItem:updatedItem]);
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

+(NSString *)makeViewNameForTypeID:(NSString *)typeID
{
    return [@"SyncType_" stringByAppendingString:typeID];
}

//------------------------------------------------
//
// MHVTypeViewDelegate
// These calls arrive on the main thread
//
//------------------------------------------------
-(void) itemsAvailable:(MHVItemCollection *)items inView:(MHVTypeView *)view viewChanged:(BOOL) viewChanged
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizedType:self itemsAvailable:items typeChanged:viewChanged];
        }
        
        if (m_broadcastNotifications)
        {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            [args setObject:items forKey:@"items"];
            [args setObject:@(viewChanged) forKey:@"viewChanged"];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:MHVSynchronizedTypeItemsAvailableNotification
                object:self
                userInfo:args
            ];
            
        }
    });
}
-(void) keysNotAvailable:(NSArray *) keys inView:(MHVTypeView *) view
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizedType:self keysNotAvailable:keys];
        }
        
        if (m_broadcastNotifications)
        {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            [args setObject:keys forKey:@"keys"];

            [[NSNotificationCenter defaultCenter]
                postNotificationName:MHVSynchronizedTypeKeysNotAvailableNotification
                object:self
                userInfo:args
             ];
            
        }
});
}
-(void) synchronizationCompletedInView:(MHVTypeView *) view
{
    [self saveView];
    
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizedTypeSyncCompleted:self];
        }
      
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:MHVSynchronizedTypeSyncCompletedNotification
             object:self
             ];
        }
    });
}
-(void) synchronizationFailedInView:(MHVTypeView *) view withError:(id) ex
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizedType:self syncFailedWithError:ex];
        }
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:MHVSynchronizedTypeSyncFailedNotification
             object:self
             ];
        }
    });
}

//------------------------------------------------
//
// NSDiscardableContent
//
//------------------------------------------------
-(BOOL)beginContentAccess
{
    @synchronized(self)
    {
        return ([self beginViewOp] != nil);
    }
}

-(void)endContentAccess
{
    @synchronized(self)
    {
        [self endViewOp];
    }
}

-(void)discardContentIfPossible
{
    @synchronized(self)
    {
        if (m_accessCount == 0)
        {
            [self releaseView];
        }
    }
}

-(BOOL)isContentDiscarded
{
    @synchronized(self)
    {
        return (m_view == nil);
    }
}

-(BOOL)isContentDiscardable
{
    @synchronized(self)
    {
        return (m_accessCount == 0);
    }
}

@end


@implementation MHVSynchronizedType (MHVPrivate)

//
// MUST BE ALWAYS CALLED FROM WITHIN A LOCK
//
-(MHVTypeView *)beginViewOp
{
    if (!m_view)
    {
        [self ensureView];
    }
    
    ++m_accessCount;
    return m_view;
}

//
// MUST BE ALWAYS CALLED FROM WITHIN A LOCK
//
-(void)endViewOp
{
    if (m_accessCount > 0)
    {
        --m_accessCount;
    }
    else
    {
        MHVASSERT(m_accessCount > 0);
    }
}

-(MHVTypeView *)ensureView
{
    if (!m_view)
    {
        m_view = [self loadView];
        if (!m_view)
        {
            m_view = [[MHVTypeView alloc] initForTypeID:m_typeID overStore:m_syncMgr.store];
        }
        MHVCHECK_NOTNULL(m_view);
        
        m_view.delegate = self;
        if (m_readAheadChunkSize > 0)
        {
            m_view.readAheadChunkSize = m_readAheadChunkSize;
        }
    }
    
    return m_view;

LError:
    return nil;
}

-(MHVTypeView *)loadView
{
    return [MHVTypeView loadViewNamed:m_viewName fromStore:m_syncMgr.store];
}

-(BOOL)saveView
{
    if (m_view)
    {
        return [m_syncMgr.store putView:m_view name:m_viewName];
    }
    
    return TRUE;
}

-(void)releaseView
{
    if (m_view)
    {
        m_view.delegate = nil;
        m_view = nil;
    }
}


-(BOOL)addKeyForItem:(MHVItem *)item
{
    BEGINVIEWOP
    [view updateItemInView:item];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)updateKeyForItem:(MHVItem *)item
{
    BEGINVIEWOP
    [view updateItemInView:item];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)replaceItemID:(NSString *)itemID withItem:(MHVItem *)item
{
    BEGINVIEWOP
    [view removeItemFromViewByID:itemID];
    [view updateItemInView:item];
    
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)removeKey:(MHVItemKey *)key
{
    BEGINVIEWOP
    [view removeItemFromViewByID:key.itemID];
    return [self saveView];
    ENDVIEWOP
}

@end


@implementation MHVItemEditOperation

@synthesize item = m_item;

-(id)init
{
    return [self initForType:nil item:nil andLock:nil];
}

-(id)initForType:(MHVSynchronizedType *)type item:(MHVItem *)item andLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(type);
    MHVCHECK_NOTNULL(item);
    MHVCHECK_NOTNULL(lock);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_item = [item newDeepClone];
    MHVCHECK_NOTNULL(m_item);
    
    m_type = type;
    m_lock = lock;
    
    return self;
LError:
    MHVALLOC_FAIL;
}


-(BOOL)commit
{
    BOOL result = [m_type putItem:m_item editLock:m_lock];
    m_lock = nil;
    return result;
}

-(void)cancel
{
    m_lock = nil;
}

@end

