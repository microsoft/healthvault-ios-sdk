//
// MHVLabTestResults.m
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
//
#import "MHVCommon.h"
#import "MHVLabTestResults.h"

static NSString *const c_typeid = @"5800eab5-a8c2-482a-a4d6-f1db25ae08c3";
static NSString *const c_typename = @"lab-test-results";

static const xmlChar *x_element_when = XMLSTRINGCONST("when");
static NSString *const c_element_labGroup = @"lab-group";
static const xmlChar *x_element_labGroup = XMLSTRINGCONST("lab-group");
static const xmlChar *x_element_orderedBy = XMLSTRINGCONST("ordered-by");

@implementation MHVLabTestResults

- (MHVLabTestResultsGroup *)firstGroup
{
    if ([MHVCollection isNilOrEmpty:self.labGroup])
    {
        return nil;
    }

    return [self.labGroup itemAtIndex:0];
}

- (MHVLabTestResultsGroupCollection *)getAllGroups
{
    MHVLabTestResultsGroupCollection *allGroups = [[MHVLabTestResultsGroupCollection alloc] init];

    MHVCHECK_NOTNULL(allGroups);

    if (self.labGroup)
    {
        [self.labGroup addItemsToCollection:allGroups];
    }

    return allGroups;

   LError:
    return nil;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_OPTIONAL(self.when);
    MHVVALIDATE_ARRAY(self.labGroup, MHVclientError_InvalidLabTestResults);
    MHVVALIDATE_OPTIONAL(self.orderedBy);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:self.when];
    [writer writeElementArray:c_element_labGroup elements:self.labGroup.toArray];
    [writer writeElementXmlName:x_element_orderedBy content:self.orderedBy];
}

- (void)deserialize:(XReader *)reader
{
    self.when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    self.labGroup = (MHVLabTestResultsGroupCollection *)[reader readElementArrayWithXmlName:x_element_labGroup asClass:[MHVLabTestResultsGroup class] andArrayClass:[MHVLabTestResultsGroupCollection class]];
    self.orderedBy = [reader readElementWithXmlName:x_element_orderedBy asClass:[MHVOrganization class]];
}

- (NSString *)toString
{
    MHVLabTestResultsGroup *group = [self firstGroup];

    if (!group)
    {
        return c_emptyString;
    }

    return [[group groupName] toString];
}

- (NSString *)description
{
    return [self toString];
}

+ (MHVItem *)newItem
{
    return [[MHVItem alloc] initWithType:[MHVLabTestResults typeID]];
}

+ (NSString *)typeID
{
    return c_typeid;
}

+ (NSString *)XRootElement
{
    return c_typename;
}

- (NSString *)typeName
{
    return NSLocalizedString(@"Lab Test Results", @"Lab Test Results Type Name");
}

@end
