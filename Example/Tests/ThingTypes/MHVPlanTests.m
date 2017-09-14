//
//  MHVPlanTests.m
//
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
#import "MHVPlan.h"

SPEC_BEGIN(MHVPlanTests)

describe(@"MHVPlan", ^
         {
             NSString *objectDefinition = @"<plan><name>Sleep better</name><description>sleep plan</description><status>InProgress</status><category>Sleep</category><objectives><objective><id>1C71CED0-3F55-4A66-A8C9-189836304BB2</id><name>Get more sleep</name><description>Work on habits that help you maximize how much you sleep.</description><state>Inactive</state><outcomes><outcome><name>Hours asleep / night</name><type>SleepHoursPerNight</type></outcome></outcomes></objective><objective><id>8F208503-A964-4373-A067-EAC8E1673133</id><name>Fall asleep faster</name><description>Focus on habits that help you feel more ready to sleep at bedtime.</description><state>Active</state><outcomes><outcome><name>Minutes to fall asleep / night</name><type>MinutesToFallAsleepPerNight</type></outcome></outcomes></objective></objectives></plan>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVPlan *plan = (MHVPlan*)[XReader newFromString:objectDefinition withRoot:[MHVPlan XRootElement] asClass:[MHVPlan class]];
                                
                                [[plan.name.description should] equal:@"Sleep better"];
                                [[plan.status should] equal:[MHVActionPlanInstanceStatusEnum MHVInProgress]];
                                [[plan.descriptionText.description should] equal:@"sleep plan"];
                                [[plan.category should] equal:[MHVActionPlanCategoryEnum MHVSleep]];
                                [[theValue(plan.objectives.objective.count) should] equal:theValue(2)];
                                MHVPlanObjective *objective = [plan.objectives.objective objectAtIndex:0];
                                [[objective.identifier.description should] equal:@"1C71CED0-3F55-4A66-A8C9-189836304BB2"];
                                [[objective.name.description should] equal:@"Get more sleep"];
                                [[objective.descriptionText.description should] equal:@"Work on habits that help you maximize how much you sleep."];
                                [[objective.state should] equal:[MHVObjectiveStateEnum MHVInactive]];
                                
                                [[theValue(objective.outcomes.outcome.count) should] equal:theValue(1)];
                                MHVPlanOutcome *outcome = [objective.outcomes.outcome objectAtIndex:0];
                                [[outcome.name.description should] equal:@"Hours asleep / night"];
                                [[outcome.type should] equal:[MHVObjectiveOutcomeTypeEnum MHVSleepHoursPerNight]];
                                
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVPlan *plan = (MHVPlan*)[XReader newFromString:objectDefinition withRoot:[MHVPlan XRootElement] asClass:[MHVPlan class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVPlan XRootElement]];
                                [plan serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
