//
// MHVItemQuery.h
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
#import "MHVType.h"
#import "MHVInt.h"
#import "MHVItemKey.h"
#import "MHVItemFilter.h"
#import "MHVItemView.h"

@interface MHVItemQuery : MHVType

@property (readwrite, nonatomic, strong) NSString *name;
//
// itemIDs, keys, and clientIDs are a CHOICE.
// You can specify items for one only one of them in a single query
//
@property (readonly, nonatomic, strong) MHVStringCollection *itemIDs;
@property (readonly, nonatomic, strong) MHVItemKeyCollection *keys;
@property (readonly, nonatomic, strong) MHVStringCollection *clientIDs;
//
// constrain results (where clauses
//
@property (readonly, nonatomic, strong) MHVItemFilterCollection *filters;
//
// What format to pull data down in
//
@property (readwrite, nonatomic, strong) MHVItemView *view;

@property (readwrite, nonatomic) int maxResults;
@property (readwrite, nonatomic) int maxFullResults;

- (instancetype)initWithTypeID:(NSString *)typeID;
- (instancetype)initWithFilter:(MHVItemFilter *)filter;
- (instancetype)initWithItemKey:(MHVItemKey *)key;
- (instancetype)initWithItemKeys:(NSArray *)keys;
- (instancetype)initWithItemIDs:(NSArray *)ids;
- (instancetype)initWithItemID:(NSString *)itemID;
- (instancetype)initWithPendingItems:(MHVCollection *)pendingItems;
- (instancetype)initWithItemKey:(MHVItemKey *)key andType:(NSString *)typeID;
- (instancetype)initWithItemID:(NSString *)itemID andType:(NSString *)typeID;
- (instancetype)initWithClientID:(NSString *)clientID andType:(NSString *)typeID;

@end

@interface MHVItemQueryCollection : MHVCollection

- (void)addItem:(MHVItemQuery *)query;
- (MHVItemQuery *)itemAtIndex:(NSUInteger)index;

@end
