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

@interface HVSynchronizedStore : NSObject
{
    enum HVItemSection m_sections;
    id<HVItemStore> m_localStore;
}

@property (readonly, nonatomic) id<HVItemStore> localStore;
@property (readwrite, nonatomic) enum HVItemSection defaultSections;

-(id) initOverStore:(id<HVObjectStore>) store;
-(id) initOverItemStore:(id<HVItemStore>) store;

-(HVItem *) getLocalItemWithKey:(HVItemKey *) key;
-(HVItemCollection *) getLocalItemsWithKeys:(NSArray *) keys;
-(HVItem *) getlocalItemWithID:(NSString *) itemID;
-(BOOL)updateItemsInLocalStore:(HVItemCollection *)items;
-(void) removeLocalItemWithKey:(HVItemKey *) key;

-(HVTask *) downloadItemsWithKeys:(NSArray *) keys inView:(HVTypeView *) view;

-(HVTask *) getItemsInRecord:(HVRecordReference *) record withKeys:(NSArray *) keys callback:(HVTaskCompletion) callback;
-(BOOL) putItem:(HVItem *) item;

//
// The query identifies the items to synchronize
//
-(HVTask *) downloadItemsInRecord:(HVRecordReference *) record query:(HVItemQuery *) query callback:(HVTaskCompletion) callback;
-(HVTask *) newDownloadItemsInRecord:(HVRecordReference *) record forQuery:(HVItemQuery *) query callback:(HVTaskCompletion) callback;

@end
