//
//  MHVSynchronizationManager.h
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
#import <Foundation/Foundation.h>
#import "MHVItemChangeManager.h"
#import "MHVSynchronizedStore.h"

@class MHVLocalRecordStore;
@class MHVSynchronizedType;

@interface MHVSynchronizationManager : NSObject
{
@private
    MHVLocalRecordStore* m_store;
    MHVSynchronizedStore* m_data;
    MHVItemChangeManager* m_changeManager;
    NSMutableDictionary* m_syncTypes;
}

@property (strong, readonly, nonatomic) MHVLocalRecordStore* store;
@property (strong, readonly, nonatomic) MHVRecordReference* record;
@property (strong, readonly, nonatomic) MHVSynchronizedStore* data;
@property (readonly, nonatomic) MHVItemChangeManager* changeManager;

-(id) initForRecordStore:(MHVLocalRecordStore *) store withCache:(BOOL) cache;

// Invoked by the owning MHVLocalRecordStore to release references
-(void) close;
-(void) reset;  // Warning - calling this will delete all locally cached data and any pending changes
//
// Return a synchronized type object for the given typeID
// MHVSynchronizedType can function offline just like a MHVTypeView, but also has Offline WRITEs
// and reliable background commit support. See documentation
//
-(MHVSynchronizedType *) getTypeForClassName:(NSString *)className;
-(MHVSynchronizedType *) getTypeForTypeID:(NSString *) typeID;

-(MHVItem *) getLocalItemWithKey:(MHVItemKey *) key; // Returns nil if not locally available
-(MHVItem *) getLocalItemForEditWithKey:(MHVItemKey *) key; // Clones (in memory only) item, if available. Returns nil if not locally available
-(MHVDownloadItemsTask *) downloadItemWithKey:(MHVItemKey *) key withCallback:(MHVTaskCompletion) callback;

-(MHVAutoLock *) newLockForItemKey:(MHVItemKey *) key;
-(BOOL) putNewItem:(MHVItem *) item;
-(BOOL) putItem:(MHVItem *) item itemLock:(MHVAutoLock *) lock;
-(BOOL) removeItem:(MHVItem *) item itemLock:(MHVAutoLock *) lock;
-(BOOL) removeItemWithTypeID:(NSString *) typeID key:(MHVItemKey *) key itemLock:(MHVAutoLock *) lock;

-(BOOL) hasPendingChanges;
-(MHVTask *) commitPendingChangesWithCallback:(MHVTaskCompletion) callback;

+(NSString *) dataStoreKey;

-(void) clearCache;

//---------------------------------------------------
//
// Internal methods called MHVSynchronizationStore
//
//---------------------------------------------------
-(BOOL) replaceLocalWithDownloaded:(MHVItem *) item;  // Will only replace the local item if there are no pending changes to the item
-(BOOL) applyChangeCommitSuccess:(MHVItemChange *) change itemLock:(MHVAutoLock *) lock;

@end
