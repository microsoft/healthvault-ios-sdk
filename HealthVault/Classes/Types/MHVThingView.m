//
// MHVThingView.m
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
#import "MHVThingView.h"

static NSString *const c_element_section = @"section";
static NSString *const c_element_xml = @"xml";
static NSString *const c_element_versions = @"type-version-format";

@interface MHVThingView ()

@property (readwrite, nonatomic, strong) MHVStringCollection *transforms;
@property (readwrite, nonatomic, strong) MHVStringCollection *typeVersions;

@end

@implementation MHVThingView

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
        _sections = MHVThingSection_Standard;

        _typeVersions = [[MHVStringCollection alloc] init];

        MHVCHECK_NOTNULL(_typeVersions);
    }

    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_ARRAYOPTIONAL(self.typeVersions, MHVClientError_InvalidThingView);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    MHVStringCollection *sections = [self createStringsFromSections];
    [writer writeElementArray:c_element_section elements:sections.toArray];
    if (self.sections & MHVThingSection_Data)
    {
        [writer writeEmptyElement:c_element_xml];
    }
    
    [writer writeElementArray:c_element_xml elements:self.transforms.toArray];
    [writer writeElementArray:c_element_versions elements:self.typeVersions.toArray];
}

- (void)deserialize:(XReader *)reader
{
    MHVStringCollection *sections = [reader readStringElementArray:c_element_section];
    self.transforms = [reader readStringElementArray:c_element_xml];
    self.typeVersions = [reader readStringElementArray:c_element_versions];
    
    self.sections = [self stringsToSections:sections];
    if ([self.transforms containsString:c_emptyString])
    {
        self.sections |= MHVThingSection_Data;
        [self.transforms removeString:c_emptyString];
    }
}

#pragma mark - Internal methods

- (MHVStringCollection *)createStringsFromSections
{
    MHVStringCollection *array = [[MHVStringCollection alloc] init];

    if (self.sections & MHVThingSection_Core)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Core)];
    }

    if (self.sections & MHVThingSection_Audits)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Audits)];
    }

    if (self.sections & MHVThingSection_Blobs)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Blobs)];
    }

    if (self.sections & MHVThingSection_Tags)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Tags)];
    }

    if (self.sections & MHVThingSection_Permissions)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Permissions)];
    }

    if (self.sections & MHVThingSection_Signatures)
    {
        [array addObject:MHVThingSectionToString(MHVThingSection_Signatures)];
    }

    return array;
}

- (MHVThingSection)stringsToSections:(MHVStringCollection *)strings
{
    MHVThingSection section = MHVThingSection_None;

    if (![MHVStringCollection isNilOrEmpty:strings])
    {
        for (NSString *string in strings)
        {
            section |= MHVThingSectionFromString(string);
        }
    }

    return section;
}

@end
