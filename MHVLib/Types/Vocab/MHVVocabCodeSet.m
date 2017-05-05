//
// MHVVocabSearchResult.m
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
#import "MHVVocabCodeSet.h"

static NSString *const c_element_name = @"name";
static NSString *const c_element_family = @"family";
static NSString *const c_element_version = @"version";
static NSString *const c_element_item = @"code-item";
static NSString *const c_element_truncated = @"is-vocab-truncated";
static NSString *const c_element_codeset = @"code-set-result";

@implementation MHVVocabCodeSet

- (BOOL)hasItems
{
    return ![NSArray isNilOrEmpty:self.items];
}

- (MHVVocabItemCollection *)items
{
    MHVENSURE(_items, MHVVocabItemCollection);
    return _items;
}

- (NSArray *)displayStrings
{
    return (self.items) ? [self.items displayStrings] : nil;
}

- (void)sortItemsByDisplayText
{
    if (self.items)
    {
        [self.items sortByDisplayText];
    }
}

- (MHVVocabIdentifier *)getVocabID
{
    return [[MHVVocabIdentifier alloc] initWithFamily:self.family andName:self.name];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElement:c_element_family value:self.family];
    [writer writeElement:c_element_version value:self.version];
    [writer writeElementArray:c_element_item elements:self.items];
    [writer writeElement:c_element_truncated content:self.isTruncated];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.family = [reader readStringElement:c_element_family];
    self.version = [reader readStringElement:c_element_version];
    self.items = (MHVVocabItemCollection *)[reader readElementArray:c_element_item asClass:[MHVVocabItem class] andArrayClass:[MHVVocabItemCollection class]];
    self.isTruncated = [reader readElement:c_element_truncated asClass:[MHVBool class]];
}

@end

@implementation MHVVocabSetCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVVocabCodeSet class];
    }

    return self;
}

- (MHVVocabCodeSet *)itemAtIndex:(NSUInteger)index
{
    return (MHVVocabCodeSet *)[super objectAtIndex:index];
}

@end

@implementation MHVVocabSearchResults

- (BOOL)hasMatches
{
    return self.match != nil;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_codeset content:self.match];
}

- (void)deserialize:(XReader *)reader
{
    self.match = [reader readElement:c_element_codeset asClass:[MHVVocabCodeSet class]];
}

@end
