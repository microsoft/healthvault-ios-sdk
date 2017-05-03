//
//  HVItemView.m
//  HVLib
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

#import "HVCommon.h"
#import "HVItemView.h"

static NSString* const c_element_section = @"section";
static NSString* const c_element_xml = @"xml";
static NSString* const c_element_versions = @"type-version-format";

@interface HVItemView (HVPrivate) 

-(HVStringCollection *) createStringsFromSections;
-(enum HVItemSection) stringsToSections:(HVStringCollection *) strings;

@end

@implementation HVItemView

@synthesize sections = m_sections;
@synthesize transforms = m_transforms;
@synthesize typeVersions = m_typeVersions;

-(HVStringCollection *)transforms
{
    if (!m_transforms)
    {
        m_transforms = [[HVStringCollection alloc] init];
    }
    return m_transforms;
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_sections = HVItemSection_Standard;
    
    m_typeVersions = [[HVStringCollection alloc] init];
    
    HVCHECK_NOTNULL(m_typeVersions);
   
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_ARRAYOPTIONAL(m_typeVersions, HVClientError_InvalidItemView);
    
    HVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    HVStringCollection *sections = nil;
    @try
    {
        sections = [self createStringsFromSections];
        [writer writeElementArray:c_element_section elements:sections];
        if (m_sections & HVItemSection_Data)
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
    HVStringCollection* sections = nil;
    @try {
        
        sections = [reader readStringElementArray:c_element_section];
        m_transforms = [reader readStringElementArray:c_element_xml];
        m_typeVersions = [reader readStringElementArray:c_element_versions];
        
        m_sections = [self stringsToSections:sections];
        if ([m_transforms containsString:c_emptyString])
        {
            m_sections |= HVItemSection_Data;
            [m_transforms removeString:c_emptyString];
        }
     }

    @finally {
        sections = nil;
    }
}

@end

@implementation HVItemView (HVPrivate)

-(HVStringCollection *) createStringsFromSections
{
    HVStringCollection* array = [[HVStringCollection alloc] init];
    if (m_sections & HVItemSection_Core)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Core)];
    }
    if (m_sections & HVItemSection_Audits)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Audits)];
    }
    if (m_sections & HVItemSection_Blobs)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Blobs)];
    }
    if (m_sections & HVItemSection_Tags)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Tags)];
    }
    if (m_sections & HVItemSection_Permissions)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Permissions)];
    }
    if (m_sections & HVItemSection_Signatures)
    {
        [array addObject:HVItemSectionToString(HVItemSection_Signatures)];
    }
    
    return array;
}

-(enum HVItemSection) stringsToSections:(HVStringCollection *) strings
{
    enum HVItemSection section = HVItemSection_None;
    
    if (![HVStringCollection isNilOrEmpty:strings])
    {
        for (NSString* string in strings) {
            section |= HVItemSectionFromString(string); 
        }
    }
    
    return section;
}

@end
