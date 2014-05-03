//
//  HVLabTestResults.m
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
#import "HVLabTestResults.h"

static NSString* const c_typeid = @"5800eab5-a8c2-482a-a4d6-f1db25ae08c3";
static NSString* const c_typename = @"lab-test-results";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static NSString* const c_element_labGroup = @"lab-group";
static const xmlChar* x_element_labGroup = XMLSTRINGCONST("lab-group");
static const xmlChar* x_element_orderedBy = XMLSTRINGCONST("ordered-by");

@implementation HVLabTestResults

@synthesize when = m_when;
@synthesize labGroup = m_labGroup;
@synthesize orderedBy = m_orderedBy;

-(HVLabTestResultsGroup *)firstGroup
{
    if ([NSArray isNilOrEmpty:m_labGroup])
    {
        return nil;
    }
    
    return [m_labGroup itemAtIndex:0];
}

-(void)dealloc
{
    [m_when release];
    [m_labGroup release];
    [m_orderedBy release];
    
    [super dealloc];
}

-(HVLabTestResultsGroupCollection *)getAllGroups
{
    HVLabTestResultsGroupCollection* allGroups = [[[HVLabTestResultsGroupCollection alloc] init] autorelease];
    HVCHECK_NOTNULL(allGroups);
    
    if (m_labGroup)
    {
        [m_labGroup addItemsToCollection:allGroups];
    }
    
    return allGroups;
    
LError:
    return nil;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_ARRAY(m_labGroup, HVclientError_InvalidLabTestResults);
    HVVALIDATE_OPTIONAL(m_orderedBy);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_when, x_element_when);
    HVSERIALIZE_ARRAY(m_labGroup, c_element_labGroup);
    HVSERIALIZE_X(m_orderedBy, x_element_orderedBy);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_when, x_element_when, HVApproxDateTime);
    HVDESERIALIZE_TYPEDARRAY_X(m_labGroup, x_element_labGroup, HVLabTestResultsGroup, HVLabTestResultsGroupCollection);
    HVDESERIALIZE_X(m_orderedBy, x_element_orderedBy, HVOrganization);
}

-(NSString *)toString
{
    HVLabTestResultsGroup* group = [self firstGroup];
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

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVLabTestResults typeID]];
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
