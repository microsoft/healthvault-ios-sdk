//
//  HVItemChangeManager.m
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
#import "HVItemChangeManager.h"
#import "HVServerResponseStatus.h"
#import "HVItem.h"
#import "HVSynchronizationManager.h"
#import "HVClient.h"

@interface HVItemChangeManager (HVPrivate)

-(HVWorkerStatus*) status;

-(BOOL) ensureChangeTable:(id<HVObjectStore>) store;

-(void) notifyStarting;
-(void) notifyFinished;
-(void) notifyCommitSuccess:(HVItemChange *) change itemLock:(HVAutoLock *) lock;
-(void) notifyCommitFailed:(HVItemChange *) change;
-(void) notifyException:(id) ex;

@end

@interface HVItemChangeQueueProcess (HVPrivate)

-(void) state_start;
-(HVTask *) state_next;
-(BOOL) state_done;

-(HVTask *) commitChange;
-(BOOL) acquireLockForChange:(HVItemChange *) change;
-(void) releaseLockForChange:(HVItemChange *) change;
-(BOOL) handleException:(id) ex shouldDequeue:(BOOL *) dequeue;
-(void) clear;

@end

@interface HVItemChangeCommit (HVPrivate)

-(void) state_start;
-(HVTask *) state_remove;
-(void) state_startNew;
-(void) state_startPut;
-(HVTask *) state_new;
-(void) state_startUpdate;
-(HVTask *) state_detectDupe:(enum HVItemChangeCommitState) state;
-(HVTask *) state_put;
-(HVTask *) state_refresh;

-(void) updateChangeAttemptCount;

@end

//-----------------------------------------------------
//
// HVItemChangeQueueProcess
//
//-----------------------------------------------------

@implementation HVItemChangeQueueProcess

@synthesize changeManager = m_mgr;
-(enum HVItemChangeQueueProcessState)currentState
{
    return (enum HVItemChangeQueueProcessState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andQueue:nil];
}

-(id)initWithChangeManager:(HVItemChangeManager *)mgr andQueue:(NSEnumerator *)queue
{
    HVCHECK_NOTNULL(mgr);
    HVCHECK_NOTNULL(queue);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_mgr, mgr);
    HVRETAIN(m_queue, queue);
    
    self.name = @"HVItemChangeQueueProcess";
    self.stateID = HVItemChangeQueueProcessStateStart;
 
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [self clear];
    
    [m_mgr release];
    [m_queue release];
    
    [super dealloc];
}

