//
// MHVTaskRecurrenceTypeEnum.m
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

#import "MHVTaskRecurrenceTypeEnum.h"

@implementation MHVTaskRecurrenceTypeEnum

+ (NSDictionary *)enumMap
{
    return @{
             @"Unknown": @(0),
             @"None": @(1),
             @"Minute": @(2),
             @"Hourly": @(3),
             @"Daily": @(4),
             @"Weekly": @(5),
             @"Monthly": @(6),
             @"Annually": @(7),
             };
}

+ (MHVTaskRecurrenceTypeEnum *)MHVUnknown
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Unknown"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVNone
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"None"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVMinute
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Minute"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVHourly
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Hourly"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVDaily
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Daily"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVWeekly
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Weekly"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVMonthly
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Monthly"];
}

+ (MHVTaskRecurrenceTypeEnum *)MHVAnnually
{
    return [[MHVTaskRecurrenceTypeEnum alloc] initWithString:@"Annually"];
}

@end


