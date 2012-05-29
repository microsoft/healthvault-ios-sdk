//
//  HVRecordReference.h
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
#import "HVItemQuery.h"
#import "HVAsyncTask.h"
#import "HVGetItemsTask.h"
#import "HVPutItemsTask.h"
#import "HVRemoveItemsTask.h"

@interface HVRecordReference : HVType
{
    NSString *m_id;
    NSString *m_personID;
}

@property (readwrite, nonatomic, retain) NSString* ID;
@property (readwrite, nonatomic, retain) NSString* personID;

@end

@interface HVRecordReference (HVMethods)

//-------------------------
//
// Get Data
// Each of these work with an HVGetItemsTask
//
// On success, the result property of HVTask will contain any found items
// You can also do: ((HVGetItemsTask *) task).itemsRetrieved in your callback
//
//-------------------------

//
// Get all items of the given type
//
-(HVGetItemsTask *) getItemsForClass:(Class) cls callback:(HVTaskCompletion) callback;
-(HVGetItemsTask *) getItemsForType:(NSString *) typeID callback:(HVTaskCompletion) callback;
//
// Get the item with the given key. ItemKey includes a version stamp
//
-(HVGetItemsTask *) getItemWithKey:(HVItemKey *) key callback:(HVTaskCompletion) callback;
//
// Get item with the given ID. If the item exists, will retrieve the latest version
//
-(HVGetItemsTask *) getItemWithID:(NSString *) itemID callback:(HVTaskCompletion) callback;

//
// Get all items matching the given query
//
-(HVGetItemsTask *) getItems:(HVItemQuery *) query callback:(HVTaskCompletion) callback;

-(HVGetItemsTask *) getPendingItems:(HVPendingItemCollection *) items callback:(HVTaskCompletion) callback;

//-------------------------
//
// Put Data
// Each of these work with a HVPutItemsTask
//
//-------------------------
-(HVPutItemsTask *) putItem:(HVItem *) item callback:(HVTaskCompletion) callback;
-(HVPutItemsTask *) putItems:(HVItemCollection *) items callback:(HVTaskCompletion)callback;

//-------------------------
//
// Remove Data
//
//-------------------------
-(HVRemoveItemsTask *) removeItemWithKey:(HVItemKey *) key callback:(HVTaskCompletion) callback;
-(HVRemoveItemsTask *) removeItemsWithKeys:(HVItemKeyCollection *)keys callback:(HVTaskCompletion)callback;


@end