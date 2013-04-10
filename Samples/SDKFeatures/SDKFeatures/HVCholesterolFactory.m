//
//  HVCholesterolFactory.m
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

#import "HVCholesterolFactory.h"

@implementation HVCholesterolV2 (HVFactoryMethods)

+(HVItemCollection *)createRandomForDay:(NSDate *)date
{
    return [HVCholesterolV2 createRandomForDay:date metric:FALSE];
}

+(HVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [HVCholesterolV2 createRandomForDay:date metric:TRUE];
}

+(HVItemCollection *) createRandomForDay:(NSDate *) date metric:(BOOL)metric
{
    HVItemCollection* items = [[[HVItemCollection alloc] init] autorelease];
    
    // Typically 1 a day
    HVDateTime* dateTime = [HVDateTime fromDate:date];
    dateTime.time.hour = [HVRandom randomIntInRangeMin:11 max:16];
    dateTime.time.minute = [HVRandom randomIntInRangeMin:5 max:55];
    
    [items addObject:[HVCholesterolV2 createRandomForDate:dateTime metric:metric]];
    
    return items;    
}

@end

@implementation HVCholesterolV2 (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"LDL/HDL: %.1f / %.1f mg/dL", self.ldlValueMgDL, self.hdlValueMgDL];
}

-(NSString *)detailsStringMetric
{
    return [NSString stringWithFormat:@"LDL/HDL: %.1f / %.1f mmol/L", self.ldlValue, self.hdlValue];
}

@end

