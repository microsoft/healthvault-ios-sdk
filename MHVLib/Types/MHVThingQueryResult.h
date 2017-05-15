//
// MHVThingQueryResult.h
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
#import "MHVThing.h"
#import "MHVPendingThing.h"
#import "MHVThingView.h"

@class MHVGetThingsTask;

@interface MHVThingQueryResult : MHVType
//
// Collection of things found
//
@property (readwrite, nonatomic, strong) MHVThingCollection *things;
//
// If there were too many matches (depends on server quotas & buffer sizes), HealthVault will
// return only the first chunk of matches. It will also return the keys of the 'pending' things
// You must issue a fresh query to retrieve these pending things. This is easily done using
// convenient init methods on MHVThingQuery
//
@property (readwrite, nonatomic, strong) MHVPendingThingCollection *pendingThings;
//
// When you issue multiple queries simultaneously, you can give them names
//
@property (readwrite, nonatomic, strong) NSString *name;
//
// Convenience properties
//
@property (readonly, nonatomic) BOOL hasThings;
@property (readonly, nonatomic) BOOL hasPendingThings;
@property (readonly, nonatomic) NSUInteger thingCount;
@property (readonly, nonatomic) NSUInteger pendingCount;
@property (readonly, nonatomic) NSUInteger resultCount;

//
// If the query result has pending things, get them and ADD them to the things collection
//
- (MHVTask *)getPendingThingsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback;
- (MHVTask *)getPendingThingsForRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view withCallback:(MHVTaskCompletion)callback;

- (MHVTask *)createTaskToGetPendingThingsForRecord:(MHVRecordReference *)record withCallback:(MHVTaskCompletion)callback;
- (MHVTask *)createTaskToGetPendingThingsForRecord:(MHVRecordReference *)record thingView:(MHVThingView *)view withCallback:(MHVTaskCompletion)callback;

@end

@interface MHVThingQueryResultCollection : MHVCollection<MHVThingQueryResult *>

@end
