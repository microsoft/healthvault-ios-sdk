//
// MHVThingQuery.h
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
#import "MHVThingKey.h"
#import "MHVThingFilter.h"
#import "MHVThingView.h"

@interface MHVThingQuery : MHVType

@property (readwrite, nonatomic, strong) NSString *name;
//
// thingIDs, keys, and clientIDs are a CHOICE.
// You can specify things for one only one of them in a single query
//
@property (readonly, nonatomic, strong) MHVStringCollection *thingIDs;
@property (readonly, nonatomic, strong) MHVThingKeyCollection *keys;
@property (readonly, nonatomic, strong) MHVStringCollection *clientIDs;
//
// constrain results (where clauses
//
@property (readonly, nonatomic, strong) MHVThingFilterCollection *filters;
//
// What format to pull data down in
//
@property (readwrite, nonatomic, strong) MHVThingView *view;

@property (readwrite, nonatomic) int maxResults;
@property (readwrite, nonatomic) int maxFullResults;

- (instancetype)initWithTypeID:(NSString *)typeID;
- (instancetype)initWithFilter:(MHVThingFilter *)filter;
- (instancetype)initWithThingKey:(MHVThingKey *)key;
- (instancetype)initWithThingKeys:(NSArray *)keys;
- (instancetype)initWithThingIDs:(NSArray *)ids;
- (instancetype)initWithThingID:(NSString *)thingID;
- (instancetype)initWithPendingThings:(MHVCollection *)pendingThings;
- (instancetype)initWithThingKey:(MHVThingKey *)key andType:(NSString *)typeID;
- (instancetype)initWithThingID:(NSString *)thingID andType:(NSString *)typeID;
- (instancetype)initWithClientID:(NSString *)clientID andType:(NSString *)typeID;

@end

@interface MHVThingQueryCollection : MHVCollection<MHVThingQuery *>

@end
