//
// MHVBlobPayload.m
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
//
#import "MHVCommon.h"
#import "MHVBlobPayload.h"

static NSString *const c_element_blob = @"blob";

@interface MHVBlobPayload ()

@property (readwrite, nonatomic, strong) MHVBlobPayloadThingCollection *things;

@end

@implementation MHVBlobPayload

- (MHVBlobPayloadThingCollection *)things
{
    if (!_things)
    {
        _things = [[MHVBlobPayloadThingCollection alloc] init];
    }
    
    return _things;
}

- (BOOL)hasThings
{
    return ![MHVCollection isNilOrEmpty:self.things];
}

- (MHVBlobPayloadThing *)getDefaultBlob
{
    return [self getBlobNamed:c_emptyString];
}

- (MHVBlobPayloadThing *)getBlobNamed:(NSString *)name
{
    if (!self.hasThings)
    {
        return nil;
    }
    
    return [self.things getBlobNamed:name];
}

- (NSURL *)getUrlForBlobNamed:(NSString *)name
{
    MHVBlobPayloadThing *blob = [self getBlobNamed:name];
    
    if (!blob)
    {
        return nil;
    }
    
    return [NSURL URLWithString:blob.blobUrl];
}

- (BOOL)addOrUpdateBlob:(MHVBlobPayloadThing *)blob
{
    MHVCHECK_NOTNULL(blob);
    
    if (self.things)
    {
        NSUInteger existingIndex = [self.things indexOfBlobNamed:blob.name];
        if (existingIndex != NSNotFound)
        {
            [self.things removeObjectAtIndex:existingIndex];
        }
    }
    
    if (!self.things)
    {
        self.things = [[MHVBlobPayloadThingCollection alloc] init];
    }

    MHVCHECK_NOTNULL(self.things);
    
    [self.things addObject:blob];
    
    return TRUE;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(self.things, MHVClientError_InvalidBlobInfo);
    
    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_blob elements:self.things.toArray];
}

- (void)deserialize:(XReader *)reader
{
    self.things = (MHVBlobPayloadThingCollection *)[reader readElementArray:c_element_blob
                                                                  asClass:[MHVBlobPayloadThing class]
                                                            andArrayClass:[MHVBlobPayloadThingCollection class]];
}

@end
