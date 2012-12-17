//
//  HVSynchronizedStore.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVAsyncTask.h"
#import "HVItemStore.h"
#import "HVTypeView.h"
#import "HVDownloadItemsTask.h"

@interface HVSynchronizedStore : NSObject
{
    enum HVItemSection m_sections;
    id<HVItemStore> m_localStore;
}

@property (readonly, nonatomic) id<HVItemStore> localStore;
@property (readwrite, nonatomic) enum HVItemSection defaultSections;

-(id) initOverStore:(id<HVObjectStore>) store;
-(id) initOverItemStore:(id<HVItemStore>) store;

//---------------------------------
//
// Operations on items locally available on this machine
//
//---------------------------------

-(HVItem *) getLocalItemWithKey:(HVItemKey *) key;
//
// Retrieve locally stored items for the given keys
// HVItemCollection.count is always == keys.count
// If no local item is found for a key, returns its equivalent position in HVItemCollection
// contains NSNull
//
-(HVItemCollection *) getLocalItemsWithKeys:(NSArray *) keys;

-(HVItem *) getlocalItemWithID:(NSString *) itemID;
-(BOOL) putLocalItem:(HVItem *) item;
-(BOOL) updateItemsInLocalStore:(HVItemCollection *)items;
-(void) removeLocalItemWithKey:(HVItemKey *) key;

//---------------------------------
//
// Operations that go to HealthVault
// They pull items down to the local store
//
//---------------------------------
//
// Downloads items for the given keys and store them locally.
// Always retrieves the LATEST item for the key 
// When complete, notify HVTypeView of completions by calling:
//   - keysNotRetrieved (if error)
//   - itemsRetrieved
//
-(HVTask *) downloadItemsWithKeys:(NSArray *) keys inView:(HVTypeView *) view;
-(HVTask *) downloadItemsWithKeys:(NSArray *) keys typeID:(NSString *) typeID inView:(HVTypeView *) view;
//
// Fetch items with given keys into the local store
// Always retrieves the LATEST item for the key
// In the callback, HVTask.result has an HVItemCollection containing those items that were found
//
-(HVTask *) getItemsInRecord:(HVRecordReference *) record withKeys:(NSArray *) keys callback:(HVTaskCompletion) callback;
-(HVTask *) getItemsInRecord:(HVRecordReference *) record forQuery:(HVItemQuery *) query callback:(HVTaskCompletion) callback;
//
// Currently, puts the given item in the local store
// Future versions may include a reliable async upload queue for offline behavior
//
-(BOOL) putItem:(HVItem *) item;

//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
// task.result will contain updated keys - in case the items 
// Always retrieves the LATEST item for the keys
//
-(HVDownloadItemsTask *) downloadItemsInRecord:(HVRecordReference *) record forKeys:(NSArray *) keys callback:(HVTaskCompletion) callback;
//
// In the callback, use [task checkForSuccess] to confirm that the operation succeeded
//
-(HVDownloadItemsTask *) downloadItemsInRecord:(HVRecordReference *) record query:(HVItemQuery *) query callback:(HVTaskCompletion) callback;
//
// These create new download tasks but do NOT start them.
// You can make the task a child of another task
// 
-(HVDownloadItemsTask *) newDownloadItemsInRecord:(HVRecordReference *) record forKeys:(NSArray *) keys callback:(HVTaskCompletion) callback;
-(HVDownloadItemsTask *) newDownloadItemsInRecord:(HVRecordReference *) record forQuery:(HVItemQuery *) query callback:(HVTaskCompletion) callback;

@end
