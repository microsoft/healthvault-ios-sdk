//
//  HVItemTestExtensions.m
//  HVTestLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVRandom.h"
#import "HVItemTestExtensions.h"

NSDate* createRandomDate(void)
{
    return [[HVRandom createRandomDayOffsetFromTodayInRangeMin:0 max:-365] autorelease];
}

@implementation HVItem (HVTestExtensions)

+(HVItem *)createRandomOfClass:(NSString *)className
{
    if ([className isEqualToString:@"HVWeight"])
    {
        return [HVWeight createRandom];
    }
 
    if ([className isEqualToString:@"HVBloodPressure"])
    {
        return [HVBloodPressure createRandom];
    }
    
    return nil;
}

@end

@implementation HVWeight (HVTestExtensions)

+(HVItem *)createRandom
{
    HVItem *item = [HVWeight newItem];
    
    item.weight.inPounds = [HVRandom randomDoubleInRangeMin:120 max:145];
    item.weight.when = [[HVDateTime alloc] initWithDate:createRandomDate()];
    
    return item;    
}

@end

@implementation HVBloodPressure (HVTestExtensions)
    
+(HVItem *)createRandom
{
    HVItem *item = [HVBloodPressure newItem];
    HVBloodPressure *bp = item.bloodPressure;
    
    int s = [HVRandom randomIntInRangeMin:120 max:150];
    int d = s - [HVRandom randomIntInRangeMin:25 max:40];
    
    bp.systolicValue = s;
    bp.diastolicValue = d;
    
    bp.when = [[HVDateTime alloc] initWithDate:createRandomDate()];
    
    return item;
}

@end

@implementation HVTestSynchronizedStore : HVSynchronizedStore

@synthesize failureProbability;

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
{
    if ([HVRandom randomDouble] < self.failureProbability)
    {
        return nil;
    }
    
    return [super getLocalItemWithKey:key];
}


@end