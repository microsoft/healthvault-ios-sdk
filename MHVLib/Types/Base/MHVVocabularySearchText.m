//
// MHVVocabularySearchText.m
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
#import "MHVVocabularySearchText.h"

NSString *MHVVocabularyMatchTypeToString(MHVVocabularyMatchType type)
{
    switch (type)
    {
        case MHVVocabularyMatchTypeFullText:
            return @"FullText";

        case MHVVocabularyMatchTypePrefix:
            return @"Prefix";

        default:
            break;
    }

    return c_emptyString;
}

MHVVocabularyMatchType MHVVocabularyMatchTypeFromString(NSString *string)
{
    if ([string isEqualToString:@"FullText"])
    {
        return MHVVocabularyMatchTypeFullText;
    }

    if ([string isEqualToString:@"Prefix"])
    {
        return MHVVocabularyMatchTypePrefix;
    }

    return MHVVocabularyMatchTypeNone;
}

static NSString *const c_attribute_matchType = @"search-mode";

@implementation MHVVocabularySearchText

- (void)serializeAttributes:(XWriter *)writer
{
    NSString *matchType = MHVVocabularyMatchTypeToString(self.matchType);

    [writer writeAttribute:c_attribute_matchType value:matchType];
}

- (void)deserializeAttributes:(XReader *)reader
{
    NSString *mode = nil;

    mode = [reader readAttribute:c_attribute_matchType];
    if (![NSString isNilOrEmpty:mode])
    {
        self.matchType = MHVVocabularyMatchTypeFromString(mode);
    }
}

@end
