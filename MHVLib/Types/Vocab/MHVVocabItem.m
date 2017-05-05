//
// MHVVocabItem.m
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
#import "MHVVocabItem.h"

static const xmlChar *x_element_code = XMLSTRINGCONST("code-value");
static const xmlChar *x_element_displaytext = XMLSTRINGCONST("display-text");
static const xmlChar *x_element_abbrv = XMLSTRINGCONST("abbreviation-text");
static NSString *const c_element_data = @"info-xml";

@implementation MHVVocabItem

- (NSString *)toString
{
    return self.displayText;
}

- (NSString *)description
{
    return [self toString];
}

- (BOOL)matchesDisplayText:(NSString *)text
{
    return [self.displayText caseInsensitiveCompare:[text trim]] == NSOrderedSame;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_STRING(self.code, MHVClientError_InvalidVocabIdentifier);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_code value:self.code];
    [writer writeElementXmlName:x_element_displaytext value:self.displayText];
    [writer writeElementXmlName:x_element_abbrv value:self.abbreviation];
    [writer writeRaw:self.dataXml];
}

- (void)deserialize:(XReader *)reader
{
    self.code = [reader readStringElementWithXmlName:x_element_code];
    self.displayText = [reader readStringElementWithXmlName:x_element_displaytext];
    self.abbreviation = [reader readStringElementWithXmlName:x_element_abbrv];
    self.dataXml = [reader readElementRaw:c_element_data];
}

@end

@implementation MHVVocabItemCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVVocabItem class];
    }

    return self;
}

- (MHVVocabItem *)itemAtIndex:(NSUInteger)index
{
    return (MHVVocabItem *)self[index];
}

- (void)sortByDisplayText
{
    [self sortUsingComparator:^NSComparisonResult (id obj1, id obj2)
    {
        MHVVocabItem *x = (MHVVocabItem *)obj1;
        MHVVocabItem *y = (MHVVocabItem *)obj2;

        return [x.displayText compare:y.displayText];
    } ];
}

- (void)sortByCode
{
    [self sortUsingComparator:^NSComparisonResult (id obj1, id obj2)
    {
        MHVVocabItem *x = (MHVVocabItem *)obj1;
        MHVVocabItem *y = (MHVVocabItem *)obj2;

        return [x.code compare:y.code];
    }];
}

- (NSUInteger)indexOfVocabCode:(NSString *)code
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        MHVVocabItem *item = [self itemAtIndex:i];
        if ([item.code isEqualToString:code])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (MHVVocabItem *)getItemWithCode:(NSString *)code
{
    NSUInteger index = [self indexOfVocabCode:code];

    if (index == NSNotFound)
    {
        return nil;
    }

    return [self itemAtIndex:index];
}

- (NSString *)displayTextForCode:(NSString *)code
{
    MHVVocabItem *vocabItem = [self getItemWithCode:code];

    if (!vocabItem)
    {
        return nil;
    }

    return vocabItem.displayText;
}

- (NSArray *)displayStrings
{
    NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:self.count];

    [self addDisplayStringsTo:strings];
    return strings;
}

- (void)addDisplayStringsTo:(NSMutableArray *)strings
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [strings addObject:[self itemAtIndex:i].displayText];
    }
}

@end
