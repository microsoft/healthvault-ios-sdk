//
//  MHVThingChangeManager.m
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
#import "MHVThingChangeManager.h"
#import "MHVServerResponseStatus.h"
#import "MHVThing.h"
#import "MHVSynchronizationManager.h"
#import "MHVClient.h"

@interface MHVThingChangeManager (MHVPrivate)

-(MHVWorkerStatus*) status;

-(BOOL) ensureChangeTable:(id<MHVObjectStore>) store;

-(void) notifyStarting;
-(void) notifyFinished;
-(void) notifyCommitSuccess:(MHVThingChange *) change thingLock:(MHVAutoLock *) lock;
-(void) notifyCommitFailed:(MHVThingChange *) change;
-(void) notifyException:(id) ex;

@end

@interface MHVThingChangeQueueProcess (MHVPrivate)

-(void) state_start;
-(MHVTask *) state_next;
-(BOOL) state_done;

-(MHVTask *) commitChange;
-(BOOL) acquireLockForChange:(MHVThingChange *) change;
-(void) releaseLockForChange:(MHVThingChange *) change;
-(BOOL) handleException:(id) ex shouldDequeue:(BOOL *) dequeue;
-(void) clear;

@end

@interface MHVThingChangeCommit (MHVPrivate)

-(void) state_start;
-(MHVTask *) state_remove;
-(void) state_startNew;
-(void) state_startPut;
-(MHVTask *) state_new;
-(void) state_startUpdate;
-(MHVTask *) state_detectDupe:(enum MHVThingChangeCommitState) state;
-(MHVTask *) state_put;
-(MHVTask *) state_refresh;

-(void) updateChangeAttemptCount;

@end

//-----------------------------------------------------
//
// MHVThingChangeQueueProcess
//
//-----------------------------------------------------

@implementation MHVThingChangeQueueProcess

@synthesize changeManager = m_mgr;
-(enum MHVThingChangeQueueProcessState)currentState
{
    return (enum MHVThingChangeQueueProcessState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andQueue:nil];
}

