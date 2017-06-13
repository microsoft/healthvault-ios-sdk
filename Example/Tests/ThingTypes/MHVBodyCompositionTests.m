//
//  MHVBodyCompositionTests.m
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
#import "MHVBodyComposition.h"

SPEC_BEGIN(MHVBodyCompositionTests)

describe(@"MHVBodyComposition", ^
         {
             NSString *objectDefinition = @"<body-composition><when><structured><date><y>2008</y><m>1</m><d>1</d></date><time><h>18</h><m>30</m><s>0</s><f>0</f></time></structured></when><measurement-name><text>Body fat percentage</text><code><value>fat-percent</value><family>wc</family><type>body-composition-measurement-names</type><version>1</version></code></measurement-name><value><mass-value><kg>89</kg><display units=\"kg\">89</display></mass-value><percent-value>0.67</percent-value></value><measurement-method><text>DXA/DEXA</text><code><value>DXA</value><family>wc</family><type>body-composition-measurement-methods</type><version>1</version></code></measurement-method><site><text>Trunk</text><code><value>Trunk</value><family>wc</family><type>body-composition-sites</type><version>1</version></code></site></body-composition>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVBodyComposition *bodyComposition = (MHVBodyComposition*)[XReader newFromString:objectDefinition withRoot:[MHVBodyComposition XRootElement] asClass:[MHVBodyComposition class]];
                                
                                [[bodyComposition.when.description should] equal:@"01/01/08 06:30 PM"];
                                [[bodyComposition.measurementName.description should] equal:@"Body fat percentage"];
                                [[bodyComposition.value.massValue.description should] equal:@"89.00 kilogram"];
                                [[bodyComposition.value.percentValue.description should] equal:@"0.670000"];
                                [[bodyComposition.measurementMethod.description should] equal:@"DXA/DEXA"];
                                [[bodyComposition.site.description should] equal:@"Trunk"];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVBodyComposition *bodyComposition = (MHVBodyComposition*)[XReader newFromString:objectDefinition withRoot:[MHVBodyComposition XRootElement] asClass:[MHVBodyComposition class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVBodyComposition XRootElement]];
                                [bodyComposition serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
