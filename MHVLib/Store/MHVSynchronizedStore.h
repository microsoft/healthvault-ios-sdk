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
#import "MHVItemStore.h"
#import "MHVDownloadItemsTask.h"

@class MHVTypeView;
@class MHVSynchronizationManager;

@interface MHVSynchronizedStore : NSObject
{
    enum MHVItemSection m_sections;
    id<MHVItemStore> m_localStore;
}

@property (readonly, nonatomic, strong) id<MHVItemStore> localStore;
@property (readwrite, nonatomic) enum MHVItemSection defaultSections;

// Weak ref back to the owning sync manager, if any
@property (readwrite, nonatomic, weak) MHVSynchronizationManager* syncMgr;

-(id) initOverStore:(id<MHVObjectStore>) store;
-(id) initOverItemStore:(id<MHVItemStore>) store;

-(void) clearCache;

//---------------------------------
//
// Operations on items locally available on this machine
//
//---------------------------------

-(MHVItem *) getLocalItemWithKey:(MHVItemKey *) key;
//
// Retrieve locally stored items for the given keys
// MHVItemCollection.count is always == keys.count
// If no local item is found for a key, returns its equivalent position in MHVItemCollection
// contains NSNull
//
-(MHVItemCollection *) getLocalItemsWithKeys:(NSArray *) keys;

-(MHVItem *) getlocalItemWithID:(NSString *) itemID;
-(BOOL) putLocalItem:(MHVItem *) item;
-(void) removeLocalItemWithKey:(MHVItemKey *) key;

//---------------------------------
//
// Operations that go to HealthVault
// They pull items down to the local store
//
//---------------------------------
//
// Downloads items for the given keys and store them locally.
// Always retrieves the LATEST item for the key 
// When complete, notify MHVTypeView of completions by calling:
//   - keysNotRetrieved (if error)
//   - itemsRetrieved
//
-(MHVTask *) downloadItemsWithKeys:(NSArray *) keys inView:(MHVTypeView *) view;
-(MHVTask *) downloadItemsWithKeys:(NSArray *) keys typeID:(NSString *) typeID inView:(MHVTypeView *) view;
//
// Fetch items with given keys into the local store
// Always retrieves the LATEST item for the key
// In the callback, MHVTask.result has an MHVItemCollection containing those items that were found
//
-(MHVTask *) getItemsInRecord:(MHVRecordReference *) record withKeys:(NSArray *) keys callback:(MHVTaskCompletion) callback;
-(MHVTask *) getItemsInRecord:(MHVRecordReference *) record forQuery:(MHVItemQuery *) query callback:(MHVTaskCompletion) callback;

// Deprecated. Use MHVSynchronizationMgr & MHVSynchronizedType
-(BOOL) putItem:(MHVItem *) item __deprecated;

//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
// task.result will contain updated keys - in case the items 
// Always retrieves the LATEST item for the keys
//
-(MHVDownloadItemsTask *) downloadItemsInRecord:(MHVRecordReference *) record forKeys:(NSArray *) keys callback:(MHVTaskCompletion) callback;
//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
//
-(MHVDownloadItemsTask *) downloadItemsInRecord:(MHVRecordReference *) record query:(MHVItemQuery *) query callback:(MHVTaskCompletion) callback;
//
// These create new download tasks but do NOT start them.
// You can make the task a child of another task
// 
-(MHVDownloadItemsTask *) newDownloadItemsInRecord:(MHVRecordReference *) record forKeys:(NSArray *) keys callback:(MHVTaskCompletion) callback;
-(MHVDownloadItemsTask *) newDownloadItemsInRecord:(MHVRecordReference *) record forQuery:(MHVItemQuery *) query callback:(MHVTaskCompletion) callback;

@end
