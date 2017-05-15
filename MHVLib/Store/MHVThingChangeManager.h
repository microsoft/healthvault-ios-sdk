//
//  MHVThingChangeManager.h
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
#import <Foundation/Foundation.h>
#import "MHVCore.h"
#import "MHVWorkerStatus.h"
#import "MHVThingChangeTable.h"
#import "MHVThingCommitErrorHandler.h"
#import "MHVLockTable.h"
#import "MHVSynchronizedStore.h"
#import "MHVMethodFactory.h"

@class MHVThingChangeManager;
@class MHVSynchronizationManager;
@class MHVThingChangeCommit;
@class MHVThingChangeQueueProcess;

//
// ThingChangeManager OPTIONALLY BROADCASTS the following events using [NSNotificationCenter defaultCenter]
//
MHVDECLARE_NOTIFICATION(MHVThingChangeManagerStartingCommitNotification);
MHVDECLARE_NOTIFICATION(MHVThingChangeManagerFinishedCommitNotification);
MHVDECLARE_NOTIFICATION(MHVThingChangeManagerChangeCommitSuccessNotification);
MHVDECLARE_NOTIFICATION(MHVThingChangeManagerChangeCommitFailedNotification);
MHVDECLARE_NOTIFICATION(MHVThingChangeManagerExceptionNotification);

@interface MHVThingChangeManager : NSObject
{
@private
    MHVRecordReference* m_record;
    MHVSynchronizedStore* m_data;
    MHVThingChangeTable* m_changeTable;
    MHVLockTable* m_lockTable;
    MHVThingCommitErrorHandler* m_errorHandler;
    MHVWorkerStatus* m_status;
    
    BOOL m_broadcastNotifications;
}

@property (readwrite, nonatomic, assign) MHVSynchronizationManager* syncMgr; // Weak ref

@property (strong, readonly, nonatomic) MHVRecordReference* record;
@property (strong, readonly, nonatomic) MHVSynchronizedStore* data;
@property (strong, readonly, nonatomic) MHVThingChangeTable* changeTable;
@property (readonly, nonatomic) MHVLockTable* locks;
@property (readwrite, nonatomic, strong) MHVThingCommitErrorHandler* errorHandler;
//
// Set to <= 0 if you don't want batching
//
@property (readwrite, nonatomic) int batchSize;

@property (readwrite, nonatomic) BOOL isCommitEnabled;
@property (readonly, nonatomic) BOOL isBusy;
@property (readwrite, nonatomic) BOOL isBroadcastingNotifications;

-(id) initOverStore:(id<MHVObjectStore>) store forRecord:(MHVRecordReference *) record andData:(MHVSynchronizedStore *) data;

-(BOOL) hasPendingChanges;
-(BOOL) hasChangesForThing:(MHVThing *) thing;
-(BOOL) hasChangesForTypeID:(NSString *) typeID;

-(BOOL) trackPut:(MHVThing *) thing;
-(NSString *) trackPutForTypeID:(NSString *) typeID andThingKey:(MHVThingKey *)key;
-(BOOL) trackRemoveForTypeID:(NSString *) typeID andThingKey:(MHVThingKey *)key;
-(MHVAutoLock *) newAutoLockForThingKey:(MHVThingKey *) key;

-(MHVTask *) commitChangesWithCallback:(MHVTaskCompletion) callback;

-(MHVTask *) newCommitChangesTaskWithCallback:(MHVTaskCompletion) callback;

-(long) acquireLockForThingID:(NSString *) thingID;
-(void) releaseLock:(long) lockID forThingID:(NSString *) thingID;

+(NSString *) changeStoreKey;

@end


//-----------------------------------------------------
//
// State machines to perform the asynchrononous steps
// necessary for background commit of things
//
//-----------------------------------------------------

enum MHVThingChangeQueueProcessState
{
    MHVThingChangeQueueProcessStateStart = 0,
    MHVThingChangeQueueProcessStateNext,
    MHVThingChangeQueueProcessStateDone
};

@interface MHVThingChangeQueueProcess : MHVTaskStateMachine
{
@private
    MHVThingChangeManager* m_mgr;
    NSEnumerator* m_queue;
    MHVThingChange* m_current;
    MHVAutoLock* m_lock;
    MHVThingChangeCommit* m_commit;
    NSUInteger m_committedCount;
}

@property (strong, readonly, nonatomic) MHVThingChangeManager* changeManager;
@property (readonly, nonatomic) enum MHVThingChangeQueueProcessState currentState;
@property (readonly, nonatomic) NSUInteger committedCount;

-(id) initWithChangeManager:(MHVThingChangeManager *) mgr andQueue:(NSEnumerator *) queue;

@end

enum MHVThingChangeCommitState
{
    MHVThingChangeCommitStateStart = 0,
    MHVThingChangeCommitStateRemove,
    MHVThingChangeCommitStateStartPut,
    MHVThingChangeCommitStateStartNew,
    MHVThingChangeCommitStateNew,
    MHVThingChangeCommitStateStartUpdate,
    MHVThingChangeCommitStateDetectDupeNew,
    MHVThingChangeCommitStateDetectDupeUpdate,
    MHVThingChangeCommitStatePut,
    MHVThingChangeCommitStateRefresh,
    MHVThingChangeCommitStateDone
};

@interface MHVThingChangeCommit : MHVTaskStateMachine
{
@private
    MHVThingChangeManager* m_mgr;
    MHVThingChange* m_change;
    MHVMethodFactory* m_methodFactory;
}

@property (readonly, nonatomic) enum MHVThingChangeCommitState currentState;

-(id) initWithChangeManager:(MHVThingChangeManager *) mgr andChange:(MHVThingChange *) change;

@end


