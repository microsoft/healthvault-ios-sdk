//
//  HVSynchronizedType.m
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
#import "HVSynchronizedType.h"

#define BEGINVIEWOP \
    @try { \
        HVTypeView* view = [self beginViewOp]; \

#define ENDVIEWOP \
    } \
    @finally { \
        [self endViewOp]; \
    }

HVDEFINE_NOTIFICATION(HVSynchronizedTypeItemsAvailableNotification);
HVDEFINE_NOTIFICATION(HVSynchronizedTypeKeysNotAvailableNotification);
HVDEFINE_NOTIFICATION(HVSynchronizedTypeSyncCompletedNotification);
HVDEFINE_NOTIFICATION(HVSynchronizedTypeSyncFailedNotification);

@interface HVSynchronizedType (HVPrivate)

-(HVTypeView *) beginViewOp;
-(void) endViewOp;

-(HVTypeView *) ensureView;
-(HVTypeView *) loadView;
-(void) releaseView;
-(BOOL) saveView;

-(BOOL) addKeyForItem:(HVItem *) item;
-(BOOL) updateKeyForItem:(HVItem *) item;
-(BOOL) replaceItemID:(NSString *) itemID withItem:(HVItem *) item;
-(BOOL) removeKey:(HVItemKey *) key;

@end

@interface HVItemEditOperation (HVPrivate)

-(id) initForType:(HVSynchronizedType *) type item:(HVItem *) item andLock:(HVAutoLock *) lock;

@end

@implementation HVSynchronizedType

-(HVSynchronizationManager *)syncMgr
{
    @synchronized(self)
    {
        return m_syncMgr;
    }
}

-(void)setSyncMgr:(HVSynchronizationManager *)syncMgr
{
    @synchronized(self)
    {
        [self releaseView];
        if (syncMgr)
        {
            HVRETAIN(m_syncMgr, syncMgr);
        }
        else
        {
            HVCLEAR(m_syncMgr);
        }
    }
}

@synthesize delegate = m_delegate;

-(BOOL)isLoaded
{
    return (![self isContentDiscarded]);
}

-(NSString *)typeID
{
    return m_typeID;
}

-(HVRecordReference *)record
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


-(id)initForTypeID:(NSString *)typeID withMgr:(HVSynchronizationManager *)syncMgr
{
    HVCHECK_STRING(typeID);
    HVCHECK_NOTNULL(syncMgr);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_typeID, typeID);
    HVRETAIN(m_viewName, [HVSynchronizedType makeViewNameForTypeID:typeID]);
    
    self.syncMgr = syncMgr;
    
    m_readAheadChunkSize = c_hvTypeViewDefaultReadAheadChunkSize;
    m_broadcastNotifications = TRUE;
    m_accessCount = 1; // As per NSDiscardableContent docs
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_typeID release];
    [m_viewName release];
    [m_syncMgr release];
    
    [self releaseView];
    
    [super dealloc];
}

-(BOOL)hasPendingChanges
{
    @synchronized(self)
    {
        return [m_syncMgr.changeManager hasChangesForTypeID:m_typeID];
    }
}

-(HVItemKey *)keyAtIndex:(NSUInteger)index
{
    return [self itemKeyAtIndex:index];
}

-(HVTypeViewItem *)itemKeyAtIndex:(NSUInteger)index
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

-(HVItem *)getItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemAtIndex:index];
        ENDVIEWOP
    }
}

-(HVItem *)getItemByID:(NSString *)itemID
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemByID:itemID];
        ENDVIEWOP
    }
}

-(HVItemCollection *)getItemsInRange:(NSRange)range
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getItemsInRange:range];
        ENDVIEWOP
    }
}

-(HVItem *)getLocalItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getLocalItemAtIndex:index];
        ENDVIEWOP
    }
}

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
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

-(HVTask *)ensureItemsDownloadedInRange:(NSRange)range withCallback:(HVTaskCompletion)callback
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

-(HVTask *)refresh
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

-(HVTask *)refreshWithCallback:(HVTaskCompletion)callback
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

-(HVItemQuery *)getQuery
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getQuery];
        ENDVIEWOP
    }
}

-(BOOL)replaceKeys:(HVTypeViewItems *)items
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

-(HVTask *)ensureItemDownloadedForKey:(HVItemKey *)key withCallback:(HVTaskCompletion)callback
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

-(BOOL)addNewItem:(HVItem *)item
{
    @synchronized(self)
    {
        HVCHECK_NOTNULL(item);
        HVCHECK_TRUE([item isType:m_typeID]);
        
        HVClientResult* hr = [item validate];
        HVCHECK_TRUE(hr.isSuccess);
        
        HVCHECK_SUCCESS([m_syncMgr putNewItem:item]);
        HVCHECK_SUCCESS([self addKeyForItem:item]);
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)removeItemWithKey:(HVItemKey *)key
{
    @synchronized(self)
    {
        BOOL result = FALSE;
        HVAutoLock* lock = [m_syncMgr.changeManager newAutoLockForItemKey:key];
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
                [lock release];
            }
        }
        
        return result;
    }
}

-(BOOL)removeItemAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        HVItemKey* key = nil;
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

-(HVItemEditOperation *)openItemForEditWithKey:(HVItemKey *)key
{
    @synchronized(self)
    {
        HVItemEditOperation* op = nil;
        HVAutoLock* lock = [m_syncMgr newLockForItemKey:key];
        if (lock)
        {
            @try
            {
                HVItem* localItem = [[self beginViewOp] getLocalItemWithKey:key];
                if (localItem)
                {
                    op = [[[HVItemEditOperation alloc] initForType:self item:localItem andLock:lock] autorelease];
                    if (op)
                    {
                        [lock release];
                    }
                }
            }
            @finally
            {
                if (op == nil)
                {
                    [lock release];
                }
                [self endViewOp];
            }
        }
        
        return op;
    }
}

