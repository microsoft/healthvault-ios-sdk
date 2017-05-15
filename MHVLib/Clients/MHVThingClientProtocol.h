//
//  MHVThingClientProtocol.h
//  MHVLib
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

#import "MHVClientProtocol.h"

@protocol MHVTaskProgressProtocol
@class MHVThing, MHVThingQuery, MHVThingCollection;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingClientProtocol <NSObject>

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getThingWithThingId:(NSUUID *)thingId
                                                           recordId:(NSUUID *)recordId
                                                         completion:(void(^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getThingsWithQuery:(MHVThingQuery *)
                                                          recordId:(NSUUID *)recordId
                                                        completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getThingsForThingClass:(Class )thingClass
                                                                 query:(MHVThingQuery *)query
                                                              recordId:(NSUUID *)recordId
                                                            completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)createNewThing:(MHVThing *)thing
                                                      recordId:(NSUUID *)recordId
                                                    completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)createNewThings:(MHVThingCollection *)things
                                                       recordId:(NSUUID *)recordId
                                                     completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)updateThing:(MHVThing *)thing
                                                   recordId:(NSUUID *)recordId
                                                 completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)updateThings:(MHVThingCollection *)things
                                                    recordId:(NSUUID *)recordId
                                                  completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)removeThing:(MHVThing *)thing
                                                   recordId:(NSUUID *)recordId
                                                 completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)removeThings:(MHVThingCollection *)things
                                                    recordId:(NSUUID *)recordId
                                                  completion:(void(^_Nullable)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
