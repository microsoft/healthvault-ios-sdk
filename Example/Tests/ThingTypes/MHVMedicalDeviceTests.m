//
//  MHVMedicalDeviceTests.m
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
#import "MHVMedicalDevice.h"

SPEC_BEGIN(MHVMedicalDeviceTests)

describe(@"MHVMedicalDevice", ^
         {
             NSString *objectDefinition = @"<device><when><date><y>2008</y><m>1</m><d>1</d></date><time><h>10</h><m>30</m><s>0</s><f>0</f></time></when><device-name>Digital Peak Flow Meter</device-name><vendor><name><full>Mark Boyce</full><title><text>Mr</text><code><value>Mr</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>Mark</first><middle/><last>Boyce</last><suffix><text>Junior</text><code><value>Jr</value><family>wc</family><type>name-suffixes</type><version>1</version></code></suffix></name><organization>Microlife</organization><professional-training>A2Z Testing</professional-training><id>3456789</id><contact><address><description>12345 Apt#234</description><is-primary>true</is-primary><street>NE 34th St</street><city>Redmond</city><state>WA</state><postcode>98052</postcode><country>US</country></address><phone><description>Office</description><is-primary>true</is-primary><number>2069053456</number></phone><email><description>Office</description><is-primary>true</is-primary><address>markbo@live.com</address></email></contact><type><text>Provider</text><code><value>2</value><family>wc</family><type>person-types</type><version>1</version></code></type></vendor><model>PF100</model><serial-number>23456543</serial-number><anatomic-site>Lungs</anatomic-site><description>Mark Boyce got a Peak flow meter</description></device>";
             
             context(@"Deserialize", ^
                    {
                       it(@"should deserialize correctly", ^
                          {
                              MHVMedicalDevice *device = (MHVMedicalDevice*)[XReader newFromString:objectDefinition withRoot:[MHVMedicalDevice XRootElement] asClass:[MHVMedicalDevice class]];
                              
                              [[device.when.description should] equal:@"01/01/08 10:30 AM"];
                              [[device.deviceName should] equal:@"Digital Peak Flow Meter"];
                              [[device.vendor.description should] equal:@"Mark Boyce"];
                              [[device.model should] equal:@"PF100"];
                              [[device.serialNumber should] equal:@"23456543"];
                              [[device.anatomicSite should] equal:@"Lungs"];
                              [[device.descriptionText should] equal:@"Mark Boyce got a Peak flow meter"];
                          });
                    });
             
             context(@"Serialize", ^
                     {
                        it(@"should serialize correctly", ^
                           {
                               MHVMedicalDevice *device = (MHVMedicalDevice*)[XReader newFromString:objectDefinition withRoot:[MHVMedicalDevice XRootElement] asClass:[MHVMedicalDevice class]];
                               
                               XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                               [writer writeStartElement:[MHVMedicalDevice XRootElement]];
                               [device serialize:writer];
                               [writer writeEndElement];
                               
                               NSString *result = [writer newXmlString];
                               
                               [[result should] equal:objectDefinition];
                           });
                     });
         });

SPEC_END
