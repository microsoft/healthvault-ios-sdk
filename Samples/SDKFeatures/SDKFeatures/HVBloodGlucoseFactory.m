//
//  HVBloodGlucoseFactory.m
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

#import "HVBloodGlucoseFactory.h"

@implementation HVBloodGlucose (HVFactoryMethods)

+(HVItemCollection *)createRandomForDay:(NSDate *)date
{
    return [HVBloodGlucose createRandomForDay:date metric:FALSE];
}

+(HVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [HVBloodGlucose createRandomForDay:date metric:TRUE];
}

+(HVItemCollection *)createRandomForDay:(NSDate *)date metric:(BOOL)metric
{
    HVItemCollection* items = [[HVItemCollection alloc] init];
    //
    // Create 3 BG measurements per day
    //
    HVDateTime* dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:6 max:8]; // Morning;
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    HVItem* item = [HVBloodGlucose createRandomForDate:dateTime metric:metric];
    item.bloodGlucose.context = [[HVBloodGlucose vocabForContext] codableValueForText:@"After breakfast" andCode:@"AfterBreakfast"];
    
    [items addObject:item];
    
    dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:11 max:13]; // Afternoon;
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    item = [HVBloodGlucose createRandomForDate:dateTime metric:metric];
    item.bloodGlucose.context = [[HVBloodGlucose vocabForContext] codableValueForText:@"After lunch" andCode:@"AfterLunch"];
    [items addObject:item];
    
    dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:18 max:20]; // Evening;
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    item = [HVBloodGlucose createRandomForDate:dateTime metric:metric];
    item.bloodGlucose.context = [[HVBloodGlucose vocabForContext] codableValueForText:@"After dinner" andCode:@"AfterDinner"];
    [items addObject:item];
    
    return items;    
}

@end

@implementation HVBloodGlucose (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%.1f mg/dL [%@, %@]", self.inMgPerDL,
                                                              self.measurementType.description,
                                                              self.context.description];
}

-(NSString *)detailsStringMetric
{
    return [NSString stringWithFormat:@"%.1f mmol/L [%@, %@]", self.inMmolPerLiter,
                                                               self.measurementType.description,
                                                               self.context.description];
}

@end
