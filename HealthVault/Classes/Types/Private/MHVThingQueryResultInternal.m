//
// MHVThingQueryResultInternal.m
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

#import "MHVCommon.h"
#import "MHVThingQueryResultInternal.h"

static NSString *const c_element_thing = @"thing";
static NSString *const c_element_pending = @"unprocessed-thing-key-info";
static NSString *const c_attribute_name = @"name";

@implementation MHVThingQueryResultInternal

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isCachedResult = NO;
    }
    return self;
}

- (BOOL)hasThings
{
    return !([MHVCollection isNilOrEmpty:self.things]);
}

- (BOOL)hasPendingThings
{
    return !([MHVCollection isNilOrEmpty:self.pendingThings]);
}

- (NSUInteger)thingCount
{
    return self.things ? self.things.count : 0;
}

- (NSUInteger)pendingCount
{
    return self.pendingThings ? self.pendingThings.count : 0;
}

- (NSUInteger)resultCount
{
    return self.thingCount + self.pendingCount;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:self.name];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_thing elements:self.things.toArray];
    [writer writeElementArray:c_element_pending elements:self.pendingThings.toArray];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.name = [reader readAttribute:c_attribute_name];
}

- (void)deserialize:(XReader *)reader
{
    self.things = (MHVThingCollection *)[reader readElementArray:c_element_thing
                                                       asClass:[MHVThing class]
                                                 andArrayClass:[MHVThingCollection class]];
    self.pendingThings = (MHVPendingThingCollection *)[reader readElementArray:c_element_pending
                                                                     asClass:[MHVPendingThing class]
                                                               andArrayClass:[MHVPendingThingCollection class]];
}

#pragma mark - Internal methods

- (void)appendFoundThings:(MHVThingCollection *)things
{
    if (!self.things)
    {
        self.things = [[MHVThingCollection alloc] init];
    }
    
    [self.things addObjectsFromCollection:things];
}

@end

@implementation MHVThingQueryResultCollectionInternal

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVThingQueryResultInternal class];
    }
    return self;
}

- (MHVThingQueryResultInternal *)resultWithName:(NSString *)name
{
    for (MHVThingQueryResultInternal *result in self)
    {
        if ([result.name isEqualToString:name])
        {
            return result;
        }
    }
    return nil;
}

- (void)mergeThingQueryResultCollection:(MHVThingQueryResultCollectionInternal *)collection
{
    for (MHVThingQueryResultInternal *result in collection)
    {
        MHVThingQueryResultInternal *existingResult = [self resultWithName:result.name];
        
        if (existingResult)
        {
            // If the existing result did not contain things, new collections for things and pending things must be initialized
            if (!existingResult.things)
            {
                existingResult.things = [[MHVThingCollection alloc] initWithThings:result.things.toArray];
                
                if (result.pendingThings)
                {
                    existingResult.pendingThings = [[MHVPendingThingCollection alloc] initWithArray:result.pendingThings.toArray];
                }
            }
            else
            {
                [existingResult.things addObjectsFromCollection:result.things];
                [existingResult.pendingThings removeThings:result.things];
            }
        }
        else
        {
            [self addObject:result];
        }
    }
}

@end
