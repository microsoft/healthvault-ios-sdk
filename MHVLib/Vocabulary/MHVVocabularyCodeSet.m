//
// MHVVocabularySearchResult.m
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
#import "MHVVocabularyCodeSet.h"

static NSString *const c_element_name = @"name";
static NSString *const c_element_family = @"family";
static NSString *const c_element_version = @"version";
static NSString *const c_element_thing = @"code-item";
static NSString *const c_element_truncated = @"is-vocab-truncated";
static NSString *const c_element_codeset = @"code-set-result";

@implementation MHVVocabularyCodeSet

- (BOOL)hasThings
{
    return (![NSArray isNilOrEmpty:self.things.toArray]);
}

- (MHVVocabularyCodeItemCollection *)things
{
    if (!_vocabularyCodeItems)
    {
        _vocabularyCodeItems = [[MHVVocabularyCodeItemCollection alloc] init];
    }
    
    return _vocabularyCodeItems;
}

- (NSArray *)displayStrings
{
    return (self.vocabularyCodeItems) ? [self.vocabularyCodeItems displayStrings] : nil;
}

- (void)sortVocabularyCodeItemsByDisplayText
{
    if (self.vocabularyCodeItems)
    {
        [self.vocabularyCodeItems sortByDisplayText];
    }
}

- (MHVVocabularyIdentifier *)getVocabularyID
{
    return [[MHVVocabularyIdentifier alloc] initWithFamily:self.family andName:self.name andVersion:self.version];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElement:c_element_family value:self.family];
    [writer writeElement:c_element_version value:self.version];
    [writer writeElementArray:c_element_thing elements:self.things.toArray];
    [writer writeElement:c_element_truncated content:self.isTruncated];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.family = [reader readStringElement:c_element_family];
    self.version = [reader readStringElement:c_element_version];
    self.vocabularyCodeItems = (MHVVocabularyCodeItemCollection *)[reader readElementArray:c_element_thing asClass:[MHVVocabularyCodeItem class] andArrayClass:[MHVVocabularyCodeItemCollection class]];
    self.isTruncated = [reader readElement:c_element_truncated asClass:[MHVBool class]];
}

@end

@implementation MHVVocabularyCodeSetCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVVocabularyCodeSet class];
    }
    
    return self;
}

@end

@implementation MHVVocabularySearchResults

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
    self.match = [reader readElement:c_element_codeset asClass:[MHVVocabularyCodeSet class]];
}

@end
