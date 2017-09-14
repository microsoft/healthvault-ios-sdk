//
//  MHVTaskTrackingEntryTests.m
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
#import "MHVTaskTrackingEntry.h"

SPEC_BEGIN(MHVTaskTrackingEntryTests)

describe(@"MHVTaskTrackingEntry", ^
         {
             NSString *objectDefinition = @"<task-tracking-entry><tracking-time><date><y>2017</y><m>6</m><d>9</d></date><time><h>14</h><m>26</m><s>0</s></time></tracking-time><tracking-type>Manual</tracking-type><tracking-status>Occurrence</tracking-status><occurrence-start-time><date><y>2017</y><m>6</m><d>9</d></date><time><h>0</h><m>0</m><s>0</s></time></occurrence-start-time><occurrence-end-time><date><y>2017</y><m>6</m><d>10</d></date><time><h>0</h><m>0</m><s>0</s></time></occurrence-end-time><completion-start-time><date><y>2017</y><m>6</m><d>9</d></date><time><h>0</h><m>0</m><s>0</s></time></completion-start-time><completion-end-time><date><y>2017</y><m>6</m><d>10</d></date><time><h>0</h><m>0</m><s>0</s></time></completion-end-time></task-tracking-entry>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVTaskTrackingEntry *entry = (MHVTaskTrackingEntry*)[XReader newFromString:objectDefinition withRoot:[MHVTaskTrackingEntry XRootElement] asClass:[MHVTaskTrackingEntry class]];
                                
                                [[entry.trackingTime.description should] equal:@"06/09/17 02:26 PM"];
                                [[entry.trackingType should] equal:[MHVActionPlanTaskTrackingTrackingTypeEnum MHVManual]];
                                [[entry.trackingStatus should] equal:[MHVActionPlanTaskTrackingTrackingStatusEnum MHVOccurrence]];
                                [[entry.occurrenceStartTime.description should] equal:@"06/09/17 12:00 AM"];
                                [[entry.occurrenceEndTime.description should] equal:@"06/10/17 12:00 AM"];
                                [[entry.completionStartTime.description should] equal:@"06/09/17 12:00 AM"];
                                [[entry.completionEndTime.description should] equal:@"06/10/17 12:00 AM"];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVTaskTrackingEntry *entry = (MHVTaskTrackingEntry*)[XReader newFromString:objectDefinition withRoot:[MHVTaskTrackingEntry XRootElement] asClass:[MHVTaskTrackingEntry class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVTaskTrackingEntry XRootElement]];
                                [entry serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
