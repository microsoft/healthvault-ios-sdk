//
//  HVItemQueryResult.h
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
#import "HVType.h"
#import "HVItem.h"
#import "HVPendingItem.h"

@class HVGetItemsTask;

@interface HVItemQueryResult : HVType
{
@private
    HVItemCollection* m_items;
    HVPendingItemCollection* m_pendingItems;
    NSString* m_name;
}
//
// Collection of items found
//
@property (readwrite, nonatomic, retain) HVItemCollection* items;
//
// If there were too many matches (depends on server quotas & buffer sizes), HealthVault will
// return only the first chunk of matches. It will also return the keys of the 'pending' items
// You must issue a fresh query to retrieve these pending items. This is easily done using
// convenient init methods on HVItemQuery
//
@property (readwrite, nonatomic, retain) HVPendingItemCollection* pendingItems;
//
// When you issue multiple queries simultaneously, you can give them names
//
@property (readwrite, nonatomic, retain) NSString* name;
//
// Convenience properties
//
@property (readonly, nonatomic) BOOL hasItems;
@property (readonly, nonatomic) BOOL hasPendingItems;

//
// If the query result has pending items, get them and ADD them to the items collection
// 
-(HVTask *) getPendingItemsForRecord:(HVRecordReference *) record withCallback:(HVTaskCompletion) callback;

-(HVTask *) createTaskToGetPendingItemsForRecord:(HVRecordReference *) record withCallback:(HVTaskCompletion) callback;

@end

@interface HVItemQueryResultCollection : HVCollection
@end