-(HVItemEditOperation *)openItemForEditAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        HVItemKey* key = nil;
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

-(BOOL)putItem:(HVItem *)item editLock:(HVAutoLock *)lock
{
    @synchronized(self)
    {
        HVCHECK_NOTNULL(item);
        HVCHECK_NOTNULL(lock);
        HVCHECK_TRUE([item isType:m_typeID]);
        
        HVCHECK_SUCCESS([m_syncMgr putItem:item itemLock:lock]);
        HVCHECK_SUCCESS([self updateKeyForItem:item]);
        
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

-(BOOL)applyChangeCommitSuccess:(HVItemChange *)change itemLock:(HVAutoLock *)lock
{
    @synchronized(self)
    {
        HVCHECK_NOTNULL(change);
        HVCHECK_SUCCESS([lock validateLock]);
        
        HVItem* updatedItem = change.updatedItem;
        if (!updatedItem)
        {
            updatedItem = change.localItem;
            updatedItem.key = change.updatedKey;
        }
        
        HVCHECK_NOTNULL(updatedItem);
        
        [m_syncMgr.data removeLocalItemWithKey:change.itemKey];
        
        HVCHECK_SUCCESS([m_syncMgr.data putLocalItem:updatedItem]);
        HVCHECK_SUCCESS([self replaceItemID:change.itemID withItem:updatedItem]);
        
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
// HVTypeViewDelegate
// These calls arrive on the main thread
//
//------------------------------------------------
-(void) itemsAvailable:(HVItemCollection *)items inView:(HVTypeView *)view viewChanged:(BOOL) viewChanged
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate synchronizedType:self itemsAvailable:items typeChanged:viewChanged];
        }
        
        if (m_broadcastNotifications)
        {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            [args setObject:items forKey:@"items"];
            [args setBoolValue:viewChanged forKey:@"viewChanged"];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:HVSynchronizedTypeItemsAvailableNotification
                object:self
                userInfo:args
            ];
            
            [args release];
        }
    });
}
-(void) keysNotAvailable:(NSArray *) keys inView:(HVTypeView *) view
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate synchronizedType:self keysNotAvailable:keys];
        }
        
        if (m_broadcastNotifications)
        {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            [args setObject:keys forKey:@"keys"];

            [[NSNotificationCenter defaultCenter]
                postNotificationName:HVSynchronizedTypeKeysNotAvailableNotification
                object:self
                userInfo:args
             ];
            
            [args release];
        }
});
}
-(void) synchronizationCompletedInView:(HVTypeView *) view
{
    [self saveView];
    
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate synchronizedTypeSyncCompleted:self];
        }
      
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVSynchronizedTypeSyncCompletedNotification
             object:self
             ];
        }
    });
}
-(void) synchronizationFailedInView:(HVTypeView *) view withError:(id) ex
{
    safeInvokeAction(^{
        if (m_delegate)
        {
            [m_delegate synchronizedType:self syncFailedWithError:ex];
        }
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVSynchronizedTypeSyncFailedNotification
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


@implementation HVSynchronizedType (HVPrivate)

//
// MUST BE ALWAYS CALLED FROM WITHIN A LOCK
//
-(HVTypeView *)beginViewOp
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
        HVASSERT(m_accessCount > 0);
    }
}

-(HVTypeView *)ensureView
{
    if (!m_view)
    {
        HVRETAIN(m_view, [self loadView]);
        if (!m_view)
        {
            m_view = [[HVTypeView alloc] initForTypeID:m_typeID overStore:m_syncMgr.store];
        }
        HVCHECK_NOTNULL(m_view);
        
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

-(HVTypeView *)loadView
{
    return [HVTypeView loadViewNamed:m_viewName fromStore:m_syncMgr.store];
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
        HVCLEAR(m_view);
    }
}


-(BOOL)addKeyForItem:(HVItem *)item
{
    BEGINVIEWOP
    [view updateItemInView:item];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)updateKeyForItem:(HVItem *)item
{
    BEGINVIEWOP
    [view updateItemInView:item];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)replaceItemID:(NSString *)itemID withItem:(HVItem *)item
{
    BEGINVIEWOP
    [view removeItemFromViewByID:itemID];
    [view updateItemInView:item];
    
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)removeKey:(HVItemKey *)key
{
    BEGINVIEWOP
    [view removeItemFromViewByID:key.itemID];
    return [self saveView];
    ENDVIEWOP
}

@end


@implementation HVItemEditOperation

@synthesize item = m_item;

-(id)init
{
    return [self initForType:nil item:nil andLock:nil];
}

-(id)initForType:(HVSynchronizedType *)type item:(HVItem *)item andLock:(HVAutoLock *)lock
{
    HVCHECK_NOTNULL(type);
    HVCHECK_NOTNULL(item);
    HVCHECK_NOTNULL(lock);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_item = [item newDeepClone];
    HVCHECK_NOTNULL(m_item);
    
    HVRETAIN(m_type, type);
    HVRETAIN(m_lock, lock);
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_item release];
    [m_type release];
    [m_lock release];
    
    [super dealloc];
}

-(BOOL)commit
{
    BOOL result = [m_type putItem:m_item editLock:m_lock];
    HVCLEAR(m_lock);
    return result;
}

-(void)cancel
{
    HVCLEAR(m_lock);
}

@end

