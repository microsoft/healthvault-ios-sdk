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

@class MHVThing, MHVThingQuery, MHVThingCollection;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingClientProtocol <NSObject>

- (void)getThingWithThingId:(NSUUID *)thingId
                    recordId:(NSUUID *)recordId
                 completion:(void(^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion;

- (void)getThingsWithQuery:(MHVThingQuery *)
                  recordId:(NSUUID *)recordId
                completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (void)getThingsForThingClass:(Class )thingClass
                         query:(MHVThingQuery *)query
                      recordId:(NSUUID *)recordId
                    completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (void)createNewThing:(MHVThing *)thing
              recordId:(NSUUID *)recordId
            completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)createNewThings:(MHVThingCollection *)things
              recordId:(NSUUID *)recordId
            completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)updateThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)removeThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)removeThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