-(id)initWithChangeManager:(MHVThingChangeManager *)mgr andQueue:(NSEnumerator *)queue
{
    MHVCHECK_NOTNULL(mgr);
    MHVCHECK_NOTNULL(queue);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_mgr = mgr;
    m_queue = queue;
    
    self.name = @"MHVThingChangeQueueProcess";
    self.stateID = MHVThingChangeQueueProcessStateStart;
 
    return self;
    
LError:
    MHVALLOC_FAIL;
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
        enum MHVThingChangeQueueProcessState currentState = self.stateID;
        switch (currentState)
        {
            default:
                NSLog(@"MHVthingChangeQueueProcess: Unknown State %d", self.stateID);
                return nil;
                
            case MHVThingChangeQueueProcessStateStart:
                [self state_start];
                break;
                
            case MHVThingChangeQueueProcessStateNext:
                if ((nextTask = [self state_next]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeQueueProcessStateDone:
                if ([self state_done])
                {
                    return nil;
                }
                break;
        }
        MHVCHECK_FALSE(currentState == self.stateID);  // Prevent infinite loops
    }
    
LError:
    return nil;
}

-(void) onAborted
{
    [m_mgr.status completeWork];
}

@end

@implementation MHVThingChangeQueueProcess(MHVPrivate)

-(void)state_start
{
    m_committedCount = 0;
    self.stateID = MHVThingChangeQueueProcessStateNext;
}

-(MHVTask *)state_next
{
    while (TRUE)
    {
        [self clear];
        
        if (!m_mgr.isCommitEnabled)
        {
            self.stateID = MHVThingChangeQueueProcessStateDone;
            return nil;
        }
        
        MHVThingChange* queuedChange = [m_queue nextObject];
        if (queuedChange == nil)
        {
            self.stateID = MHVThingChangeQueueProcessStateDone;
            return nil;
        }
        
        if (![self acquireLockForChange:queuedChange])
        {
            continue;
        }
        
        MHVTask* commitTask = nil;
        @try
        {
            MHVThingChange* change = [m_mgr.changeTable getForTypeID:queuedChange.typeID thingID:queuedChange.thingID];
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

    self.stateID = MHVThingChangeQueueProcessStateStart;
    return FALSE;
}

-(MHVTask *)commitChange
{
    m_commit = nil;
    
    m_commit = [[MHVThingChangeCommit alloc] initWithChangeManager:m_mgr andChange:m_current];
    MHVCHECK_NOTNULL(m_commit);
    
    return [MHVTaskStateMachine newRunTaskFor:m_commit callback:^(MHVTask *task) {
        BOOL shouldDequeue = FALSE;
        BOOL shouldContinue = TRUE;
        @try
        {
            [task checkSuccess];
            [m_mgr notifyCommitSuccess:m_current thingLock:m_lock];
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
                [m_mgr.changeTable removeForTypeID:m_current.typeID thingID:m_current.thingID];
            }
            self.stateID = MHVThingChangeQueueProcessStateNext;
        }
        else
        {
            self.stateID = MHVThingChangeQueueProcessStateDone;
        }
        
        [self releaseLockForChange:m_current];
        [self clear];
    }];
    
LError:
    return nil;
}

-(BOOL)acquireLockForChange:(MHVThingChange *)change
{
    m_lock = nil;
    m_lock = [m_mgr.locks newAutoLockForKey:change.thingID];
    return (m_lock != nil);
}

-(void)releaseLockForChange:(MHVThingChange *)change
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
// MHVThingChangeCommit
//
//-----------------------------------------------------

@implementation MHVThingChangeCommit

-(enum MHVThingChangeCommitState)currentState
{
    return (enum MHVThingChangeCommitState) self.stateID;
}

-(id)init
{
    return [self initWithChangeManager:nil andChange:nil];
}

-(id)initWithChangeManager:(MHVThingChangeManager *)mgr andChange:(MHVThingChange *)change
{
    MHVCHECK_NOTNULL(mgr);
    MHVCHECK_NOTNULL(change);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_mgr = mgr;
    m_change = change;
    m_methodFactory = [MHVClient current].methodFactory;
    
    self.name = @"MHVThingChangeCommit";
    self.stateID = MHVThingChangeCommitStateStart;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTask *) nextTask
{
    while (TRUE)
    {
        MHVTask* nextTask = nil;
        enum MHVThingChangeCommitState currentState = self.stateID;
        switch (currentState)
        {
            default:
                NSLog(@"MHVthingChangeCommit: Unknown State %d", self.stateID);
                break;
                
            case MHVThingChangeCommitStateStart:
                [self state_start];
                break;
                
            case MHVThingChangeCommitStateRemove:
                if ((nextTask = [self state_remove]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeCommitStateStartNew:
                [self state_startNew];
                break;
                
            case MHVThingChangeCommitStateNew:
                if ((nextTask = [self state_new]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeCommitStateStartPut:
                [self state_startPut];
                break;
                
            case MHVThingChangeCommitStateStartUpdate:
                [self state_startUpdate];
                break;
                
            case MHVThingChangeCommitStateDetectDupeNew:
            case MHVThingChangeCommitStateDetectDupeUpdate:
                if ((nextTask = [self state_detectDupe:currentState]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeCommitStatePut:
                if ((nextTask = [self state_put]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeCommitStateRefresh:
                if ((nextTask = [self state_refresh]) != nil)
                {
                    return nextTask;
                }
                break;
                
            case MHVThingChangeCommitStateDone:
                return nil;
        }
        MHVCHECK_FALSE(currentState == self.stateID);  // Prevent infinite loops
    }
    
LError:
    return nil;
}


@end

@implementation MHVThingChangeCommit (MHVPrivate)

-(MHVSynchronizedStore *)data
{
    return m_mgr.data;
}

-(void)state_start
{
    [self updateChangeAttemptCount];
    if (m_change.changeType == MHVThingChangeTypeRemove)
    {
        self.stateID = MHVThingChangeCommitStateRemove;
    }
    else
    {
        self.stateID = MHVThingChangeCommitStateStartPut;
    }
}

-(MHVTask *)state_remove
{
    if ([m_change.thingKey isLocal])
    {
        self.stateID = MHVThingChangeQueueProcessStateDone;
        return nil;
    }
    
    MHVThingKeyCollection* keys = [[MHVThingKeyCollection alloc] initWithKey:m_change.thingKey];
    MHVCHECK_NOTNULL(keys);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newRemoveThingsForRecord:m_mgr.record keys:keys andCallback:^(MHVTask *task) {
        @try
        {
            [task checkSuccess];
        }
        @catch (MHVServerException* ex)
        {
            if (![ex.status isThingKeyNotFound])
            {
                @throw;
            }
            [task clearError];
        }
        self.stateID = MHVThingChangeCommitStateDone;
    }];
    
LError:
    return nil;
}

-(void)state_startPut
{
    m_change.localThing = [[m_mgr.data getlocalThingWithID:m_change.thingID] newDeepClone];
    if (m_change.localThing == nil)
    {
        self.stateID = MHVThingChangeCommitStateDone;
        return;
    }
        
    if ([m_change.localThing.key isLocal])
    {
        self.stateID = MHVThingChangeCommitStateStartNew;
    }
    else
    {
        self.stateID = MHVThingChangeCommitStateStartUpdate;
    }
}

-(void)state_startNew
{
    self.stateID = MHVThingChangeCommitStateDetectDupeNew;
}

-(MHVTask *)state_new
{
    MHVThingCollection* things = [[MHVThingCollection alloc] initWithThing:m_change.localThing];
    MHVCHECK_NOTNULL(things);
   
    [things prepareForNew];
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newPutThingsForRecord:m_mgr.record things:things andCallback:^(MHVTask *task) {
        
        m_change.updatedKey = ((MHVPutThingsTask *) task).firstKey;
        
        self.stateID = MHVThingChangeCommitStateRefresh;
        
    }];
    
LError:
    return nil;
}

-(void)state_startUpdate
{
    self.stateID = MHVThingChangeCommitStateDetectDupeUpdate;
}

//
// Make a best effort to avoid pushing duplicates into the system. Example scenario:
// -Thing pushed into MHV but phone turned off before local tables could be updated
// - Many others
//
-(MHVTask *)state_detectDupe:(enum MHVThingChangeCommitState)state
{
    if (m_change.attemptCount <= 1)
    {
        self.stateID = (state == MHVThingChangeCommitStateDetectDupeUpdate) ? MHVThingChangeCommitStatePut : MHVThingChangeCommitStateNew;
        return nil;
    }
  
    MHVThingQuery* query = [[MHVThingQuery alloc] initWithClientID:m_change.changeID andType:m_change.typeID];
    MHVCHECK_NOTNULL(query);
    query.maxResults = 1;
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newGetThingsForRecord:m_mgr.record query:query andCallback:^(MHVTask *task) {
        
        MHVThing* existingThing = ((MHVGetThingsTask *) task).firstThingRetrieved;
        if (existingThing == nil)
        {
            // Did not commit this change yet
            self.stateID = (state == MHVThingChangeCommitStateDetectDupeUpdate) ? MHVThingChangeCommitStatePut : MHVThingChangeCommitStateNew;
        }
        else
        {
            // Already applied this change.
            m_change.updatedKey = existingThing.key;
            m_change.updatedThing = existingThing;
            self.stateID = MHVThingChangeCommitStateDone;
        }
        
    }];
    
LError:
    return nil;
}

-(MHVTask *)state_put
{
    MHVThingCollection* things = [[MHVThingCollection alloc] initWithThing:m_change.localThing];
    MHVCHECK_NOTNULL(things);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newPutThingsForRecord:m_mgr.record things:things andCallback:^(MHVTask *task) {
        @try
        {
            m_change.updatedKey = ((MHVPutThingsTask *) task).firstKey;
            self.stateID = MHVThingChangeCommitStateRefresh;
        }
        @catch (id ex)
        {
            if (![m_mgr.errorHandler shouldCreateNewThingForConflict:m_change onException:ex])
            {
                @throw;
            }
            [task clearError];
            self.stateID = MHVThingChangeCommitStateNew;
        }
        
    }];

LError:
    return nil;
}

-(MHVTask *)state_refresh
{
    m_change.updatedThing = nil;
    
    MHVThingQuery* query = [[MHVThingQuery alloc] initWithThingKey:m_change.updatedKey andType:m_change.typeID];
    MHVCHECK_NOTNULL(query);
    
    MHVMethodFactory* methods = [MHVClient current].methodFactory;
    return [methods newGetThingsForRecord:m_mgr.record query:query andCallback:^(MHVTask *task) {
        @try
        {
            m_change.updatedThing = ((MHVGetThingsTask *) task).firstThingRetrieved;
        }
        @catch (id ex)
        {
            [m_mgr notifyException:ex];
            [task clearError];
        }
        
        self.stateID = MHVThingChangeCommitStateDone;
        
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
// MHVThingChangeManager
//
//-----------------------------------------------------
MHVDEFINE_NOTIFICATION(MHVThingChangeManagerStartingCommitNotification);
MHVDEFINE_NOTIFICATION(MHVThingChangeManagerFinishedCommitNotification);
MHVDEFINE_NOTIFICATION(MHVThingChangeManagerChangeCommitSuccessNotification);
MHVDEFINE_NOTIFICATION(MHVThingChangeManagerChangeCommitFailedNotification);
MHVDEFINE_NOTIFICATION(MHVThingChangeManagerExceptionNotification);

@implementation MHVThingChangeManager

@synthesize record = m_record;
@synthesize data = m_data;
@synthesize changeTable = m_changeTable;
@synthesize locks = m_lockTable;

-(MHVThingCommitErrorHandler *)errorHandler
{
    return m_errorHandler;
}
-(void)setErrorHandler:(MHVThingCommitErrorHandler *)errorHandler
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
    MHVCHECK_NOTNULL(store);
    MHVCHECK_NOTNULL(record);
    MHVCHECK_NOTNULL(data);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_record = record;
    m_data = data;

    MHVCHECK_SUCCESS([self ensureChangeTable:store]);
    
    m_lockTable = [[MHVLockTable alloc] init];
    MHVCHECK_NOTNULL(m_lockTable);

    m_status = [[MHVWorkerStatus alloc] init];
    MHVCHECK_NOTNULL(m_status);
    
    m_errorHandler = [[MHVThingCommitErrorHandler alloc] init];
    MHVCHECK_NOTNULL(m_errorHandler);
    
    m_broadcastNotifications = TRUE;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL)hasPendingChanges
{
    return [m_changeTable hasChanges];
}

-(BOOL)hasChangesForThing:(MHVThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    return [m_changeTable hasChangesForTypeID:thing.typeID thingID:thing.thingID];
    
LError:
    return FALSE;
}

-(BOOL)hasChangesForTypeID:(NSString *)typeID
{
    return [m_changeTable hasChangesForTypeID:typeID];
}

-(BOOL)trackPut:(MHVThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    NSString* changeID = [self trackPutForTypeID:thing.typeID andThingKey:thing.key];
    MHVCHECK_NOTNULL(changeID);
    
    thing.data.common.clientIDValue = changeID;
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *)trackPutForTypeID:(NSString *)typeID andThingKey:(MHVThingKey *)key
{
    return [m_changeTable trackChange:MHVThingChangeTypePut forTypeID:typeID andKey:key];
}

-(BOOL)trackRemoveForTypeID:(NSString *)typeID andThingKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    if ([key isLocal])
    {
        return [m_changeTable removeForTypeID:typeID thingID:key.thingID];
    }
    
    NSString* changeID = [m_changeTable trackChange:MHVThingChangeTypeRemove forTypeID:typeID andKey:key];
    return (changeID != nil);
    
LError:
    return FALSE;
}

-(MHVTask *)commitChangesWithCallback:(MHVTaskCompletion)callback
{
    MHVTask* commitTask = [self newCommitChangesTaskWithCallback:callback];
    if (commitTask)
    {
        [commitTask start];
    }
    return commitTask;
}

-(MHVTask *)newCommitChangesTaskWithCallback:(MHVTaskCompletion)callback
{
    if (![m_status beginWork])
    {
        // Already working
        return nil;
    }
    
    MHVThingChangeQueue* queue = [m_changeTable getQueue];
    
    MHVThingChangeQueueProcess* queueProcessor = [[MHVThingChangeQueueProcess alloc] initWithChangeManager:self andQueue:queue];
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

-(MHVAutoLock *)newAutoLockForThingKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    return [m_lockTable newAutoLockForKey:key.thingID];

LError:
    return nil;
}

-(long)acquireLockForThingID:(NSString *)thingID
{
    return [m_lockTable acquireLockForKey:thingID];
}

-(void)releaseLock:(long)lockID forThingID:(NSString *)thingID
{
    [m_lockTable releaseLock:lockID forKey:thingID];
}

+(NSString *)changeStoreKey
{
    return @"Changes";
}

@end

@implementation MHVThingChangeManager (MHVPrivate)

-(MHVWorkerStatus *)status
{
    return m_status;
}

-(BOOL)ensureChangeTable:(id<MHVObjectStore>)store
{
    id<MHVObjectStore> changeStore = [store newChildStore:[MHVThingChangeManager changeStoreKey]];
    MHVCHECK_NOTNULL(changeStore);
    
    m_changeTable = [[MHVThingChangeTable alloc] initWithObjectStore:changeStore];
    
    MHVCHECK_NOTNULL(m_changeTable);
    
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
             postNotificationName:MHVThingChangeManagerStartingCommitNotification
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
             postNotificationName:MHVThingChangeManagerFinishedCommitNotification
             object:self
             ];
        }
    });
}

-(void)notifyCommitSuccess:(MHVThingChange *)change thingLock:(MHVAutoLock *)lock
{
    @try
    {
        if (self.syncMgr)
        {
            [self.syncMgr applyChangeCommitSuccess:change thingLock:lock];
        }
    }
    @catch (id ex)
    {
    }
    
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:MHVThingChangeManagerChangeCommitSuccessNotification
                                                                object:self
                                                              userInfo:@{
                                                                         @"thingChange" : change
                                                                         }];
        }
    });
}

-(void)notifyCommitFailed:(MHVThingChange *)change
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:MHVThingChangeManagerChangeCommitFailedNotification
                                                                object:self
                                                              userInfo:@{
                                                                         @"thingChange" : change
                                                                         }];
        }
    });
}

-(void)notifyException:(id)ex   
{
    safeInvokeAction(^{
        if (m_broadcastNotifications)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:MHVThingChangeManagerExceptionNotification
                                                                object:self
                                                              userInfo:@{
                                                                         @"exception" : ex
                                                                         }];
        }
    });
}

@end


