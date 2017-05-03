//
//  MHVRecordReference.h
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
#import "MHVItemQuery.h"
#import "MHVAsyncTask.h"
#import "MHVGetItemsTask.h"
#import "MHVPutItemsTask.h"
#import "MHVRemoveItemsTask.h"

@interface MHVRecordReference : MHVType
{
    NSString *m_id;
    NSString *m_personID;
}

@property (readwrite, nonatomic, strong) NSString* ID;
@property (readwrite, nonatomic, strong) NSString* personID;

@end

@interface MHVRecordReference (MHVMethods)

//-------------------------
//
// Get Data
// Each of these work with an MHVGetItemsTask
//
// On success, the result property of MHVTask will contain any found items
// You can also do: ((MHVGetItemsTask *) task).itemsRetrieved in your callback
//
//-------------------------

//
// Get all items of the given type
//
-(MHVGetItemsTask *) getItemsForClass:(Class) cls callback:(HVTaskCompletion) callback;
-(MHVGetItemsTask *) getItemsForType:(NSString *) typeID callback:(HVTaskCompletion) callback;
//
// Get the item with the given key. ItemKey includes a version stamp
//
-(MHVGetItemsTask *) getItemWithKey:(MHVItemKey *) key callback:(HVTaskCompletion) callback;
-(MHVGetItemsTask *) getItemWithKey:(MHVItemKey *) key ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;
//
// Get item with the given ID. If the item exists, will retrieve the latest version
//
-(MHVGetItemsTask *) getItemWithID:(NSString *) itemID callback:(HVTaskCompletion) callback;
-(MHVGetItemsTask *) getItemWithID:(NSString *) itemID ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;

//
// Get all items matching the given query
//
-(MHVGetItemsTask *) getItems:(MHVItemQuery *) query callback:(HVTaskCompletion) callback;

-(MHVGetItemsTask *) getPendingItems:(MHVPendingItemCollection *) items callback:(HVTaskCompletion) callback;
-(MHVGetItemsTask *) getPendingItems:(MHVPendingItemCollection *) items ofType:(NSString *) typeID callback:(HVTaskCompletion) callback;

//-------------------------
//
// Put Data
// Each of these work with a MHVPutItemsTask
//
//-------------------------
-(MHVPutItemsTask *) newItem:(MHVItem *) item callback:(HVTaskCompletion) callback;
-(MHVPutItemsTask *) newItems:(MHVItemCollection *) items callback:(HVTaskCompletion)callback;

-(MHVPutItemsTask *) putItem:(MHVItem *) item callback:(HVTaskCompletion) callback;
-(MHVPutItemsTask *) putItems:(MHVItemCollection *) items callback:(HVTaskCompletion)callback;

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
-(MHVPutItemsTask *) updateItem:(MHVItem *) item callback:(HVTaskCompletion) callback;
-(MHVPutItemsTask *) updateItems:(MHVItemCollection *) items callback:(HVTaskCompletion)callback;

//-------------------------
//
// Remove Data
//
//-------------------------
-(MHVRemoveItemsTask *) removeItemWithKey:(MHVItemKey *) key callback:(HVTaskCompletion) callback;
-(MHVRemoveItemsTask *) removeItemsWithKeys:(MHVItemKeyCollection *)keys callback:(HVTaskCompletion)callback;


@end
