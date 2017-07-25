//
//  MHVMedicationUsageFactory.m
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

#import "MHVMedicationUsageFactory.h"
#import "MHVRandom.h"

@implementation MHVDailyMedicationUsage (MHVFactoryMethods)

+(NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    
    MHVDate* hvDate = [MHVDate fromDate:date];
    //
    // Record 2-4 things a day
    //
    NSInteger count = [MHVRandom randomIntInRangeMin:2 max:4];
    for (NSInteger i = 0; i < count; ++i)
    {
        [things addObject:[MHVDailyMedicationUsage createRandomForDate:hvDate forDrug:[MHVDailyMedicationUsage pickRandomDrug]]];
    }
    
    return things;
}

+(NSArray<MHVThing *> *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVDailyMedicationUsage createRandomForDay:date];
}

+(NSString *)pickRandomDrug
{
    return pickRandomString(4, @"Lipitor", @"Ibuprofen", @"Celebrex", @"Vitamins");
}

@end

@implementation MHVDailyMedicationUsage (MHVDisplay)

-(NSString *)detailsString
{
    if (self.dosesConsumed)
    {
        return [NSString stringWithFormat:@"%@ [%d doses]", self.drugName.description, self.dosesConsumedValue];
    }
    
    return self.drugName.description;
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
