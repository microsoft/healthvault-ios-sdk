//
//  MHVGoal.m
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

#import "MHVGoalsApi.h"
#import "MHVGoalFactory.h"

@implementation MHVGoal (MHVFactoryMethods)

+(NSString *) XRootElement
{
    return @"goals [REST]";
}

+(NSObject *) moreFeatures
{
    return nil;
}

+(Boolean) useRestClient
{
    return YES;
}

+(MHVThingCollection *) createRandomForDay:(NSDate *) date
{
    return [MHVGoal createRandomForDay:date metric:FALSE];
}

+(MHVThingCollection *)createRandomMetricForDay:(NSDate *)date
{
    return [MHVGoal createRandomForDay:date metric:TRUE];
}

+(MHVThingCollection *)createRandomForDay:(NSDate *)date metric:(BOOL)metric
{
    MHVThingCollection* things = [[MHVThingCollection alloc] init];
    //
    // Create 2 entries per day - MOST days. This person really likes to exercise!
    //
    MHVApproxDateTime* approxDateTime = [MHVApproxDateTime fromDate:date];
    approxDateTime.dateTime.time.hour = [MHVRandom randomIntInRangeMin:7 max:9];
    
    [things addObject:[MHVExercise createRandomForDate:approxDateTime metric:metric]];
    
    approxDateTime = [MHVApproxDateTime fromDate:date];
    approxDateTime.dateTime.time.hour = [MHVRandom randomIntInRangeMin:16 max:19];
    
    [things addObject:[MHVExercise createRandomForDate:approxDateTime metric:metric]];
    
    return things;
}

-(void) getDataFromHealthVault
{
    [MHVRemoteMonitoringClient getGoalsWithTypes:nil windowTypes:nil startDate:nil endDate:nil completion:^(MHVGoalsResponse *_Nullable response, NSError *_Nullable error) {
        int i = 0;
        i++;
    }];
}

@end

@implementation MHVGoal (MHVDisplay)

-(NSString *)detailsString
{
    return [NSString stringWithFormat:@"%@ [%@-%@]", self._description, self.startDate, self.endDate];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

@end
