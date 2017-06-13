//
// MHVRandom.m
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

#import "MHVRandom.h"

@implementation MHVRandom

+ (uint)randomUintInRangeMin:(uint)min max:(uint)max
{
    if (min < max)
    {
        return min + arc4random_uniform((max - min) + 1);
    }

    return max + arc4random_uniform((min - max) + 1);
}

+ (int)randomIntInRangeMin:(int)min max:(int)max
{
    if (min < max)
    {
        return min + arc4random_uniform((max - min) + 1);
    }

    return max + arc4random_uniform((min - max) + 1);
}

+ (double)randomDouble
{
    return ((double)arc4random_uniform(UINT32_MAX)) / (UINT32_MAX);
}

+ (double)randomDoubleInRangeMin:(int)min max:(int)max
{
    if (min < max)
    {
        return min + arc4random_uniform((max - min)) + [MHVRandom randomDouble];
    }

    return max + arc4random_uniform((min - max)) + [MHVRandom randomDouble];
}

+ (NSDate *)newRandomDayOffsetFromTodayInRangeMin:(int)min max:(int)max
{
    int nextDay = [MHVRandom randomIntInRangeMin:min max:max];

    return [[NSDate alloc] initWithTimeIntervalSinceNow:(nextDay * (24 * 3600))];
}

@end
