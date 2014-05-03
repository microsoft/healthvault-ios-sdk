//
//  HVLabTestResultsGroup.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVLabTestResultsGroup.h"

static const xmlChar* x_element_groupName = XMLSTRINGCONST("group-name");
static const xmlChar* x_element_laboratory = XMLSTRINGCONST("laboratory-name");
static const xmlChar* x_element_status = XMLSTRINGCONST("status");
static NSString* const c_element_subGroups = @"sub-groups";
static const xmlChar* x_element_subGroups = XMLSTRINGCONST("sub-groups");
static NSString* const c_element_results = @"results";
static const xmlChar* x_element_results = XMLSTRINGCONST("results");

@implementation HVLabTestResultsGroup

@synthesize groupName = m_groupName;
@synthesize laboratory = m_laboratory;
@synthesize status = m_status;
@synthesize subGroups = m_subGroups;
@synthesize results = m_results;

-(BOOL)hasSubGroups
{
    return ![NSArray isNilOrEmpty:m_subGroups];
}

-(void)dealloc
{
    [m_groupName release];
    [m_laboratory release];
    [m_status release];
    [m_subGroups release];
    [m_results release];
    
    [super dealloc];
}

-(void)addToCollection:(HVLabTestResultsGroupCollection *)groups
{
    [groups addItem:self];
    if (self.hasSubGroups)
    {
        for (NSUInteger i = 0, count = m_subGroups.count; i < count; ++i)
        {
            [[m_subGroups itemAtIndex:i] addToCollection:groups];
        }
    }
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_groupName, HVClientError_InvalidLabTestResultsGroup);
    HVVALIDATE_OPTIONAL(m_laboratory);
    HVVALIDATE_OPTIONAL(m_status);
    HVVALIDATE_ARRAYOPTIONAL(m_subGroups, HVClientError_InvalidLabTestResultsGroup);
    HVVALIDATE_ARRAYOPTIONAL(m_results, HVClientError_InvalidLabTestResultsGroup);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_groupName, x_element_groupName);
    HVSERIALIZE_X(m_laboratory, x_element_laboratory);
    HVSERIALIZE_X(m_status, x_element_status);
    HVSERIALIZE_ARRAY(m_subGroups, c_element_subGroups);
    HVSERIALIZE_ARRAY(m_results, c_element_results);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_groupName, x_element_groupName, HVCodableValue);
    HVDESERIALIZE_X(m_laboratory, x_element_laboratory, HVOrganization);
    HVDESERIALIZE_X(m_status, x_element_status, HVCodableValue);
    HVDESERIALIZE_TYPEDARRAY_X(m_subGroups, x_element_subGroups, HVLabTestResultsGroup, HVLabTestResultsGroupCollection);
    HVDESERIALIZE_TYPEDARRAY_X(m_results, x_element_results, HVLabTestResultsDetails, HVLabTestResultsDetailsCollection);
}

@end

@implementation HVLabTestResultsGroupCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVLabTestResultsGroup class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(HVLabTestResultsGroup *)item
{
    [super addObject:item];
}

-(HVLabTestResultsGroup *)itemAtIndex:(NSUInteger)index
{
    return [super objectAtIndex:index];
}

-(void) addItemsToCollection:(HVLabTestResultsGroupCollection *)groups
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [[self itemAtIndex:i] addToCollection:groups];
    }
}

@end
