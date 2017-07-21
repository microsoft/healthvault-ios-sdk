//
//  MHVEmotionalStateFactory.m
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
//

#import "MHVEmotionalStateFactory.h"
#import "MHVRandom.h"

@implementation MHVEmotionalState (MHVFactoryMethods)

+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    //
    // Two mood checks per day
    //
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:7 max:11];
    [things addObject:[MHVEmotionalState createRandomForDate:dateTime]];
    
    dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:16 max:20];
    
    [things addObject:[MHVEmotionalState createRandomForDate:dateTime]];
    
    return things;
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVEmotionalState createRandomForDay:date];
}

@end

@implementation MHVEmotionalState (MHVDisplay)

-(NSString *)detailsString
{
    return [self toString];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
