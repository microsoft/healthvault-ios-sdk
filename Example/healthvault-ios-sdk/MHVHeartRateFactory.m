//
//  MHVHeartRateFactory.m
//  SDKFeatures
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

#import "MHVHeartRateFactory.h"

@implementation MHVHeartRate (MHVFactoryMethods)

+(NSArray<MHVThing *> *) createRandomForDay:(NSDate *) date
{
    NSMutableArray<MHVThing *> *things = [[NSMutableArray alloc] init];
    
    // Typically 1 a day
    MHVDateTime* dateTime = [MHVDateTime fromDate:date];
    
    [things addObject:[MHVHeartRate createRandomForDate:dateTime]];
    
    return things;
}

@end

@implementation MHVHeartRate (MHVDisplay)

-(NSString *)detailsString
{
    return [self toString];
}

-(NSString *)detailsStringMetric
{
    return [self detailsString];
}

-(NSString *)dateString
{
    return [self.when toString];
    
}

@end