-(HVTask *)nextTask
{
    while (m_mgr.isCommitEnabled)
    {
        HVTask* nextTask = nil;
        enum HVItemChangeQueueProcessState currentState = self.stateID;
        switch (currentState)
        {
            default:
                NSLog(@"HVitemChangeQueueProcess: Unknown State %d", self.stateID);
                return nil;
                
            case HVItemChangeQueueProcessStateStart:
                [self state_start];
                break;
                
            case HVItemChangeQueueProcessStateNext:
                if ((nextTask = [self state_next]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeQueueProcessStateDone:
                if ([self state_done])
                {
                    return nil;
                }
                break;
        }
        HVCHECK_FALSE(currentState == self.stateID);  // Prevent infinite loops
    }
    
LError:
    return nil;
}

-(void) onAborted
{
    [m_mgr.status completeWork];
}

@end

@implementation HVItemChangeQueueProcess(HVPrivate)

-(void)state_start
{
    m_committedCount = 0;
    self.stateID = HVItemChangeQueueProcessStateNext;
}

-(HVTask *)state_next
{
    while (TRUE)
    {
        [self clear];
        
        if (!m_mgr.isCommitEnabled)
        {
            self.stateID = HVItemChangeQueueProcessStateDone;
            return nil;
        }
        
        HVItemChange* queuedChange = [m_queue nextObject];
        if (queuedChange == nil)
        {
            self.stateID = HVItemChangeQueueProcessStateDone;
            return nil;
        }
        
        if (![self acquireLockForChange:queuedChange])
        {
            continue;
        }
        
        HVTask* commitTask = nil;
        @try
        {
            HVItemChange* change = [m_mgr.changeTable getForTypeID:queuedChange.typeID itemID:queuedChange.itemID];
            if (change != nil)
            {
                if (m_committedCount == 0)
                {
                    [m_mgr notifyStarting];
                }
                ++m_committedCount;
                
                HVRETAIN(m_current, change);
                if ((commitTask = [self commitChange]) != nil)
                {
                    return commitTask;
                }
            }
        }
        @finally
        {
            if (commitTask == nil)
            {
                [self releaseLockForChange:queuedChange];
            }
        }
    }
}

-(BOOL)state_done
{
    [self clear];
    
    BOOL hasPendingWork = [m_mgr.status completeWork];
    if (!hasPendingWork ||
        ![m_mgr.status beginWork])
    {
        [m_mgr notifyFinished];
        return TRUE;
    }

    self.stateID = HVItemChangeQueueProcessStateStart;
    return FALSE;
}

-(HVTask *)commitChange
{
    HVCLEAR(m_commit);
    
    m_commit = [[HVItemChangeCommit alloc] initWithChangeManager:m_mgr andChange:m_current];
    HVCHECK_NOTNULL(m_commit);
    
    return [[HVTaskStateMachine newRunTaskFor:m_commit callback:^(HVTask *task) {
        BOOL shouldDequeue = FALSE;
        BOOL shouldContinue = TRUE;
        @try
        {
            [task checkSuccess];
            [m_mgr notifyCommitSuccess:m_current itemLock:m_lock];
            shouldDequeue = TRUE;
        }
        @catch (id ex)
        {
            shouldContinue = [self handleException:ex shouldDequeue:&shouldDequeue];
            [task clearError];
        }
        if (shouldContinue)
        {
            if (shouldDequeue)
            {
                [m_mgr.changeTable removeForTypeID:m_current.typeID itemID:m_current.itemID];
            }
            self.stateID = HVItemChangeQueueProcessStateNext;
        }
        else
        {
            self.stateID = HVItemChangeQueueProcessStateDone;
        }
        
        [self releaseLockForChange:m_current];
        [self clear];
    }] autorelease];
    
LError:
    return nil;
}

-(BOOL)acquireLockForChange:(HVItemChange *)change
{
    HVCLEAR(m_lock);
    m_lock = [m_mgr.locks newAutoLockForKey:change.itemID];
    return (m_lock != nil);
}

-(void)releaseLockForChange:(HVItemChange *)change
{
    HVCLEAR(m_lock);
}

-(BOOL)handleException:(id)ex shouldDequeue:(BOOL *)dequeue
{
    if ([m_mgr.errorHandler isHaltingException:ex] ||
        [m_mgr.errorHandler isServerTokenException:ex])
    {
        // Should abandon the current commit episode, since we have network or service errors. Try again later
        [m_mgr notifyException:ex];
        return FALSE;
    }
    
    if ([m_mgr.errorHandler shouldRetryChange:m_current onException:ex])
    {
        // Leave the change in the commit queue. We'll try again later
        [m_mgr notifyException:ex];
    }
    else
    {
        [m_mgr notifyCommitFailed:m_current];
        *dequeue = TRUE;
    }
    
    return TRUE;
}

-(void)clear
{
    HVCLEAR(m_lock);
    HVCLEAR(m_current);
    HVCLEAR(m_commit);
}

@end

//-----------------------------------------------------
//
// HVItemChangeCommit
//
//-----------------------------------------------------

@implementation HVItemChangeCommit

-(enum HVItemChangeCommitState)currentState
{
    return (enum HVItemChangeCommitState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andChange:nil];
}

-(id)initWithChangeManager:(HVItemChangeManager *)mgr andChange:(HVItemChange *)change
{
    HVCHECK_NOTNULL(mgr);
    HVCHECK_NOTNULL(change);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_mgr, mgr);
    HVRETAIN(m_change, change);
    HVRETAIN(m_methodFactory, [HVClient current].methodFactory);
    
    self.name = @"HVItemChangeCommit";
    self.stateID = HVItemChangeCommitStateStart;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_mgr release];
    [m_change release];
    [m_methodFactory release];
    
    [super dealloc];
}

