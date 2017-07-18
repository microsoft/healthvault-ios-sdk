//
//  MHVCachedRecord+Cache.m
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

#import "MHVCachedRecord+Cache.h"
#import "MHVCachedThing+CoreDataClass.h"
#import "MHVPendingThingOperation+CoreDataClass.h"

@implementation MHVCachedRecord (Cache)

- (MHVCachedThing *)thingWithThingId:(NSString *)thingId
{
    for (MHVCachedThing *cachedThing in self.things)
    {
        if ([cachedThing.thingId isEqualToString:thingId])
        {
            return cachedThing;
        }
    }
    return nil;
}


- (MHVPendingThingOperation *)pendingThingOperationWithIdentifier:(NSString *)identifier
{
    for (MHVPendingThingOperation *operation in self.pendingThingOperations)
    {
        if ([operation.identifier isEqualToString:identifier])
        {
            return operation;
        }
    }
    return nil;
}

@end
