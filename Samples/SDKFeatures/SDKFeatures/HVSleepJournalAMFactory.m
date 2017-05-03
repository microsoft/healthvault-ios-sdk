//
//  HVSleepAMFactory.m
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

#import "HVSleepJournalAMFactory.h"

@implementation HVSleepJournalAM (HVFactoryMethods)

+(HVItemCollection *)createRandomForDay:(NSDate *)date
{
    HVItemCollection* items = [[HVItemCollection alloc] init];
    
    HVItem* item = [HVSleepJournalAM createRandomForDate:[HVDateTime fromDate:date] withAwakenings:FALSE];
    NSString* meds = [HVSleepJournalAM pickRandomDrug];
    if (meds)
    {
        item.sleepJournalAM.medicationsBeforeBed = [HVCodableValue fromText:meds];
    }
    
    [items addObject:item];
    
    return items;
}

+(HVItemCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [HVSleepJournalAM createRandomForDay:date];
}

+(NSString *)pickRandomDrug
{
    if ([HVRandom randomDouble] < 0.2)
    {
        return pickRandomString(2, @"Lunesta", @"Melatonin");
    }
    
    return nil;
}

@end

@implementation HVSleepJournalAM (HVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%d mins [%@ - %@]", self.sleepMinutesValue, [self.bedTime toString], [self.wakeTime toString]];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
