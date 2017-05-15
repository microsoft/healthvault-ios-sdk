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
#import "MHVThingQuery.h"
#import "MHVAsyncTask.h"
#import "MHVGetThingsTask.h"
#import "MHVPutThingsTask.h"
#import "MHVRemoveThingsTask.h"

@interface MHVRecordReference : MHVType

@property (readwrite, nonatomic, strong) NSString *ID;
@property (readwrite, nonatomic, strong) NSString *personID;

// -------------------------
//
// Get Data
// Each of these work with an MHVGetThingsTask
//
// On success, the result property of MHVTask will contain any found things
// You can also do: ((MHVGetThingsTask *) task).thingsRetrieved in your callback
//
// -------------------------

//
// Get all things of the given type
//
- (MHVGetThingsTask *)getThingsForClass:(Class)cls callback:(MHVTaskCompletion)callback;
- (MHVGetThingsTask *)getThingsForType:(NSString *)typeID callback:(MHVTaskCompletion)callback;
//
// Get the thing with the given key. ThingKey includes a version stamp
//
- (MHVGetThingsTask *)getThingWithKey:(MHVThingKey *)key callback:(MHVTaskCompletion)callback;
- (MHVGetThingsTask *)getThingWithKey:(MHVThingKey *)key ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;
//
// Get thing with the given ID. If the thing exists, will retrieve the latest version
//
- (MHVGetThingsTask *)getThingWithID:(NSString *)thingID callback:(MHVTaskCompletion)callback;
- (MHVGetThingsTask *)getThingWithID:(NSString *)thingID ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;

//
// Get all things matching the given query
//
- (MHVGetThingsTask *)getThings:(MHVThingQuery *)query callback:(MHVTaskCompletion)callback;

- (MHVGetThingsTask *)getPendingThings:(MHVPendingThingCollection *)things callback:(MHVTaskCompletion)callback;
- (MHVGetThingsTask *)getPendingThings:(MHVPendingThingCollection *)things ofType:(NSString *)typeID callback:(MHVTaskCompletion)callback;

// -------------------------
//
// Put Data
// Each of these work with a MHVPutThingsTask
//
// -------------------------
- (MHVPutThingsTask *)newThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback;
- (MHVPutThingsTask *)newThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback;

- (MHVPutThingsTask *)putThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback;
- (MHVPutThingsTask *)putThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback;

//
// Update Thing assumes that you fetched things from MHV, made some changes, and are now
// writing it back. It will automatically CLEAR system fields that are *typically* set by the MHV service,
// such as effectiveDates. It does so by calling [thing prepareForPut].
// If the fields are not cleared, the system data present in the thing will get persisted into MHV.
//
// If you wish to manage this information yourself, you should call putThing/putThings directly
//
// Since updateThing alters the thing object you supplied, you should call getThing again.
// This will give you the latest updated Xml from MHV. Alternatively, you can call [thing shallowClone] and
// pass that to updateThing
//
- (MHVPutThingsTask *)updateThing:(MHVThing *)thing callback:(MHVTaskCompletion)callback;
- (MHVPutThingsTask *)updateThings:(MHVThingCollection *)things callback:(MHVTaskCompletion)callback;

// -------------------------
//
// Remove Data
//
// -------------------------
- (MHVRemoveThingsTask *)removeThingWithKey:(MHVThingKey *)key callback:(MHVTaskCompletion)callback;
- (MHVRemoveThingsTask *)removeThingsWithKeys:(MHVThingKeyCollection *)keys callback:(MHVTaskCompletion)callback;


@end