-(HVTask *) nextTask
{
    while (TRUE)
    {
        HVTask* nextTask = nil;
        enum HVItemChangeCommitState currentState = self.stateID;
        switch (currentState)
        {
            default:
                NSLog(@"HVitemChangeCommit: Unknown State %d", self.stateID);
                break;
                
            case HVItemChangeCommitStateStart:
                [self state_start];
                break;
                
            case HVItemChangeCommitStateRemove:
                if ((nextTask = [self state_remove]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeCommitStateStartNew:
                [self state_startNew];
                break;
                
            case HVItemChangeCommitStateNew:
                if ((nextTask = [self state_new]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeCommitStateStartPut:
                [self state_startPut];
                break;
                
            case HVItemChangeCommitStateStartUpdate:
                [self state_startUpdate];
                break;
                
            case HVItemChangeCommitStateDetectDupeNew:
            case HVItemChangeCommitStateDetectDupeUpdate:
                if ((nextTask = [self state_detectDupe:currentState]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeCommitStatePut:
                if ((nextTask = [self state_put]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeCommitStateRefresh:
                if ((nextTask = [self state_refresh]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case HVItemChangeCommitStateDone:
                return nil;
        }
        HVCHECK_FALSE(currentState == self.stateID);  // Prevent infinite loops
    }
    
LError:
    return nil;
}


@end

@implementation HVItemChangeCommit (HVPrivate)

-(HVSynchronizedStore *)data
{
    return m_mgr.data;
}

-(void)state_start
{
    [self updateChangeAttemptCount];
    if (m_change.changeType == HVItemChangeTypeRemove)
    {
        self.stateID = HVItemChangeCommitStateRemove;
    }
    else
    {
        self.stateID = HVItemChangeCommitStateStartPut;
    }
}

-(HVTask *)state_remove
{
    if ([m_change.itemKey isLocal])
    {
        self.stateID = HVItemChangeQueueProcessStateDone;
        return nil;
    }
    
    HVItemKeyCollection* keys = [[[HVItemKeyCollection alloc] initWithKey:m_change.itemKey] autorelease];
    HVCHECK_NOTNULL(keys);
    
    HVMethodFactory* methods = [HVClient current].methodFactory;
    return [[methods newRemoveItemsForRecord:m_mgr.record keys:keys andCallback:^(HVTask *task) {
        @try
        {
            [task checkSuccess];
        }
        @catch (HVServerException* ex)
        {
            if (![ex.status isItemKeyNotFound])
            {
                @throw;
            }
            [task clearError];
        }
        self.stateID = HVItemChangeCommitStateDone;
    }] autorelease];
    
LError:
    return nil;
}

-(void)state_startPut
{
    m_change.localItem = [[[m_mgr.data getlocalItemWithID:m_change.itemID] newDeepClone] autorelease];
    if (m_change.localItem == nil)
    {
        self.stateID = HVItemChangeCommitStateDone;
        return;
    }
        
    if ([m_change.localItem.key isLocal])
    {
        self.stateID = HVItemChangeCommitStateStartNew;
    }
    else
    {
        self.stateID = HVItemChangeCommitStateStartUpdate;
    }
}

-(void)state_startNew
{
    self.stateID = HVItemChangeCommitStateDetectDupeNew;
}

-(HVTask *)state_new
{
    HVItemCollection* items = [[[HVItemCollection alloc] initwithItem:m_change.localItem] autorelease];
    HVCHECK_NOTNULL(items);
   
    [items prepareForNew];
    
    HVMethodFactory* methods = [HVClient current].methodFactory;
    return [[methods newPutItemsForRecord:m_mgr.record items:items andCallback:^(HVTask *task) {
        
        m_change.updatedKey = ((HVPutItemsTask *) task).firstKey;
        
        self.stateID = HVItemChangeCommitStateRefresh;
        
    }] autorelease];
    
LError:
    return nil;
}

-(void)state_startUpdate
{
    self.stateID = HVItemChangeCommitStateDetectDupeUpdate;
}

//
// Make a best effort to avoid pushing duplicates into the system. Example scenario:
// -Item pushed into HV but phone turned off before local tables could be updated
// - Many others
//
-(HVTask *)state_detectDupe:(enum HVItemChangeCommitState)state
{
    if (m_change.attemptCount <= 1)
    {
        self.stateID = (state == HVItemChangeCommitStateDetectDupeUpdate) ? HVItemChangeCommitStatePut : HVItemChangeCommitStateNew;
        return nil;
    }
  
    HVItemQuery* query = [[[HVItemQuery alloc] initWithClientID:m_change.changeID andType:m_change.typeID] autorelease];
    HVCHECK_NOTNULL(query);
    query.maxResults = 1;
    
    HVMethodFactory* methods = [HVClient current].methodFactory;
    return [[methods newGetItemsForRecord:m_mgr.record query:query andCallback:^(HVTask *task) {
        
        HVItem* existingItem = ((HVGetItemsTask *) task).firstItemRetrieved;
        if (existingItem == nil)
        {
            // Did not commit this change yet
            self.stateID = (state == HVItemChangeCommitStateDetectDupeUpdate) ? HVItemChangeCommitStatePut : HVItemChangeCommitStateNew;
        }
        else
        {
            // Already applied this change.
            m_change.updatedKey = existingItem.key;
            m_change.updatedItem = existingItem;
            self.stateID = HVItemChangeCommitStateDone;
        }
        
    }] autorelease];
    
LError:
    return nil;
}

-(HVTask *)state_put
{
    HVItemCollection* items = [[[HVItemCollection alloc] initwithItem:m_change.localItem] autorelease];
    HVCHECK_NOTNULL(items);
    
    HVMethodFactory* methods = [HVClient current].methodFactory;
    return [[methods newPutItemsForRecord:m_mgr.record items:items andCallback:^(HVTask *task) {
        @try
        {
            m_change.updatedKey = ((HVPutItemsTask *) task).firstKey;
            self.stateID = HVItemChangeCommitStateRefresh;
        }
        @catch (id ex)
        {
            if (![m_mgr.errorHandler shouldCreateNewItemForConflict:m_change onException:ex])
            {
                @throw;
            }
            [task clearError];
            self.stateID = HVItemChangeCommitStateNew;
        }
        
    }] autorelease];

LError:
    return nil;
}

-(HVTask *)state_refresh
{
    m_change.updatedItem = nil;
    
    HVItemQuery* query = [[[HVItemQuery alloc] initWithItemKey:m_change.updatedKey andType:m_change.typeID] autorelease];
    HVCHECK_NOTNULL(query);
    
    HVMethodFactory* methods = [HVClient current].methodFactory;
    return [[methods newGetItemsForRecord:m_mgr.record query:query andCallback:^(HVTask *task) {
        @try
        {
            m_change.updatedItem = ((HVGetItemsTask *) task).firstItemRetrieved;
        }
        @catch (id ex)
        {
            [m_mgr notifyException:ex];
            [task clearError];
        }
        
        self.stateID = HVItemChangeCommitStateDone;
        
    }] autorelease];
    
LError:
    return nil;
}

-(void)updateChangeAttemptCount
{
    m_change.attemptCount = m_change.attemptCount + 1;
    [m_mgr.changeTable put:m_change];
}

@end

//-----------------------------------------------------
//
// HVItemChangeManager
//
//-----------------------------------------------------
HVDEFINE_NOTIFICATION(HVItemChangeManagerStartingCommitNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerFinishedCommitNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerChangeCommitSuccessNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerChangeCommitFailedNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerExceptionNotification);

@implementation HVItemChangeManager

@synthesize syncMgr = m_syncMgr;
@synthesize record = m_record;
@synthesize data = m_data;
@synthesize changeTable = m_changeTable;
@synthesize locks = m_lockTable;

-(HVItemCommitErrorHandler *)errorHandler
{
    return m_errorHandler;
}
-(void)setErrorHandler:(HVItemCommitErrorHandler *)errorHandler
{
    if (errorHandler)
    {
        HVRETAIN(m_errorHandler, errorHandler);
    }
}

-(BOOL)isCommitEnabled
{
    return m_status.isEnabled;
}
-(void)setIsCommitEnabled:(BOOL)isCommitEnabled
{
    m_status.isEnabled = isCommitEnabled;
}

-(BOOL)isBusy
{
    return m_status.isBusy;
}

@synthesize isBroadcastingNotifications = m_broadcastNotifications;

-(id)init
{
    return [self initOverStore:nil forRecord:nil andData:nil];
}

-(id)initOverStore:(id<HVObjectStore>)store forRecord:(HVRecordReference *)record andData:(HVSynchronizedStore *)data
{
    HVCHECK_NOTNULL(store);
    HVCHECK_NOTNULL(record);
    HVCHECK_NOTNULL(data);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_record, record);
    HVRETAIN(m_data, data);

    HVCHECK_SUCCESS([self ensureChangeTable:store]);
    
    m_lockTable = [[HVLockTable alloc] init];
    HVCHECK_NOTNULL(m_lockTable);

    m_status = [[HVWorkerStatus alloc] init];
    HVCHECK_NOTNULL(m_status);
    
    m_errorHandler = [[HVItemCommitErrorHandler alloc] init];
    HVCHECK_NOTNULL(m_errorHandler);
    
    m_broadcastNotifications = TRUE;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_record release];
    [m_data release];
    [m_changeTable release];
    [m_lockTable release];
    [m_errorHandler release];
    [m_status release];
   
    [super dealloc];
}

-(BOOL)hasPendingChanges
{
    return [m_changeTable hasChanges];
}

-(BOOL)hasChangesForItem:(HVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    return [m_changeTable hasChangesForTypeID:item.typeID itemID:item.itemID];
    
LError:
    return FALSE;
}

-(BOOL)hasChangesForTypeID:(NSString *)typeID
{
    return [m_changeTable hasChangesForTypeID:typeID];
}

-(BOOL)trackPut:(HVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    NSString* changeID = [self trackPutForTypeID:item.typeID andItemKey:item.key];
    HVCHECK_NOTNULL(changeID);
    
    item.data.common.clientIDValue = changeID;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)trackPutForTypeID:(NSString *)typeID andItemKey:(HVItemKey *)key
{
    return [m_changeTable trackChange:HVItemChangeTypePut forTypeID:typeID andKey:key];
}

-(BOOL)trackRemoveForTypeID:(NSString *)typeID andItemKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    if ([key isLocal])
    {
        return [m_changeTable removeForTypeID:typeID itemID:key.itemID];
    }
    
    NSString* changeID = [m_changeTable trackChange:HVItemChangeTypeRemove forTypeID:typeID andKey:key];
    return (changeID != nil);
    
LError:
    return FALSE;
}

-(HVTask *)commitChangesWithCallback:(HVTaskCompletion)callback
{
    HVTask* commitTask = [[self newCommitChangesTaskWithCallback:callback] autorelease];
    if (commitTask)
    {
        [commitTask start];
    }
    return commitTask;
}

-(HVTask *)newCommitChangesTaskWithCallback:(HVTaskCompletion)callback
{
    if (![m_status beginWork])
    {
        // Already working
        return nil;
    }
    
    HVItemChangeQueue* queue = [m_changeTable getQueue];
    
    HVItemChangeQueueProcess* queueProcessor = [[[HVItemChangeQueueProcess alloc] initWithChangeManager:self andQueue:queue] autorelease];
    HVCHECK_NOTNULL(queueProcessor);
    
    HVTask* task = [HVTaskStateMachine newRunTaskFor:queueProcessor callback:callback];
    task.taskName = @"QueueProcessorStateMachine";
    
    HVCHECK_NOTNULL(task);
    
    return task;
    
LError:
    [m_status completeWork];
    return nil;
}

-(HVAutoLock *)newAutoLockForItemKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    return [m_lockTable newAutoLockForKey:key.itemID];

LError:
    return nil;
}

-(long)acquireLockForItemID:(NSString *)itemID
{
    return [m_lockTable acquireLockForKey:itemID];
}

-(void)releaseLock:(long)lockID forItemID:(NSString *)itemID
{
    [m_lockTable releaseLock:lockID forKey:itemID];
}

+(NSString *)changeStoreKey
{
    return @"Changes";
}

@end

@implementation HVItemChangeManager (HVPrivate)

-(HVWorkerStatus *)status
{
    return m_status;
}

-(BOOL)ensureChangeTable:(id<HVObjectStore>)store
{
    id<HVObjectStore> changeStore = [store newChildStore:[HVItemChangeManager changeStoreKey]];
    HVCHECK_NOTNULL(changeStore);
    
    m_changeTable = [[HVItemChangeTable alloc] initWithObjectStore:changeStore];
    [changeStore release];
    
    HVCHECK_NOTNULL(m_changeTable);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)notifyStarting
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVItemChangeManagerStartingCommitNotification
             object:self
             ];
        }
    });
}

-(void)notifyFinished
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVItemChangeManagerFinishedCommitNotification
             object:self
             ];
        }
    });
}

-(void)notifyCommitSuccess:(HVItemChange *)change itemLock:(HVAutoLock *)lock
{
    @try
    {
        if (m_syncMgr)
        {
            [m_syncMgr applyChangeCommitSuccess:change itemLock:lock];
        }
    }
    @catch (id ex)
    {
    }
    
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVItemChangeManagerChangeCommitSuccessNotification
             sender:self
             argName:@"itemChange"
             argValue:change
            ];
        }
    });
}

-(void)notifyCommitFailed:(HVItemChange *)change
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVItemChangeManagerChangeCommitFailedNotification
             sender:self
             argName:@"itemChange"
             argValue:change
             ];
        }
    });
}

-(void)notifyException:(id)ex   
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:HVItemChangeManagerExceptionNotification
             sender:self
             argName:@"exception"
             argValue:ex
             ];
        }
    });
}

@end


