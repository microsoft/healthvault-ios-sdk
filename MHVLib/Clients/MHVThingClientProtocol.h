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

@protocol MHVThingClientProtocol <NSObject>

- (void)getThingWithThingId:(NSUUID *_Nonnull)thingId
                    recordId:(NSUUID *_Nonnull)recordId
                 completion:(void(^_Nonnull)(MHVThing *_Nullable thing, NSError *_Nullable error))completion;

- (void)getThingsWithQuery:(MHVThingQuery *_Nonnull)
                  recordId:(NSUUID *_Nonnull)recordId
                completion:(void(^_Nonnull)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (void)getThingsForThingClass:(Class _Nonnull)thingClass
                         query:(MHVThingQuery *_Nonnull)query
                      recordId:(NSUUID *_Nonnull)recordId
                    completion:(void(^_Nonnull)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion;

- (void)createNewThing:(MHVThing *_Nonnull)thing
              recordId:(NSUUID *_Nonnull)recordId
            completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)createNewThings:(MHVThingCollection *_Nonnull)things
              recordId:(NSUUID *_Nonnull)recordId
            completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)updateThing:(MHVThing *_Nonnull)thing
           recordId:(NSUUID *_Nonnull)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)updateThings:(MHVThingCollection *_Nonnull)things
            recordId:(NSUUID *_Nonnull)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)removeThing:(MHVThing *_Nonnull)thing
           recordId:(NSUUID *_Nonnull)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)removeThings:(MHVThingCollection *_Nonnull)things
            recordId:(NSUUID *_Nonnull)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion;

@end
