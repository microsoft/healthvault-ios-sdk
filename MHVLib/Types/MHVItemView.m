//
// MHVItemView.m
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
#import "MHVItemView.h"

static NSString *const c_element_section = @"section";
static NSString *const c_element_xml = @"xml";
static NSString *const c_element_versions = @"type-version-format";

@interface MHVItemView ()

@property (readwrite, nonatomic, strong) MHVStringCollection *transforms;
@property (readwrite, nonatomic, strong) MHVStringCollection *typeVersions;

@end

@implementation MHVItemView

- (MHVStringCollection *)transforms
{
    if (!_transforms)
    {
        _transforms = [[MHVStringCollection alloc] init];
    }

    return _transforms;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sections = MHVItemSection_Standard;

        _typeVersions = [[MHVStringCollection alloc] init];

        MHVCHECK_NOTNULL(_typeVersions);
    }

    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_ARRAYOPTIONAL(self.typeVersions, MHVClientError_InvalidItemView);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    @try
    {
        MHVStringCollection *sections = [self createStringsFromSections];
        [writer writeElementArray:c_element_section elements:sections.toArray];
        if (self.sections & MHVItemSection_Data)
        {
            [writer writeEmptyElement:c_element_xml];
        }

        [writer writeElementArray:c_element_xml elements:self.transforms.toArray];
        [writer writeElementArray:c_element_versions elements:self.typeVersions.toArray];
    }
    @catch (id exception)
    {
    }
}

- (void)deserialize:(XReader *)reader
{
    @try
    {
        MHVStringCollection *sections = [reader readStringElementArray:c_element_section];
        self.transforms = [reader readStringElementArray:c_element_xml];
        self.typeVersions = [reader readStringElementArray:c_element_versions];

        self.sections = [self stringsToSections:sections];
        if ([self.transforms containsString:c_emptyString])
        {
            self.sections |= MHVItemSection_Data;
            [self.transforms removeString:c_emptyString];
        }
    }
    @catch (id exception)
    {
    }
}

#pragma mark - Internal methods

- (MHVStringCollection *)createStringsFromSections
{
    MHVStringCollection *array = [[MHVStringCollection alloc] init];

    if (self.sections & MHVItemSection_Core)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Core)];
    }

    if (self.sections & MHVItemSection_Audits)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Audits)];
    }

    if (self.sections & MHVItemSection_Blobs)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Blobs)];
    }

    if (self.sections & MHVItemSection_Tags)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Tags)];
    }

    if (self.sections & MHVItemSection_Permissions)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Permissions)];
    }

    if (self.sections & MHVItemSection_Signatures)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Signatures)];
    }

    return array;
}

- (MHVItemSection)stringsToSections:(MHVStringCollection *)strings
{
    MHVItemSection section = MHVItemSection_None;

    if (![MHVStringCollection isNilOrEmpty:strings])
    {
        for (NSString *string in strings)
        {
            section |= MHVItemSectionFromString(string);
        }
    }

    return section;
}

@end
