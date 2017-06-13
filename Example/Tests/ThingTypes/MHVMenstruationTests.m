//
//  MHVMenstruationTests.m
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
#import "MHVMenstruation.h"

SPEC_BEGIN(MHVMenstruationTests)

describe(@"MHVMenstruation", ^
         {
             NSString *objectDefinition = @"<menstruation><when><date><y>2014</y><m>10</m><d>22</d></date></when><is-new-cycle>true</is-new-cycle><amount><text>light</text></amount></menstruation>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVMenstruation *menstruation = (MHVMenstruation*)[XReader newFromString:objectDefinition withRoot:[MHVMenstruation XRootElement] asClass:[MHVMenstruation class]];
                                
                                [[menstruation.when.description should] equal:@"10/22/14 12:00 AM"];
                                [[theValue(menstruation.isNewCycle.value) should] equal:theValue(YES)];
                                [[menstruation.amount.description should] equal:@"light"];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVMenstruation *menstruation = (MHVMenstruation*)[XReader newFromString:objectDefinition withRoot:[MHVMenstruation XRootElement] asClass:[MHVMenstruation class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVMenstruation XRootElement]];
                                [menstruation serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
