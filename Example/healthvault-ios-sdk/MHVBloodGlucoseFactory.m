//
//  MHVBloodGlucoseFactory.m
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

#import "MHVBloodGlucoseFactory.h"
#import "MHVRandom.h"

@implementation MHVBloodGlucose (MHVFactoryMethods)

+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date
{
    return [MHVBloodGlucose createRandomForDay:date metric:FALSE];
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVBloodGlucose createRandomForDay:date metric:TRUE];
}

+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date metric:(BOOL)metric
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    //
    // Create 3 BG measurements per day
    //
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:6 max:8]; // Morning;
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    MHVThing* thing = [MHVBloodGlucose createRandomForDate:dateTime metric:metric];
    thing.bloodGlucose.context = [[MHVBloodGlucose vocabForContext] codableValueForText:@"After breakfast" andCode:@"AfterBreakfast"];
    
    [things addObject:thing];
    
    dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:11 max:13]; // Afternoon;
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    thing = [MHVBloodGlucose createRandomForDate:dateTime metric:metric];
    thing.bloodGlucose.context = [[MHVBloodGlucose vocabForContext] codableValueForText:@"After lunch" andCode:@"AfterLunch"];
    [things addObject:thing];
    
    dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:18 max:20]; // Evening;
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    thing = [MHVBloodGlucose createRandomForDate:dateTime metric:metric];
    thing.bloodGlucose.context = [[MHVBloodGlucose vocabForContext] codableValueForText:@"After dinner" andCode:@"AfterDinner"];
    [things addObject:thing];
    
    return things;    
}

@end

@implementation MHVBloodGlucose (MHVDisplay)

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
