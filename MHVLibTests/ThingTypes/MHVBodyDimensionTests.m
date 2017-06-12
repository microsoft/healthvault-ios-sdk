//
//  MHVBodyDimensionTests.m
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
#import "MHVBodyDimension.h"

SPEC_BEGIN(MHVBodyDimensionTests)

describe(@"MHVBodyDimension", ^
         {
             NSString *objectDefinition = @"<body-dimension><when><structured><date><y>2005</y><m>1</m><d>1</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></structured></when><measurement-name><text>Left bicep size</text><code><value>BicepCircumferenceLeft</value><family>wc</family><type>body-dimension-measurement-names</type><version>1</version></code></measurement-name><value><m>0.15</m><display units=\"\">0.15</display></value></body-dimension>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVBodyDimension *bodyDimension = (MHVBodyDimension*)[XReader newFromString:objectDefinition withRoot:[MHVBodyDimension XRootElement] asClass:[MHVBodyDimension class]];
                                
                                [[bodyDimension.when.description should] equal:@"01/01/05 06:00 AM"];
                                [[bodyDimension.measurementName.description should] equal:@"Left bicep size"];
                                [[theValue(bodyDimension.value.display.value) should] beBetween:theValue(0.14999) and:theValue(0.15001)];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVBodyDimension *bodyDimension = (MHVBodyDimension*)[XReader newFromString:objectDefinition withRoot:[MHVBodyDimension XRootElement] asClass:[MHVBodyDimension class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVBodyDimension XRootElement]];
                                [bodyDimension serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
