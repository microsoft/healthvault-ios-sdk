//
//  MHVCachedRecord+Cache.h
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
//

#import "MHVCachedRecord+CoreDataClass.h"
#import "MHVThingCacheDatabaseProtocol.h"
@class MHVCachedThing;

NS_ASSUME_NONNULL_BEGIN

@interface MHVCachedRecord (Cache) 

/**
 Find a thing in a record

 @param thingId The thingId to find
 @return the thing
 */
- (MHVCachedThing *_Nullable)thingWithThingId:(NSString *)thingId;

/**
 Returns a MHVPendingThingOperation with a given identifier, or nil if one does not exist.

 @param identifier NSString The identifier for the operation.
 @return MHVPendingThingOperation The operation with the given identifier.
 */
- (MHVPendingThingOperation *_Nullable)pendingThingOperationWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
