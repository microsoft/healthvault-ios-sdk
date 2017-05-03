//
//  MHVItemChangeManager.m
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
#import "MHVItemChangeManager.h"
#import "MHVServerResponseStatus.h"
#import "MHVItem.h"
#import "MHVSynchronizationManager.h"
#import "MHVClient.h"

@interface MHVItemChangeManager (HVPrivate)

-(MHVWorkerStatus*) status;

-(BOOL) ensureChangeTable:(id<MHVObjectStore>) store;

-(void) notifyStarting;
-(void) notifyFinished;
-(void) notifyCommitSuccess:(MHVItemChange *) change itemLock:(MHVAutoLock *) lock;
-(void) notifyCommitFailed:(MHVItemChange *) change;
-(void) notifyException:(id) ex;

@end

@interface MHVItemChangeQueueProcess (HVPrivate)

-(void) state_start;
-(MHVTask *) state_next;
-(BOOL) state_done;

-(MHVTask *) commitChange;
-(BOOL) acquireLockForChange:(MHVItemChange *) change;
-(void) releaseLockForChange:(MHVItemChange *) change;
-(BOOL) handleException:(id) ex shouldDequeue:(BOOL *) dequeue;
-(void) clear;

@end

@interface MHVItemChangeCommit (HVPrivate)

-(void) state_start;
-(MHVTask *) state_remove;
-(void) state_startNew;
-(void) state_startPut;
-(MHVTask *) state_new;
-(void) state_startUpdate;
-(MHVTask *) state_detectDupe:(enum HVItemChangeCommitState) state;
-(MHVTask *) state_put;
-(MHVTask *) state_refresh;

-(void) updateChangeAttemptCount;

@end

//-----------------------------------------------------
//
// MHVItemChangeQueueProcess
//
//-----------------------------------------------------

@implementation MHVItemChangeQueueProcess

@synthesize changeManager = m_mgr;
-(enum HVItemChangeQueueProcessState)currentState
{
    return (enum HVItemChangeQueueProcessState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andQueue:nil];
}

-(id)initWithChangeManager:(MHVItemChangeManager *)mgr andQueue:(NSEnumerator *)queue
{
    HVCHECK_NOTNULL(mgr);
    HVCHECK_NOTNULL(queue);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_mgr = mgr;
    m_queue = queue;
    
    self.name = @"MHVItemChangeQueueProcess";
    self.stateID = HVItemChangeQueueProcessStateStart;
 
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [self clear];
    
    
}

