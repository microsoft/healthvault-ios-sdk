//
// MHVVocabParams.m
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
#import "MHVVocabParams.h"

static NSString *const c_element_vocabkey = @"vocabulary-key";
static NSString *const c_element_culture = @"fixed-culture";

@interface MHVVocabParams ()

@property (readwrite, nonatomic, strong) MHVVocabIdentifierCollection *vocabIDs;

@end

@implementation MHVVocabParams

- (MHVVocabIdentifierCollection *)vocabIDs
{
    if (!_vocabIDs)
    {
        _vocabIDs = [[MHVVocabIdentifierCollection alloc] init];
    }
    
    return _vocabIDs;
}

- (instancetype)initWithVocabID:(MHVVocabIdentifier *)vocabID
{
    MHVCHECK_NOTNULL(vocabID);
    
    self = [super init];
    if (self)
    {
        [_vocabIDs addObject:vocabID];
    }
    return self;
}

- (instancetype)initWithVocabIDs:(MHVVocabIdentifierCollection *)vocabIDs
{
    MHVCHECK_NOTNULL(vocabIDs);
    
    self = [super init];
    if (self)
    {
        _vocabIDs = vocabIDs;
    }
    
    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(self.vocabIDs, MHVClientError_InvalidVocabIdentifier);
    
    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_vocabkey elements:self.vocabIDs.toArray];
    [writer writeElement:c_element_culture boolValue:self.fixedCulture];
}

- (void)deserialize:(XReader *)reader
{
    self.vocabIDs = (MHVVocabIdentifierCollection *)[reader readElementArray:c_element_vocabkey asClass:[MHVVocabIdentifier class] andArrayClass:[MHVVocabIdentifierCollection class]];
    self.fixedCulture = [reader readBoolElement:c_element_culture];
}

@end
