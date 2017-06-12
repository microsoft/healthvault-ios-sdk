//
// MHVUser.m
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
#import "MHVUser.h"
#import "MHVRecord.h"

static NSString *const c_element_name = @"name";
static NSString *const c_element_recordarray = @"records";
static NSString *const c_element_record = @"record";
static NSString *const c_element_current = @"current";
static NSString *const c_element_environment = @"environment";
static NSString *const c_element_instanceID = @"instanceID";

@implementation MHVUser

- (BOOL)hasRecords
{
    return (![MHVCollection isNilOrEmpty:self.records]);
}

- (void)setCurrentRecordIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex > self.records.count)
    {
        currentIndex = 0;
    }

    _currentRecordIndex = currentIndex;
}

- (MHVRecord *)currentRecord
{
    if ([MHVCollection isNilOrEmpty:self.records])
    {
        return nil;
    }

    return [self.records objectAtIndex:self.currentRecordIndex];
}

- (BOOL)hasEnvironment
{
    return ![NSString isNilOrEmpty:self.environment];
}

- (BOOL)hasInstanceID
{
    return ![NSString isNilOrEmpty:self.instanceID];
}

- (void)clear
{
    self.name = nil;
    self.records = nil;
    self.currentRecordIndex = 0;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    if (self.records)
    {
        for (MHVRecord *record in self.records)
        {
            MHVCHECK_RESULT([record validate]);
        }
    }

    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElementArray:c_element_recordarray thingName:c_element_record elements:self.records.toArray];
    [writer writeElement:c_element_current intValue:(int)self.currentRecordIndex];
    [writer writeElement:c_element_environment value:self.environment];
    [writer writeElement:c_element_instanceID value:self.instanceID];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.records = (MHVRecordCollection *)[reader readElementArray:c_element_recordarray thingName:c_element_record asClass:[MHVRecord class] andArrayClass:[MHVRecordCollection class]];
    self.currentRecordIndex = [reader readIntElement:c_element_current];
    self.environment = [reader readStringElement:c_element_environment];
    self.instanceID = [reader readStringElement:c_element_instanceID];
}

@end
