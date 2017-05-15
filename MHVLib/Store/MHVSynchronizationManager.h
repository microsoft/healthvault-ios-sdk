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
#import "MHVThingChangeManager.h"
#import "MHVSynchronizedStore.h"

@class MHVLocalRecordStore;
@class MHVSynchronizedType;

@interface MHVSynchronizationManager : NSObject
{
@private
    MHVLocalRecordStore* m_store;
    MHVSynchronizedStore* m_data;
    MHVThingChangeManager* m_changeManager;
    NSMutableDictionary* m_syncTypes;
}

@property (strong, readonly, nonatomic) MHVLocalRecordStore* store;
@property (strong, readonly, nonatomic) MHVRecordReference* record;
@property (strong, readonly, nonatomic) MHVSynchronizedStore* data;
@property (readonly, nonatomic) MHVThingChangeManager* changeManager;

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

-(MHVThing *) getLocalThingWithKey:(MHVThingKey *) key; // Returns nil if not locally available
-(MHVThing *) getLocalThingForEditWithKey:(MHVThingKey *) key; // Clones (in memory only) thing, if available. Returns nil if not locally available
-(MHVDownloadThingsTask *) downloadThingWithKey:(MHVThingKey *) key withCallback:(MHVTaskCompletion) callback;

-(MHVAutoLock *) newLockForThingKey:(MHVThingKey *) key;
-(BOOL) putNewThing:(MHVThing *) thing;
-(BOOL) putThing:(MHVThing *) thing thingLock:(MHVAutoLock *) lock;
-(BOOL) removeThing:(MHVThing *) thing thingLock:(MHVAutoLock *) lock;
-(BOOL) removeThingWithTypeID:(NSString *) typeID key:(MHVThingKey *) key thingLock:(MHVAutoLock *) lock;

-(BOOL) hasPendingChanges;
-(MHVTask *) commitPendingChangesWithCallback:(MHVTaskCompletion) callback;

+(NSString *) dataStoreKey;

-(void) clearCache;

//---------------------------------------------------
//
// Internal methods called MHVSynchronizationStore
//
//---------------------------------------------------
-(BOOL) replaceLocalWithDownloaded:(MHVThing *) thing;  // Will only replace the local thing if there are no pending changes to the thing
-(BOOL) applyChangeCommitSuccess:(MHVThingChange *) change thingLock:(MHVAutoLock *) lock;

@end
