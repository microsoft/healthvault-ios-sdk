//
//  MHVBloodPressureFactory.m
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

#import "MHVBloodPressureFactory.h"

@implementation MHVBloodPressure (HVFactoryMethods)

+(MHVItemCollection *) createRandomForDay:(NSDate *) date
{
    MHVItemCollection* items = [[MHVItemCollection alloc] init];
    
    // Typically 1 a day
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = 8;  // Morning
    dateTime.time.minute = 35;
    
    [items addObject:[MHVBloodPressure createRandomForDate:dateTime withPulse:TRUE]];
    
    return items;
}

@end

@implementation MHVBloodPressure (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ mmHg", [self toString]];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end