-(MHVTask *)nextTask
{
    while (m_mgr.isCommitEnabled)
    {
        MHVTask* nextTask = nil;
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

@implementation MHVItemChangeQueueProcess(HVPrivate)

-(void)state_start
{
    m_committedCount = 0;
    self.stateID = HVItemChangeQueueProcessStateNext;
}

-(MHVTask *)state_next
{
    while (TRUE)
    {
        [self clear];
        
        if (!m_mgr.isCommitEnabled)
        {
            self.stateID = HVItemChangeQueueProcessStateDone;
            return nil;
        }
        
        MHVItemChange* queuedChange = [m_queue nextObject];
        if (queuedChange == nil)
        {
            self.stateID = HVItemChangeQueueProcessStateDone;
            return nil;
        }
        
        if (![self acquireLockForChange:queuedChange])
        {
            continue;
        }
        
        MHVTask* commitTask = nil;
        @try
        {
            MHVItemChange* change = [m_mgr.changeTable getForTypeID:queuedChange.typeID itemID:queuedChange.itemID];
            if (change != nil)
            {
                if (m_committedCount == 0)
                {
                    [m_mgr notifyStarting];
                }
                ++m_committedCount;
                
                m_current = change;
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

-(MHVTask *)commitChange
{
    m_commit = nil;
    
    m_commit = [[MHVItemChangeCommit alloc] initWithChangeManager:m_mgr andChange:m_current];
    HVCHECK_NOTNULL(m_commit);
    
    return [MHVTaskStateMachine newRunTaskFor:m_commit callback:^(MHVTask *task) {
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
    }];
    
LError:
    return nil;
}

-(BOOL)acquireLockForChange:(MHVItemChange *)change
{
    m_lock = nil;
    m_lock = [m_mgr.locks newAutoLockForKey:change.itemID];
    return (m_lock != nil);
}

-(void)releaseLockForChange:(MHVItemChange *)change
{
    m_lock = nil;
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
    m_lock = nil;
    m_current = nil;
    m_commit = nil;
}

@end

//-----------------------------------------------------
//
// MHVItemChangeCommit
//
//-----------------------------------------------------

@implementation MHVItemChangeCommit

-(enum HVItemChangeCommitState)currentState
{
    return (enum HVItemChangeCommitState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andChange:nil];
}

-(id)initWithChangeManager:(MHVItemChangeManager *)mgr andChange:(MHVItemChange *)change
{
    HVCHECK_NOTNULL(mgr);
    HVCHECK_NOTNULL(change);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_mgr = mgr;
    m_change = change;
    m_methodFactory = [MHVClient current].methodFactory;
    
    self.name = @"MHVItemChangeCommit";
    self.stateID = HVItemChangeCommitStateStart;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(MHVTask *) nextTask
{
    while (TRUE)
    {
        MHVTask* nextTask = nil;
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

@implementation MHVItemChangeCommit (HVPrivate)

-(MHVSynchronizedStore *)data
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

-(MHVTask *)state_remove
{
    if ([m_change.itemKey isLocal])
    {
        self.stateID = HVItemChangeQueueProcessStateDone;
        return nil;
    }
    
    MHVItemKeyCollection* keys = [[MHVItemKeyCollection alloc] initWithKey:m_change.itemKey];
    HVCHECK_NOTNULL(keys);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newRemoveItemsForRecord:m_mgr.record keys:keys andCallback:^(MHVTask *task) {
        @try
        {
            [task checkSuccess];
        }
        @catch (MHVServerException* ex)
        {
            if (![ex.status isItemKeyNotFound])
            {
                @throw;
            }
            [task clearError];
        }
        self.stateID = HVItemChangeCommitStateDone;
    }];
    
LError:
    return nil;
}

-(void)state_startPut
{
    m_change.localItem = [[m_mgr.data getlocalItemWithID:m_change.itemID] newDeepClone];
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

-(MHVTask *)state_new
{
    MHVItemCollection* items = [[MHVItemCollection alloc] initWithItem:m_change.localItem];
    HVCHECK_NOTNULL(items);
   
    [items prepareForNew];
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newPutItemsForRecord:m_mgr.record items:items andCallback:^(MHVTask *task) {
        
        m_change.updatedKey = ((MHVPutItemsTask *) task).firstKey;
        
        self.stateID = HVItemChangeCommitStateRefresh;
        
    }];
    
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
-(MHVTask *)state_detectDupe:(enum HVItemChangeCommitState)state
{
    if (m_change.attemptCount <= 1)
    {
        self.stateID = (state == HVItemChangeCommitStateDetectDupeUpdate) ? HVItemChangeCommitStatePut : HVItemChangeCommitStateNew;
        return nil;
    }
  
    MHVItemQuery* query = [[MHVItemQuery alloc] initWithClientID:m_change.changeID andType:m_change.typeID];
    HVCHECK_NOTNULL(query);
    query.maxResults = 1;
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newGetItemsForRecord:m_mgr.record query:query andCallback:^(MHVTask *task) {
        
        MHVItem* existingItem = ((MHVGetItemsTask *) task).firstItemRetrieved;
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
        
    }];
    
LError:
    return nil;
}

-(MHVTask *)state_put
{
    MHVItemCollection* items = [[MHVItemCollection alloc] initWithItem:m_change.localItem];
    HVCHECK_NOTNULL(items);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newPutItemsForRecord:m_mgr.record items:items andCallback:^(MHVTask *task) {
        @try
        {
            m_change.updatedKey = ((MHVPutItemsTask *) task).firstKey;
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
        
    }];

LError:
    return nil;
}

-(MHVTask *)state_refresh
{
    m_change.updatedItem = nil;
    
    MHVItemQuery* query = [[MHVItemQuery alloc] initWithItemKey:m_change.updatedKey andType:m_change.typeID];
    HVCHECK_NOTNULL(query);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newGetItemsForRecord:m_mgr.record query:query andCallback:^(MHVTask *task) {
        @try
        {
            m_change.updatedItem = ((MHVGetItemsTask *) task).firstItemRetrieved;
        }
        @catch (id ex)
        {
            [m_mgr notifyException:ex];
            [task clearError];
        }
        
        self.stateID = HVItemChangeCommitStateDone;
        
    }];
    
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
// MHVItemChangeManager
//
//-----------------------------------------------------
HVDEFINE_NOTIFICATION(HVItemChangeManagerStartingCommitNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerFinishedCommitNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerChangeCommitSuccessNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerChangeCommitFailedNotification);
HVDEFINE_NOTIFICATION(HVItemChangeManagerExceptionNotification);

@implementation MHVItemChangeManager

@synthesize record = m_record;
@synthesize data = m_data;
@synthesize changeTable = m_changeTable;
@synthesize locks = m_lockTable;

-(MHVItemCommitErrorHandler *)errorHandler
{
    return m_errorHandler;
}
-(void)setErrorHandler:(MHVItemCommitErrorHandler *)errorHandler
{
    if (errorHandler)
    {
        m_errorHandler = errorHandler;
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

-(id)initOverStore:(id<MHVObjectStore>)store forRecord:(MHVRecordReference *)record andData:(MHVSynchronizedStore *)data
{
    HVCHECK_NOTNULL(store);
    HVCHECK_NOTNULL(record);
    HVCHECK_NOTNULL(data);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_record = record;
    m_data = data;

    HVCHECK_SUCCESS([self ensureChangeTable:store]);
    
    m_lockTable = [[MHVLockTable alloc] init];
    HVCHECK_NOTNULL(m_lockTable);

    m_status = [[MHVWorkerStatus alloc] init];
    HVCHECK_NOTNULL(m_status);
    
    m_errorHandler = [[MHVItemCommitErrorHandler alloc] init];
    HVCHECK_NOTNULL(m_errorHandler);
    
    m_broadcastNotifications = TRUE;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(BOOL)hasPendingChanges
{
    return [m_changeTable hasChanges];
}

-(BOOL)hasChangesForItem:(MHVItem *)item
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

-(BOOL)trackPut:(MHVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    NSString* changeID = [self trackPutForTypeID:item.typeID andItemKey:item.key];
    HVCHECK_NOTNULL(changeID);
    
    item.data.common.clientIDValue = changeID;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)trackPutForTypeID:(NSString *)typeID andItemKey:(MHVItemKey *)key
{
    return [m_changeTable trackChange:HVItemChangeTypePut forTypeID:typeID andKey:key];
}

-(BOOL)trackRemoveForTypeID:(NSString *)typeID andItemKey:(MHVItemKey *)key
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

-(MHVTask *)commitChangesWithCallback:(HVTaskCompletion)callback
{
    MHVTask* commitTask = [self newCommitChangesTaskWithCallback:callback];
    if (commitTask)
    {
        [commitTask start];
    }
    return commitTask;
}

-(MHVTask *)newCommitChangesTaskWithCallback:(HVTaskCompletion)callback
{
    if (![m_status beginWork])
    {
        // Already working
        return nil;
    }
    
    MHVItemChangeQueue* queue = [m_changeTable getQueue];
    
    MHVItemChangeQueueProcess* queueProcessor = [[MHVItemChangeQueueProcess alloc] initWithChangeManager:self andQueue:queue];
    if (!queueProcessor)
    {
        [m_status completeWork];
        return nil;
    }
    
    MHVTask* task = [MHVTaskStateMachine newRunTaskFor:queueProcessor callback:callback];
    task.taskName = @"QueueProcessorStateMachine";
    
    if (!task)
    {
        [m_status completeWork];
        return nil;
    }
    
    return task;
}

-(MHVAutoLock *)newAutoLockForItemKey:(MHVItemKey *)key
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

@implementation MHVItemChangeManager (HVPrivate)

-(MHVWorkerStatus *)status
{
    return m_status;
}

-(BOOL)ensureChangeTable:(id<MHVObjectStore>)store
{
    id<MHVObjectStore> changeStore = [store newChildStore:[MHVItemChangeManager changeStoreKey]];
    HVCHECK_NOTNULL(changeStore);
    
    m_changeTable = [[MHVItemChangeTable alloc] initWithObjectStore:changeStore];
    
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

-(void)notifyCommitSuccess:(MHVItemChange *)change itemLock:(MHVAutoLock *)lock
{
    @try
    {
        if (self.syncMgr)
        {
            [self.syncMgr applyChangeCommitSuccess:change itemLock:lock];
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

-(void)notifyCommitFailed:(MHVItemChange *)change
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


