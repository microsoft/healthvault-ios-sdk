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
-(HVGetItemsTask *) getItemWithKey:(HVItemKey *) key ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;
//
// Get item with the given ID. If the item exists, will retrieve the latest version
//
-(HVGetItemsTask *) getItemWithID:(NSString *) itemID callback:(HVTaskCompletion) callback;
-(HVGetItemsTask *) getItemWithID:(NSString *) itemID ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;

//
// Get all items matching the given query
//
-(HVGetItemsTask *) getItems:(HVItemQuery *) query callback:(HVTaskCompletion) callback;

-(HVGetItemsTask *) getPendingItems:(HVPendingItemCollection *) items callback:(HVTaskCompletion) callback;
-(HVGetItemsTask *) getPendingItems:(HVPendingItemCollection *) items ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;

//-------------------------
//
// Put Data
// Each of these work with a HVPutItemsTask
//
//-------------------------
-(HVPutItemsTask *) putItem:(HVItem *) item callback:(HVTaskCompletion) callback;
-(HVPutItemsTask *) putItems:(HVItemCollection *) items callback:(HVTaskCompletion)callback;

//
// Update Item assumes that you fetched items from HV, made some changes, and are now 
// writing it back. It will automatically CLEAR system fields that are *typically* set by the HV service, 
// such as effectiveDates. It does so by calling [item prepareForPut]. 
// If the fields are not cleared, the system data present in the item will get persisted into HV. 
//
// If you wish to manage this information yourself, you should call putItem/putItems directly
//
// Since updateItem alters the item object you supplied, you should call getItem again.
// This will give you the latest updated Xml from HV. Alternatively, you can call [item shallowClone] and
// pass that to updateItem
//
-(HVPutItemsTask *) updateItem:(HVItem *) item callback:(HVTaskCompletion) callback;
-(HVPutItemsTask *) updateItems:(HVItemCollection *) items callback:(HVTaskCompletion)callback;

//-------------------------
//
// Remove Data
//
//-------------------------
-(HVRemoveItemsTask *) removeItemWithKey:(HVItemKey *) key callback:(HVTaskCompletion) callback;
-(HVRemoveItemsTask *) removeItemsWithKeys:(HVItemKeyCollection *)keys callback:(HVTaskCompletion)callback;


@end