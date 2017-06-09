//
//  MHVPregnancyTests.m
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
#import "MHVPregnancy.h"

SPEC_BEGIN(MHVPregnancyTests)

describe(@"MHVPregnancy", ^
         {
             NSString *objectDefinition = @"<pregnancy><due-date><y>2005</y><m>9</m><d>1</d></due-date><last-menstrual-period><y>2005</y><m>1</m><d>2</d></last-menstrual-period><conception-method><text>Intercourse</text><code><value>Intercourse</value><family>wc</family><type>conception-methods</type><version>1</version></code></conception-method><fetus-count>1</fetus-count><gestational-age>40</gestational-age><delivery><location><name>Suzan Mc Kense</name><contact><address><description>14503 Apt# 102</description><is-primary>true</is-primary><street>SE 140th St</street><city>DC</city><state>WA</state><postcode>98008</postcode><country>USA</country></address><phone><description>Office</description><is-primary>true</is-primary><number>4254485432</number></phone><email><description>Mail Id</description><is-primary>true</is-primary><address>john@live.com</address></email></contact><type><text>Emergency Contact</text><code><value>1</value><family>wc</family><type>person-types</type><version>1</version></code></type><website/></location><time-of-delivery><structured><date><y>2005</y><m>9</m><d>1</d></date><time><h>8</h><m>0</m><s>0</s><f>0</f></time></structured></time-of-delivery><labor-duration>30</labor-duration><complications><text>Placenta previa</text><code><value>PlacentaPrevia</value><family>wc</family><type>delivery-complications</type><version>1</version></code></complications><anesthesia><text>Regional analgesia</text><code><value>RegionalAnalgesia</value><family>wc</family><type>anesthesia-methods</type><version>1</version></code></anesthesia><delivery-method><text>Vaginal</text><code><value>Vaginal</value><family>wc</family><type>delivery-methods</type><version>1</version></code></delivery-method><outcome><text>Live birth</text><code><value>Livebirth</value><family>wc</family><type>pregnancy-outcomes</type><version>1</version></code></outcome><baby><name><full>John MC Kense</full><title><text>Mr</text><code><value>Mr</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>John</first><middle>Mc</middle><last>Kense</last></name><gender><text>male</text><code><value>male</value><family>wc</family><type>gender-types</type><version>1</version></code></gender><weight><kg>3.4</kg><display units=\"3.4 Kgs\">3.4</display></weight><length><m>0.2</m><display units=\"0.2 m\">0.2</display></length><head-circumference><m>0.13</m><display units=\"0.13 m\">0.13</display></head-circumference><note/></baby><note/></delivery></pregnancy>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVPregnancy *pregnancy = (MHVPregnancy*)[XReader newFromString:objectDefinition withRoot:[MHVPregnancy XRootElement] asClass:[MHVPregnancy class]];
                                
                                MHVDelivery *delivery = [pregnancy.delivery objectAtIndex:0];
                                
                                [[pregnancy.dueDate.description should] equal:@"09/01/05"];
                                [[pregnancy.lastMenstrualPeriod.description should] equal:@"01/02/05"];
                                [[pregnancy.conceptionMethod.description should] equal:@"Intercourse"];
                                [[theValue(pregnancy.feteusCount.value) should] equal:theValue(1)];
                                [[theValue(pregnancy.gestationalAge.value) should] equal:theValue(40)];
                                [[theValue(pregnancy.delivery.count) should] equal:theValue(1)];
                                [[delivery.location.description should] equal:@"Suzan Mc Kense"];
                                [[delivery.timeOfDelivery.description should] equal:@"09/01/05 08:00 AM"];
                                [[theValue(delivery.laborDuration.value) should] equal:theValue(30.0000)];
                                [[theValue(delivery.complications.count) should] equal:theValue(1)];
                                [[[delivery.complications objectAtIndex:0].description should] equal:@"Placenta previa"];
                                [[theValue(delivery.anesthesia.count) should] equal:theValue(1)];
                                [[[delivery.anesthesia objectAtIndex:0].description should] equal:@"Regional analgesia"];
                                [[delivery.deliveryMethod.description should] equal:@"Vaginal"];
                                [[delivery.outcome.description should] equal:@"Live birth"];
                                [[delivery.baby.name.description should] equal:@"John MC Kense"];
                                [[delivery.baby.gender.description should] equal:@"male"];
                                [[delivery.baby.weight.description should] equal:@"3.40 kilogram"];
                                [[theValue(delivery.baby.length.display.value) should] equal:theValue(0.20000000000000001)];
                                [[theValue(delivery.baby.headCircumference.display.value) should] equal:theValue(0.13)];
                                [[delivery.baby.note.description should] equal:@""];
                                [[delivery.note.description should] equal:@""];
                                 
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVPregnancy *pregnancy = (MHVPregnancy*)[XReader newFromString:objectDefinition withRoot:[MHVPregnancy XRootElement] asClass:[MHVPregnancy class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVPregnancy XRootElement]];
                                [pregnancy serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
