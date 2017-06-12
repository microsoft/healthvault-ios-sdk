//
//  MHVAsthmaInhalerTests.m
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
#import "MHVAsthmaInhaler.h"

SPEC_BEGIN(MHVAsthmaInhalerTests)

describe(@"MHVAsthmaInhaler", ^
         {
             NSString *objectDefinition = @"<asthma-inhaler><drug><text>ventolin</text><code><value>5924e2fc-deb6-4d1e-a244-bd49de3cd292</value><family>Mayo</family><type>MayoMedications</type><version>2.0</version></code></drug><strength><text>Micrograms (mcg)</text><code><value>mcg</value><family>wc</family><type>medication-dose-units</type><version>1</version></code></strength><purpose>Combination</purpose><start-date><structured><date><y>2005</y><m>1</m><d>1</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></structured></start-date><stop-date><structured><date><y>2005</y><m>1</m><d>12</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></structured></stop-date><expiration-date><structured><date><y>2007</y><m>1</m><d>1</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></structured></expiration-date><device-id>9C4C77CF-1DF0-4c41-BD3D-EC9232B5BC8A</device-id><initial-doses>3</initial-doses><min-daily-doses>3</min-daily-doses><max-daily-doses>5</max-daily-doses><can-alert>true</can-alert><alert><dow>4</dow><time><h>1</h><m>0</m><s>0</s><f>0</f></time></alert></asthma-inhaler>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVAsthmaInhaler *inhaler = (MHVAsthmaInhaler*)[XReader newFromString:objectDefinition withRoot:[MHVAsthmaInhaler XRootElement] asClass:[MHVAsthmaInhaler class]];
                                
                                [[inhaler.drug.description should] equal:@"ventolin"];
                                [[inhaler.strength.description should] equal:@"Micrograms (mcg)"];
                                [[inhaler.purpose.description should] equal:@"Combination"];
                                [[inhaler.startDate.description should] equal:@"01/01/05 06:00 AM"];
                                [[inhaler.stopDate.description should] equal:@"01/12/05 06:00 AM"];
                                [[inhaler.expirationDate.description should] equal:@"01/01/07 06:00 AM"];
                                [[inhaler.deviceId.description should] equal:@"9C4C77CF-1DF0-4c41-BD3D-EC9232B5BC8A"];
                                [[theValue(inhaler.initialDose) should] equal:theValue(3)];
                                [[theValue(inhaler.minDailyDoses) should] equal:theValue(3)];
                                [[theValue(inhaler.maxDailyDoses) should] equal:theValue(5)];
                                [[theValue(inhaler.canAlert.value) should] equal:theValue(YES)];
                                [[theValue(inhaler.alert.count) should] equal:theValue(1)];
                                MHVAlert *alert = [inhaler.alert objectAtIndex:0];
                                [[theValue(alert.dow.value) should] equal:theValue(4)];
                                [[theValue(alert.time.hour) should] equal:theValue(1)];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVAsthmaInhaler *inhaler = (MHVAsthmaInhaler*)[XReader newFromString:objectDefinition withRoot:[MHVAsthmaInhaler XRootElement] asClass:[MHVAsthmaInhaler class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVAsthmaInhaler XRootElement]];
                                [inhaler serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
