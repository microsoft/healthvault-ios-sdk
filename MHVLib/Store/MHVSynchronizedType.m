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

MHVDEFINE_NOTIFICATION(MHVSynchronizedTypeThingsAvailableNotification);
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

-(BOOL) addKeyForThing:(MHVThing *) thing;
-(BOOL) updateKeyForThing:(MHVThing *) thing;
-(BOOL) replaceThingID:(NSString *) thingID withThing:(MHVThing *) thing;
-(BOOL) removeKey:(MHVThingKey *) key;

@end

@interface MHVThingEditOperation (MHVPrivate)

-(id) initForType:(MHVSynchronizedType *) type thing:(MHVThing *) thing andLock:(MHVAutoLock *) lock;

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

-(NSInteger)maxThings
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return view.maxThings;
        ENDVIEWOP
    }
}

-(void)setMaxThings:(NSInteger)maxThings
{
    @synchronized(self)
    {
        BEGINVIEWOP
        view.maxThings = maxThings;
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

-(MHVThingKey *)keyAtIndex:(NSUInteger)index
{
    return [self thingKeyAtIndex:index];
}

-(MHVTypeViewThing *)thingKeyAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view thingKeyAtIndex:index];
        ENDVIEWOP
    }
}

-(NSUInteger)indexOfThingID:(NSString *)thingID
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view indexOfThingID:thingID];
        ENDVIEWOP
    }
}

-(MHVThing *)getThingAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getThingAtIndex:index];
        ENDVIEWOP
    }
}

-(MHVThing *)getThingByID:(NSString *)thingID
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getThingByID:thingID];
        ENDVIEWOP
    }
}

-(MHVThingCollection *)getThingsInRange:(NSRange)range
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getThingsInRange:range];
        ENDVIEWOP
    }
}

-(MHVThing *)getLocalThingAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getLocalThingAtIndex:index];
        ENDVIEWOP
    }
}

-(MHVThing *)getLocalThingWithKey:(MHVThingKey *)key
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getLocalThingWithKey:key];
        ENDVIEWOP
    }
}

-(MHVThingKeyCollection *)keysOfThingsNeedingDownloadInRange:(NSRange)range
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view keysOfThingsNeedingDownloadInRange:range];
        ENDVIEWOP
    }
}

-(MHVTask *)ensureThingsDownloadedInRange:(NSRange)range withCallback:(MHVTaskCompletion)callback
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view ensureThingsDownloadedInRange:range withCallback:callback];
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

-(MHVThingQuery *)getQuery
{
    @synchronized(self)
    {
        BEGINVIEWOP
        return [view getQuery];
        ENDVIEWOP
    }
}

-(BOOL)replaceKeys:(MHVTypeViewThings *)things
{
    @synchronized(self)
    {
        BOOL success = FALSE;
        
        BEGINVIEWOP
        success = [view replaceKeys:things];
        ENDVIEWOP
        
        if (success)
        {
            [self synchronizationCompletedInView:nil];
        }
    }
}

-(MHVTask *)ensureThingDownloadedForKey:(MHVThingKey *)key withCallback:(MHVTaskCompletion)callback
{
    @synchronized(self)
    {
        BEGINVIEWOP
        NSUInteger index = [view indexOfThingID:key.thingID];
        if (index == NSNotFound)
        {
            return nil;
        }
        
        return [view ensureThingsDownloadedInRange:NSMakeRange(index, 1) withCallback:callback];
        ENDVIEWOP
    }
}

