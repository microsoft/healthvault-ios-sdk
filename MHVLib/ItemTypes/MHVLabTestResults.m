//
//  MHVLabTestResults.m
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
//
#import "MHVCommon.h"
#import "MHVLabTestResults.h"

static NSString* const c_typeid = @"5800eab5-a8c2-482a-a4d6-f1db25ae08c3";
static NSString* const c_typename = @"lab-test-results";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static NSString* const c_element_labGroup = @"lab-group";
static const xmlChar* x_element_labGroup = XMLSTRINGCONST("lab-group");
static const xmlChar* x_element_orderedBy = XMLSTRINGCONST("ordered-by");

@implementation MHVLabTestResults

@synthesize when = m_when;
@synthesize labGroup = m_labGroup;
@synthesize orderedBy = m_orderedBy;

-(MHVLabTestResultsGroup *)firstGroup
{
    if ([NSArray isNilOrEmpty:m_labGroup])
    {
        return nil;
    }
    
    return [m_labGroup itemAtIndex:0];
}


-(MHVLabTestResultsGroupCollection *)getAllGroups
{
    MHVLabTestResultsGroupCollection* allGroups = [[MHVLabTestResultsGroupCollection alloc] init];
    MHVCHECK_NOTNULL(allGroups);
    
    if (m_labGroup)
    {
        [m_labGroup addItemsToCollection:allGroups];
    }
    
    return allGroups;
    
LError:
    return nil;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_OPTIONAL(m_when);
    MHVVALIDATE_ARRAY(m_labGroup, MHVclientError_InvalidLabTestResults);
    MHVVALIDATE_OPTIONAL(m_orderedBy);
    
    MHVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementArray:c_element_labGroup elements:m_labGroup];
    [writer writeElementXmlName:x_element_orderedBy content:m_orderedBy];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    m_labGroup = (MHVLabTestResultsGroupCollection *)[reader readElementArrayWithXmlName:x_element_labGroup asClass:[MHVLabTestResultsGroup class] andArrayClass:[MHVLabTestResultsGroupCollection class]];
    m_orderedBy = [reader readElementWithXmlName:x_element_orderedBy asClass:[MHVOrganization class]];
}

-(NSString *)toString
{
    MHVLabTestResultsGroup* group = [self firstGroup];
    if (!group)
    {
        return c_emptyString;
    }
    
    return [[group groupName] toString];
}

-(NSString *)description
{
    return [self toString];
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVLabTestResults typeID]];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Lab Test Results", @"Lab Test Results Type Name");
}

@end
