//
//  MHVWeightFactory.m
//  SDKFeatures
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

#import "MHVWeightFactory.h"
#import "MHVRandom.h"

@implementation MHVWeight (MHVFactoryMethods)

+(NSArray<MHVThing *> *) createRandomForDay:(NSDate *) date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:6 max:8];
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    [things addObject:[MHVWeight createRandomForDate:dateTime]];
    
    return things;
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:6 max:8];
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    [things addObject:[MHVWeight createRandomMetricForDate:dateTime]];
    
    return things;    
}

@end

@implementation MHVWeight (MHVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ lb", [self stringInPounds]];
}

-(NSString *)detailsStringMetric
{
    return [NSString stringWithFormat:@"%@ kg", [self stringInKg]];
}

@end

