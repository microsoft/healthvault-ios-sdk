//
//  MHVItemChangeManager.h
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
#import "MHVItemChangeTable.h"
#import "MHVItemCommitErrorHandler.h"
#import "MHVLockTable.h"
#import "MHVSynchronizedStore.h"
#import "MHVMethodFactory.h"

@class MHVItemChangeManager;
@class MHVSynchronizationManager;
@class MHVItemChangeCommit;
@class MHVItemChangeQueueProcess;

//
// ItemChangeManager OPTIONALLY BROADCASTS the following events using [NSNotificationCenter defaultCenter]
//
HVDECLARE_NOTIFICATION(HVItemChangeManagerStartingCommitNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerFinishedCommitNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerChangeCommitSuccessNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerChangeCommitFailedNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerExceptionNotification);

@interface MHVItemChangeManager : NSObject
{
@private
    MHVRecordReference* m_record;
    MHVSynchronizedStore* m_data;
    MHVItemChangeTable* m_changeTable;
    MHVLockTable* m_lockTable;
    MHVItemCommitErrorHandler* m_errorHandler;
    MHVWorkerStatus* m_status;
    
    BOOL m_broadcastNotifications;
}

@property (readwrite, nonatomic, assign) MHVSynchronizationManager* syncMgr; // Weak ref

@property (strong, readonly, nonatomic) MHVRecordReference* record;
@property (strong, readonly, nonatomic) MHVSynchronizedStore* data;
@property (strong, readonly, nonatomic) MHVItemChangeTable* changeTable;
@property (readonly, nonatomic) MHVLockTable* locks;
@property (readwrite, nonatomic, strong) MHVItemCommitErrorHandler* errorHandler;
//
// Set to <= 0 if you don't want batching
//
@property (readwrite, nonatomic) int batchSize;

@property (readwrite, nonatomic) BOOL isCommitEnabled;
@property (readonly, nonatomic) BOOL isBusy;
@property (readwrite, nonatomic) BOOL isBroadcastingNotifications;

-(id) initOverStore:(id<MHVObjectStore>) store forRecord:(MHVRecordReference *) record andData:(MHVSynchronizedStore *) data;

-(BOOL) hasPendingChanges;
-(BOOL) hasChangesForItem:(MHVItem *) item;
-(BOOL) hasChangesForTypeID:(NSString *) typeID;

-(BOOL) trackPut:(MHVItem *) item;
-(NSString *) trackPutForTypeID:(NSString *) typeID andItemKey:(MHVItemKey *)key;
-(BOOL) trackRemoveForTypeID:(NSString *) typeID andItemKey:(MHVItemKey *)key;
-(MHVAutoLock *) newAutoLockForItemKey:(MHVItemKey *) key;

-(MHVTask *) commitChangesWithCallback:(HVTaskCompletion) callback;

-(MHVTask *) newCommitChangesTaskWithCallback:(HVTaskCompletion) callback;

-(long) acquireLockForItemID:(NSString *) itemID;
-(void) releaseLock:(long) lockID forItemID:(NSString *) itemID;

+(NSString *) changeStoreKey;

@end


//-----------------------------------------------------
//
// State machines to perform the asynchrononous steps
// necessary for background commit of items
//
//-----------------------------------------------------

enum HVItemChangeQueueProcessState
{
    HVItemChangeQueueProcessStateStart = 0,
    HVItemChangeQueueProcessStateNext,
    HVItemChangeQueueProcessStateDone
};

@interface MHVItemChangeQueueProcess : MHVTaskStateMachine
{
@private
    MHVItemChangeManager* m_mgr;
    NSEnumerator* m_queue;
    MHVItemChange* m_current;
    MHVAutoLock* m_lock;
    MHVItemChangeCommit* m_commit;
    NSUInteger m_committedCount;
}

@property (strong, readonly, nonatomic) MHVItemChangeManager* changeManager;
@property (readonly, nonatomic) enum HVItemChangeQueueProcessState currentState;
@property (readonly, nonatomic) NSUInteger committedCount;

-(id) initWithChangeManager:(MHVItemChangeManager *) mgr andQueue:(NSEnumerator *) queue;

@end

enum HVItemChangeCommitState
{
    HVItemChangeCommitStateStart = 0,
    HVItemChangeCommitStateRemove,
    HVItemChangeCommitStateStartPut,
    HVItemChangeCommitStateStartNew,
    HVItemChangeCommitStateNew,
    HVItemChangeCommitStateStartUpdate,
    HVItemChangeCommitStateDetectDupeNew,
    HVItemChangeCommitStateDetectDupeUpdate,
    HVItemChangeCommitStatePut,
    HVItemChangeCommitStateRefresh,
    HVItemChangeCommitStateDone
};

@interface MHVItemChangeCommit : MHVTaskStateMachine
{
@private
    MHVItemChangeManager* m_mgr;
    MHVItemChange* m_change;
    MHVMethodFactory* m_methodFactory;
}

@property (readonly, nonatomic) enum HVItemChangeCommitState currentState;

-(id) initWithChangeManager:(MHVItemChangeManager *) mgr andChange:(MHVItemChange *) change;

@end


