//
//  MHVSynchronizedStore.h
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

#import <Foundation/Foundation.h>
#import "MHVAsyncTask.h"
#import "MHVObjectStore.h"
#import "MHVThingStore.h"
#import "MHVDownloadThingsTask.h"

@class MHVTypeView;
@class MHVSynchronizationManager;

@interface MHVSynchronizedStore : NSObject
{
    MHVThingSection m_sections;
    id<MHVThingStore> m_localStore;
}

@property (readonly, nonatomic, strong) id<MHVThingStore> localStore;
@property (readwrite, nonatomic) MHVThingSection defaultSections;

// Weak ref back to the owning sync manager, if any
@property (readwrite, nonatomic, weak) MHVSynchronizationManager* syncMgr;

-(id) initOverStore:(id<MHVObjectStore>) store;
-(id) initOverThingStore:(id<MHVThingStore>) store;

-(void) clearCache;

//---------------------------------
//
// Operations on things locally available on this machine
//
//---------------------------------

-(MHVThing *) getLocalThingWithKey:(MHVThingKey *) key;
//
// Retrieve locally stored things for the given keys
// MHVThingCollection.count is always == keys.count
// If no local thing is found for a key, returns its equivalent position in MHVThingCollection
// contains NSNull
//
-(MHVThingCollection *) getLocalThingsWithKeys:(MHVThingKeyCollection *) keys;

-(MHVThing *) getlocalThingWithID:(NSString *) thingID;
-(BOOL) putLocalThing:(MHVThing *) thing;
-(void) removeLocalThingWithKey:(MHVThingKey *) key;

//---------------------------------
//
// Operations that go to HealthVault
// They pull things down to the local store
//
//---------------------------------
//
// Downloads things for the given keys and store them locally.
// Always retrieves the LATEST thing for the key 
// When complete, notify MHVTypeView of completions by calling:
//   - keysNotRetrieved (if error)
//   - thingsRetrieved
//
-(MHVTask *) downloadThingsWithKeys:(MHVThingKeyCollection *) keys inView:(MHVTypeView *) view;
-(MHVTask *) downloadThingsWithKeys:(MHVThingKeyCollection *) keys typeID:(NSString *) typeID inView:(MHVTypeView *) view;
//
// Fetch things with given keys into the local store
// Always retrieves the LATEST thing for the key
// In the callback, MHVTask.result has an MHVThingCollection containing those things that were found
//
-(MHVTask *) getThingsInRecord:(MHVRecordReference *) record withKeys:(MHVThingKeyCollection *) keys callback:(MHVTaskCompletion) callback;
-(MHVTask *) getThingsInRecord:(MHVRecordReference *) record forQuery:(MHVThingQuery *) query callback:(MHVTaskCompletion) callback;

// Deprecated. Use MHVSynchronizationMgr & MHVSynchronizedType
-(BOOL) putThing:(MHVThing *) thing __deprecated;

//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
// task.result will contain updated keys - in case the things 
// Always retrieves the LATEST thing for the keys
//
-(MHVDownloadThingsTask *) downloadThingsInRecord:(MHVRecordReference *) record forKeys:(MHVThingKeyCollection *) keys callback:(MHVTaskCompletion) callback;
//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
//
-(MHVDownloadThingsTask *) downloadThingsInRecord:(MHVRecordReference *) record query:(MHVThingQuery *) query callback:(MHVTaskCompletion) callback;
//
// These create new download tasks but do NOT start them.
// You can make the task a child of another task
// 
-(MHVDownloadThingsTask *) newDownloadThingsInRecord:(MHVRecordReference *) record forKeys:(MHVThingKeyCollection *) keys callback:(MHVTaskCompletion) callback;
-(MHVDownloadThingsTask *) newDownloadThingsInRecord:(MHVRecordReference *) record forQuery:(MHVThingQuery *) query callback:(MHVTaskCompletion) callback;

@end
