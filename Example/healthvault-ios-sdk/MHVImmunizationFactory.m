//
//  MHVImmunizationFactory.m
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

#import "MHVImmunizationFactory.h"

@implementation MHVImmunization (MHVFactoryMethods)

+(NSArray<MHVThing *> *) createRandomForDay:(NSDate *) date
{
    MHVThing* thing = [MHVImmunization createRandomForDate:[MHVApproxDateTime fromDate:date]];
    return @[thing];
}

+(NSArray<MHVThing *> *) createRandomMetricForDay:(NSDate *) date
{
    return [MHVImmunization createRandomForDay:date];
}

@end

@implementation MHVImmunization (MHVDisplay)

-(NSString *) detailsString
{
    return [NSString stringWithFormat:@"%@ [Administered: %@]", self.name.description, self.administeredDate ? self.administeredDate.description : @""];
}

-(NSString *) detailsStringMetric
{
    return [self detailsString];
}

@end
