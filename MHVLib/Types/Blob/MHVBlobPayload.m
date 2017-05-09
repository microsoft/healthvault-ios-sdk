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

@property (readwrite, nonatomic, strong) MHVBlobPayloadItemCollection *items;

@end

@implementation MHVBlobPayload

- (MHVBlobPayloadItemCollection *)items
{
    MHVENSURE(_items, MHVBlobPayloadItemCollection);
    return _items;
}

- (BOOL)hasItems
{
    return ![MHVCollection isNilOrEmpty:self.items];
}

- (MHVBlobPayloadItem *)getDefaultBlob
{
    return [self getBlobNamed:c_emptyString];
}

- (MHVBlobPayloadItem *)getBlobNamed:(NSString *)name
{
    if (!self.hasItems)
    {
        return nil;
    }
    
    return [self.items getBlobNamed:name];
}

- (NSURL *)getUrlForBlobNamed:(NSString *)name
{
    MHVBlobPayloadItem *blob = [self getBlobNamed:name];
    
    if (!blob)
    {
        return nil;
    }
    
    return [NSURL URLWithString:blob.blobUrl];
}

- (BOOL)addOrUpdateBlob:(MHVBlobPayloadItem *)blob
{
    MHVCHECK_NOTNULL(blob);
    
    if (self.items)
    {
        NSUInteger existingIndex = [self.items indexOfBlobNamed:blob.name];
        if (existingIndex != NSNotFound)
        {
            [self.items removeObjectAtIndex:existingIndex];
        }
    }
    
    MHVENSURE(self.items, MHVBlobPayloadItemCollection);
    MHVCHECK_NOTNULL(self.items);
    
    [self.items addObject:blob];
    
    return TRUE;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(self.items, MHVClientError_InvalidBlobInfo);
    
    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_blob elements:self.items.toArray];
}

- (void)deserialize:(XReader *)reader
{
    self.items = (MHVBlobPayloadItemCollection *)[reader readElementArray:c_element_blob
                                                                  asClass:[MHVBlobPayloadItem class]
                                                            andArrayClass:[MHVBlobPayloadItemCollection class]];
}

@end
