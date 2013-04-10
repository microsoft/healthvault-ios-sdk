//
//  HVWeightFactory.m
//  SDKFeatures
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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

#import "HVWeightFactory.h"

@implementation HVWeight (HVFactoryMethods)

+(HVItemCollection *) createRandomForDay:(NSDate *) date
{
    HVItemCollection* items = [[[HVItemCollection alloc] init] autorelease];
    
    HVDateTime* dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:6 max:8];
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    [items addObject:[HVWeight createRandomForDate:dateTime]];
    
    return items;
}

+(HVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    HVItemCollection* items = [[[HVItemCollection alloc] init] autorelease];
    
    HVDateTime* dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:6 max:8];
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    [items addObject:[HVWeight createRandomMetricForDate:dateTime]];
    
    return items;    
}

@end

@implementation HVWeight (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ lb", [self stringInPounds]];
}

-(NSString *)detailsStringMetric
{
    return [NSString stringWithFormat:@"%@ kg", [self stringInKg]];
}

@end

