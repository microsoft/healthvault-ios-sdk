//
//  MHVItemView.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString* const c_element_section = @"section";
static NSString* const c_element_xml = @"xml";
static NSString* const c_element_versions = @"type-version-format";

@interface MHVItemView (MHVPrivate) 

-(MHVStringCollection *) createStringsFromSections;
-(enum MHVItemSection) stringsToSections:(MHVStringCollection *) strings;

@end

@implementation MHVItemView

@synthesize sections = m_sections;
@synthesize transforms = m_transforms;
@synthesize typeVersions = m_typeVersions;

-(MHVStringCollection *)transforms
{
    if (!m_transforms)
    {
        m_transforms = [[MHVStringCollection alloc] init];
    }
    return m_transforms;
}

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_sections = MHVItemSection_Standard;
    
    m_typeVersions = [[MHVStringCollection alloc] init];
    
    MHVCHECK_NOTNULL(m_typeVersions);
   
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_ARRAYOPTIONAL(m_typeVersions, MHVClientError_InvalidItemView);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    MHVStringCollection *sections = nil;
    @try
    {
        sections = [self createStringsFromSections];
        [writer writeElementArray:c_element_section elements:sections];
        if (m_sections & MHVItemSection_Data)
        {
            [writer writeEmptyElement:c_element_xml];
        }
        [writer writeElementArray:c_element_xml elements:m_transforms];
        [writer writeElementArray:c_element_versions elements:m_typeVersions];
    }
    @finally {
        sections = nil;
    }    
}

-(void) deserialize:(XReader *)reader
{
    MHVStringCollection* sections = nil;
    @try {
        
        sections = [reader readStringElementArray:c_element_section];
        m_transforms = [reader readStringElementArray:c_element_xml];
        m_typeVersions = [reader readStringElementArray:c_element_versions];
        
        m_sections = [self stringsToSections:sections];
        if ([m_transforms containsString:c_emptyString])
        {
            m_sections |= MHVItemSection_Data;
            [m_transforms removeString:c_emptyString];
        }
     }

    @finally {
        sections = nil;
    }
}

@end

@implementation MHVItemView (MHVPrivate)

-(MHVStringCollection *) createStringsFromSections
{
    MHVStringCollection* array = [[MHVStringCollection alloc] init];
    if (m_sections & MHVItemSection_Core)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Core)];
    }
    if (m_sections & MHVItemSection_Audits)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Audits)];
    }
    if (m_sections & MHVItemSection_Blobs)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Blobs)];
    }
    if (m_sections & MHVItemSection_Tags)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Tags)];
    }
    if (m_sections & MHVItemSection_Permissions)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Permissions)];
    }
    if (m_sections & MHVItemSection_Signatures)
    {
        [array addObject:MHVItemSectionToString(MHVItemSection_Signatures)];
    }
    
    return array;
}

-(enum MHVItemSection) stringsToSections:(MHVStringCollection *) strings
{
    enum MHVItemSection section = MHVItemSection_None;
    
    if (![MHVStringCollection isNilOrEmpty:strings])
    {
        for (NSString* string in strings) {
            section |= MHVItemSectionFromString(string); 
        }
    }
    
    return section;
}

@end
