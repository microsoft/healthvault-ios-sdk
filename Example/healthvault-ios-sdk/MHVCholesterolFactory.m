//
//  MHVCholesterolFactory.m
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

#import "MHVCholesterolFactory.h"
#import "MHVRandom.h"

@implementation MHVCholesterol (MHVFactoryMethods)

+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date
{
    return [MHVCholesterol createRandomForDay:date metric:FALSE];
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVCholesterol createRandomForDay:date metric:TRUE];
}

+(NSArray<MHVThing *> *) createRandomForDay:(NSDate *) date metric:(BOOL)metric
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    
    // Typically 1 a day
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    dateTime.time.hour = [MHVRandom randomIntInRangeMin:11 max:16];
    dateTime.time.minute = [MHVRandom randomIntInRangeMin:5 max:55];
    
    [things addObject:[MHVCholesterol createRandomForDate:dateTime metric:metric]];
    
    return things;    
}

@end

@implementation MHVCholesterol (MHVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"LDL/HDL: %.1f / %.1f mg/dL", self.ldlValueMgDL, self.hdlValueMgDL];
}

-(NSString *)detailsStringMetric
{
    return [NSString stringWithFormat:@"LDL/HDL: %.1f / %.1f mmol/L", self.ldlValue, self.hdlValue];
}

@end

