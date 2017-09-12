//
//  MHVPlanOutcomeTypeEnum.m
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

#import "MHVPlanOutcomeTypeEnum.h"

@implementation MHVPlanOutcomeTypeEnum

+ (NSDictionary *)enumMap
{
    return @{
             @"Unknown": @(0),
             @"StepsPerDay": @(1),
             @"CaloriesPerDay": @(2),
             @"ExerciseHoursPerWeek": @(3),
             @"SleepHoursPerNight": @(4),
             @"MinutesToFallAsleepPerNight": @(5),
             @"Other": @(6),
             };
}

+ (MHVPlanOutcomeTypeEnum *)MHVUnknown
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"Unknown"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVStepsPerDay
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"StepsPerDay"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVCaloriesPerDay
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"CaloriesPerDay"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVExerciseHoursPerWeek
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"ExerciseHoursPerWeek"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVSleepHoursPerNight
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"SleepHoursPerNight"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVMinutesToFallAsleepPerNight
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"MinutesToFallAsleepPerNight"];
}

+ (MHVPlanOutcomeTypeEnum *)MHVOther
{
    return [[MHVPlanOutcomeTypeEnum alloc] initWithString:@"Other"];
}

@end


