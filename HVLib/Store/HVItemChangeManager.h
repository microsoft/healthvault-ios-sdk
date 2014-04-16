//
//  HVItemChangeManager.h
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
#import <Foundation/Foundation.h>
#import "HVCore.h"
#import "HVWorkerStatus.h"
#import "HVItemChangeTable.h"
#import "HVItemCommitErrorHandler.h"
#import "HVLockTable.h"
#import "HVSynchronizedStore.h"
#import "HVMethodFactory.h"

@class HVItemChangeManager;
@class HVSynchronizationManager;
@class HVItemChangeCommit;
@class HVItemChangeQueueProcess;

//
// ItemChangeManager OPTIONALLY BROADCASTS the following events using [NSNotificationCenter defaultCenter]
//
HVDECLARE_NOTIFICATION(HVItemChangeManagerStartingCommitNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerFinishedCommitNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerChangeCommitSuccessNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerChangeCommitFailedNotification);
HVDECLARE_NOTIFICATION(HVItemChangeManagerExceptionNotification);

@interface HVItemChangeManager : NSObject
{
@private
    HVSynchronizationManager* m_syncMgr; // weak reference
    
    HVRecordReference* m_record;
    HVSynchronizedStore* m_data;
    HVItemChangeTable* m_changeTable;
    HVLockTable* m_lockTable;
    HVItemCommitErrorHandler* m_errorHandler;
    HVWorkerStatus* m_status;
    
    BOOL m_broadcastNotifications;
}

@property (readwrite, nonatomic, assign) HVSynchronizationManager* syncMgr; // Weak ref

@property (readonly, nonatomic) HVRecordReference* record;
@property (readonly, nonatomic) HVSynchronizedStore* data;
@property (readonly, nonatomic) HVItemChangeTable* changeTable;
@property (readonly, nonatomic) HVLockTable* locks;
@property (readwrite, nonatomic, retain) HVItemCommitErrorHandler* errorHandler;
//
// Set to <= 0 if you don't want batching
//
@property (readwrite, nonatomic) int batchSize;

@property (readwrite, nonatomic) BOOL isCommitEnabled;
@property (readonly, nonatomic) BOOL isBusy;
@property (readwrite, nonatomic) BOOL isBroadcastingNotifications;

-(id) initOverStore:(id<HVObjectStore>) store forRecord:(HVRecordReference *) record andData:(HVSynchronizedStore *) data;

-(BOOL) hasPendingChanges;
-(BOOL) hasChangesForItem:(HVItem *) item;
-(BOOL) hasChangesForTypeID:(NSString *) typeID;

-(BOOL) trackPut:(HVItem *) item;
-(NSString *) trackPutForTypeID:(NSString *) typeID andItemKey:(HVItemKey *)key;
-(BOOL) trackRemoveForTypeID:(NSString *) typeID andItemKey:(HVItemKey *)key;
-(HVAutoLock *) newAutoLockForItemKey:(HVItemKey *) key;

-(HVTask *) commitChangesWithCallback:(HVTaskCompletion) callback;

-(HVTask *) newCommitChangesTaskWithCallback:(HVTaskCompletion) callback;

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

@interface HVItemChangeQueueProcess : HVTaskStateMachine
{
@private
    HVItemChangeManager* m_mgr;
    NSEnumerator* m_queue;
    HVItemChange* m_current;
    HVAutoLock* m_lock;
    HVItemChangeCommit* m_commit;
    NSUInteger m_committedCount;
}

@property (readonly, nonatomic) HVItemChangeManager* changeManager;
@property (readonly, nonatomic) enum HVItemChangeQueueProcessState currentState;
@property (readonly, nonatomic) NSUInteger committedCount;

-(id) initWithChangeManager:(HVItemChangeManager *) mgr andQueue:(NSEnumerator *) queue;

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

@interface HVItemChangeCommit : HVTaskStateMachine
{
@private
    HVItemChangeManager* m_mgr;
    HVItemChange* m_change;
    HVMethodFactory* m_methodFactory;
}

@property (readonly, nonatomic) enum HVItemChangeCommitState currentState;

-(id) initWithChangeManager:(HVItemChangeManager *) mgr andChange:(HVItemChange *) change;

@end


