//
//  MHVAsthmaInhalerUsageTests.m
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
#import "MHVAsthmaInhalerUsage.h"

SPEC_BEGIN(MHVAsthmaInhalerUsageTests)

describe(@"MHVAsthmaInhalerUsage", ^
         {
             NSString *objectDefinition = @"<asthma-inhaler-use><when><date><y>2005</y><m>1</m><d>1</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></when><drug><text>ventolin</text><code><value>5924e2fc-deb6-4d1e-a244-bd49de3cd292</value><family>Mayo</family><type>MayoMedications</type><version>2.0</version></code></drug><strength><text>Micrograms (mcg)</text><code><value>mcg</value><family>wc</family><type>medication-dose-units</type><version>1</version></code></strength><dose-count>3</dose-count><device-id>9C4C77CF-1DF0-4c41-BD3D-EC9232B5BC8A</device-id><dose-purpose><text>prevention</text><code><value>p</value><family>wc</family><type>inhaler-dose-purpose</type><version>1</version></code></dose-purpose></asthma-inhaler-use>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVAsthmaInhalerUsage *inhalerUsage = (MHVAsthmaInhalerUsage*)[XReader newFromString:objectDefinition withRoot:[MHVAsthmaInhalerUsage XRootElement] asClass:[MHVAsthmaInhalerUsage class]];
                                
                                [[inhalerUsage.when.description should] equal:@"01/01/05 06:00 AM"];
                                [[inhalerUsage.drug.description should] equal:@"ventolin"];
                                [[inhalerUsage.strength.description should] equal:@"Micrograms (mcg)"];
                                [[inhalerUsage.deviceId.description should] equal:@"9C4C77CF-1DF0-4c41-BD3D-EC9232B5BC8A"];
                                [[inhalerUsage.dosePurpose.description should] equal:@"prevention"];
                                [[theValue(inhalerUsage.doseCount) should] equal:theValue(3)];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVAsthmaInhalerUsage *inhalerUsage = (MHVAsthmaInhalerUsage*)[XReader newFromString:objectDefinition withRoot:[MHVAsthmaInhalerUsage XRootElement] asClass:[MHVAsthmaInhalerUsage class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVAsthmaInhalerUsage XRootElement]];
                                [inhalerUsage serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
