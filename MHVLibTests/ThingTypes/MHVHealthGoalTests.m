//
//  MHV	HealthGoalTests.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "MHVHealthGoal.h"

SPEC_BEGIN(MHVHealthGoalTests)

describe(@"MHVHealthGoal", ^
{
    NSString *objectDefinition = @"<health-goal><name><text>walking-step-count</text><code><value>walk</value><family>wc</family><type>goal-type</type><version>1</version></code></name><description>sample goal</description><start-date><structured><date><y>2017</y><m>6</m><d>9</d></date><time><h>7</h><m>0</m><s>0</s><f>0</f></time></structured></start-date><target-range><name><text>range</text></name><minimum><display>6000 count</display><structured><value>6000</value><units><text>Count</text><code><value>Count</value><family>wc</family><type>exercise-units</type><version>1</version></code></units></structured></minimum></target-range><recurrence><interval><text>Day</text><code><value>day</value><family>wc</family><type>recurrence-intervals</type><version>1</version></code></interval><times-in-interval>1</times-in-interval></recurrence></health-goal>";
    
    context(@"Deserialize", ^
            {
                it(@"should deserialize correclty", ^
                   {
                       MHVHealthGoal *goal = (MHVHealthGoal*)[XReader newFromString:objectDefinition withRoot:[MHVHealthGoal XRootElement] asClass:[MHVHealthGoal class]];
                       
                       [[goal.name.description should] equal:@"walking-step-count"];
                       [[goal.descriptionText.description should] equal:@"sample goal"];
                       [[goal.startDate.description should] equal:@"06/09/17 07:00 AM"];
                       [[goal.endDate.description should] beNil];
                       [[goal.targetRange.name.description should] equal:@"range"];
                       [[goal.targetRange.minimum.dispaly.description should] equal:@"6000 count"];
                       [[goal.recurrence.interval.description should] equal:@"Day"];
                       [[theValue(goal.recurrence.timesInInterval.value) should] equal:theValue(1)];
                   });
            });
    context(@"Serialize", ^
            {
                it(@"should serialize correclty", ^
                   {
                      MHVHealthGoal *goal = (MHVHealthGoal*)[XReader newFromString:objectDefinition withRoot:[MHVHealthGoal XRootElement] asClass:[MHVHealthGoal class]];
                       
                       XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                       [writer writeStartElement:[MHVHealthGoal XRootElement]];
                       [goal serialize:writer];
                       [writer writeEndElement];
                       
                       NSString *result = [writer newXmlString];
                       
                       [[result should] equal:objectDefinition];
                   });
            });
});

SPEC_END
