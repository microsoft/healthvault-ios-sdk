//
// MHVRecordReference.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

@property (readwrite, nonatomic, strong) NSUUID *ID;
@property (readwrite, nonatomic, strong) NSUUID *personID;

// -------------------------
//
// Get Data
// Each of these work with an MHVGetItemsTask
//
// On success, the result property of MHVTask will contain any found items
// You can also do: ((MHVGetItemsTask *) task).itemsRetrieved in your callback
//
// -------------------------

//
// Get all items of the given type
//
- (MHVGetItemsTask *)getItemsForClass:(Class)cls callback:(MHVTaskCompletion)callback;
- (MHVGetItemsTask *)getItemsForType:(NSString *)typeID callback:(MHVTaskCompletion)callback;
//
// Get the item with the given key. ItemKey includes a version stamp
//
- (MHVGetItemsTask *)getItemWithKey:(MHVItemKey *)key callback:(MHVTaskCompletion)callback;
- (MHVGetItemsTask *)getItemWithKey:(MHVItemKey *)key ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;
//
// Get item with the given ID. If the item exists, will retrieve the latest version
//
- (MHVGetItemsTask *)getItemWithID:(NSString *)itemID callback:(MHVTaskCompletion)callback;
- (MHVGetItemsTask *)getItemWithID:(NSString *)itemID ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;

//
// Get all items matching the given query
//
- (MHVGetItemsTask *)getItems:(MHVItemQuery *)query callback:(MHVTaskCompletion)callback;

- (MHVGetItemsTask *)getPendingItems:(MHVPendingItemCollection *)items callback:(MHVTaskCompletion)callback;
- (MHVGetItemsTask *)getPendingItems:(MHVPendingItemCollection *)items ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;

// -------------------------
//
// Put Data
// Each of these work with a MHVPutItemsTask
//
// -------------------------
- (MHVPutItemsTask *)newItem:(MHVItem *)item callback:(MHVTaskCompletion)callback;
- (MHVPutItemsTask *)newItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback;

- (MHVPutItemsTask *)putItem:(MHVItem *)item callback:(MHVTaskCompletion)callback;
- (MHVPutItemsTask *)putItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback;

//
// Update Item assumes that you fetched items from MHV, made some changes, and are now
// writing it back. It will automatically CLEAR system fields that are *typically* set by the MHV service,
// such as effectiveDates. It does so by calling [item prepareForPut].
// If the fields are not cleared, the system data present in the item will get persisted into MHV.
//
// If you wish to manage this information yourself, you should call putItem/putItems directly
//
// Since updateItem alters the item object you supplied, you should call getItem again.
// This will give you the latest updated Xml from MHV. Alternatively, you can call [item shallowClone] and
// pass that to updateItem
//
- (MHVPutItemsTask *)updateItem:(MHVItem *)item callback:(MHVTaskCompletion)callback;
- (MHVPutItemsTask *)updateItems:(MHVItemCollection *)items callback:(MHVTaskCompletion)callback;

// -------------------------
//
// Remove Data
//
// -------------------------
- (MHVRemoveItemsTask *)removeItemWithKey:(MHVItemKey *)key callback:(MHVTaskCompletion)callback;
- (MHVRemoveItemsTask *)removeItemsWithKeys:(MHVItemKeyCollection *)keys callback:(MHVTaskCompletion)callback;


@end