-(BOOL)addNewThing:(MHVThing *)thing
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(thing);
        MHVCHECK_TRUE([thing isType:m_typeID]);
        
        MHVClientResult* hr = [thing validate];
        MHVCHECK_TRUE(hr.isSuccess);
        
        MHVCHECK_SUCCESS([m_syncMgr putNewThing:thing]);
        MHVCHECK_SUCCESS([self addKeyForThing:thing]);
        
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(BOOL)removeThingWithKey:(MHVThingKey *)key
{
    @synchronized(self)
    {
        BOOL result = FALSE;
        MHVAutoLock* lock = [m_syncMgr.changeManager newAutoLockForThingKey:key];
        if (lock)
        {
            @try
            {
                result = [m_syncMgr removeThingWithTypeID:m_typeID key:key thingLock:lock];
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

-(BOOL)removeThingAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        MHVThingKey* key = nil;
        BEGINVIEWOP
        key = [view thingKeyAtIndex:index];
        ENDVIEWOP
        if (!key)
        {
            return FALSE;
        }
        return [self removeThingWithKey:key];
    }
}

-(MHVThingEditOperation *)openThingForEditWithKey:(MHVThingKey *)key
{
    @synchronized(self)
    {
        MHVThingEditOperation* op = nil;
        MHVAutoLock* lock = [m_syncMgr newLockForThingKey:key];
        if (lock)
        {
            @try
            {
                MHVThing* localThing = [[self beginViewOp] getLocalThingWithKey:key];
                if (localThing)
                {
                    op = [[MHVThingEditOperation alloc] initForType:self thing:localThing andLock:lock];
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

-(MHVThingEditOperation *)openThingForEditAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        MHVThingKey* key = nil;
        BEGINVIEWOP
        key = [view thingKeyAtIndex:index];
        ENDVIEWOP
        
        if (!key)
        {
            return FALSE;
        }
        return [self openThingForEditWithKey:key];
    }
}

-(BOOL)putThing:(MHVThing *)thing editLock:(MHVAutoLock *)lock
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(thing);
        MHVCHECK_NOTNULL(lock);
        MHVCHECK_TRUE([thing isType:m_typeID]);
        
        MHVCHECK_SUCCESS([m_syncMgr putThing:thing thingLock:lock]);
        MHVCHECK_SUCCESS([self updateKeyForThing:thing]);
        
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

-(BOOL)removeAllLocalThings
{
    @synchronized(self)
    {
        BEGINVIEWOP
        [view removeAllLocalThings];
        return [self saveView];
        ENDVIEWOP
    }
}

-(BOOL)applyChangeCommitSuccess:(MHVThingChange *)change thingLock:(MHVAutoLock *)lock
{
    @synchronized(self)
    {
        MHVCHECK_NOTNULL(change);
        MHVCHECK_SUCCESS([lock validateLock]);
        
        MHVThing* updatedThing = change.updatedThing;
        if (!updatedThing)
        {
            updatedThing = change.localThing;
            updatedThing.key = change.updatedKey;
        }
        
        MHVCHECK_NOTNULL(updatedThing);
        
        [m_syncMgr.data removeLocalThingWithKey:change.thingKey];
        
        MHVCHECK_SUCCESS([m_syncMgr.data putLocalThing:updatedThing]);
        MHVCHECK_SUCCESS([self replaceThingID:change.thingID withThing:updatedThing]);
        
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
-(void) thingsAvailable:(MHVThingCollection *)things inView:(MHVTypeView *)view viewChanged:(BOOL) viewChanged
{
    safeInvokeAction(^{
        if (self.delegate)
        {
            [self.delegate synchronizedType:self thingsAvailable:things typeChanged:viewChanged];
        }
        
        if (m_broadcastNotifications)
        {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            [args setObject:things forKey:@"things"];
            [args setObject:@(viewChanged) forKey:@"viewChanged"];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:MHVSynchronizedTypeThingsAvailableNotification
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


-(BOOL)addKeyForThing:(MHVThing *)thing
{
    BEGINVIEWOP
    [view updateThingInView:thing];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)updateKeyForThing:(MHVThing *)thing
{
    BEGINVIEWOP
    [view updateThingInView:thing];
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)replaceThingID:(NSString *)thingID withThing:(MHVThing *)thing
{
    BEGINVIEWOP
    [view removeThingFromViewByID:thingID];
    [view updateThingInView:thing];
    
    return [self saveView];
    ENDVIEWOP
}

-(BOOL)removeKey:(MHVThingKey *)key
{
    BEGINVIEWOP
    [view removeThingFromViewByID:key.thingID];
    return [self saveView];
    ENDVIEWOP
}

@end


@implementation MHVThingEditOperation

@synthesize thing = m_thing;

-(id)init
{
    return [self initForType:nil thing:nil andLock:nil];
}

-(id)initForType:(MHVSynchronizedType *)type thing:(MHVThing *)thing andLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(type);
    MHVCHECK_NOTNULL(thing);
    MHVCHECK_NOTNULL(lock);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_thing = [thing newDeepClone];
    MHVCHECK_NOTNULL(m_thing);
    
    m_type = type;
    m_lock = lock;
    
    return self;
LError:
    MHVALLOC_FAIL;
}


-(BOOL)commit
{
    BOOL result = [m_type putThing:m_thing editLock:m_lock];
    m_lock = nil;
    return result;
}

-(void)cancel
{
    m_lock = nil;
}

@end

