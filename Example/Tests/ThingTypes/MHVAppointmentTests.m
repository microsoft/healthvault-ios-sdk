//
//  MHVAppointmentTests.m
// MHVLib
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
#import "MHVAppointment.h"

SPEC_BEGIN(MHVAppointmentTests)

describe(@"MHVAppointment", ^
         {
            NSString *objectDefinition = @"<appointment><when><date><y>2005</y><m>1</m><d>1</d></date><time><h>10</h><m>0</m><s>0</s><f>0</f></time></when><duration><start-date><structured><date><y>2005</y><m>1</m><d>1</d></date><time><h>10</h><m>0</m><s>0</s><f>0</f></time></structured></start-date><end-date><structured><date><y>2005</y><m>1</m><d>1</d></date><time><h>11</h><m>0</m><s>0</s><f>0</f></time></structured></end-date></duration><service><text>Outpatient</text><code><value>OP</value><family>wc</family><type>appointment-care-class</type><version>1</version></code></service><clinic><name><full>John Mc Kense</full><title><text>Mr</text><code><value>Mr</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>John</first><middle>Mc</middle><last>Kense</last><suffix><text>The Fourth</text><code><value>IV</value><family>wc</family><type>name-suffixes</type><version>1</version></code></suffix></name><organization>InterLake Dental Clinic</organization><professional-training>Dental Training</professional-training><id/><contact><address><description>14532 Apt# 201</description><is-primary>true</is-primary><street>SE 150th St</street><city>DC</city><state>WA</state><postcode>98008</postcode><country>USA</country></address><phone><description>Office</description><is-primary>true</is-primary><number>4254485444</number></phone><email><description>Mail Id</description><is-primary>true</is-primary><address>John@live.com</address></email></contact><type><text>Emergency Contact</text><code><value>1</value><family>wc</family><type>person-types</type><version>1</version></code></type></clinic><specialty><text>Adolescent Medicine - Pediatrics</text><code><value>ADL</value><family>wc</family><type>medical-specialties</type><version>1</version></code></specialty><status><text>Complete</text><code><value>Cmp</value><family>wc</family><type>appointment-status</type><version>1</version></code></status><care-class><text>Day Surgery</text><code><value>DS</value><family>wc</family><type>appointment-care-class</type><version>1</version></code></care-class></appointment>";
             
            context(@"Deserialize", ^
                    {
                        it(@"should deserialize correctly", ^
                           {
                               MHVAppointment *appointment = (MHVAppointment*)[XReader newFromString:objectDefinition withRoot:[MHVAppointment XRootElement] asClass:[MHVAppointment class]];
                               
                               [[appointment.when.description should] equal:@"01/01/05 10:00 AM"];
                               [[appointment.duration.startDate.description should] equal:@"01/01/05 10:00 AM"];
                               [[appointment.duration.endDate.description should] equal:@"01/01/05 11:00 AM"];
                               [[appointment.service.description should] equal:@"Outpatient"];
                               [[appointment.clinic.description should] equal:@"John Mc Kense"];
                               [[appointment.specialty.description should] equal:@"Adolescent Medicine - Pediatrics"];
                               [[appointment.status.description should] equal:@"Complete"];
                               [[appointment.careClass.description should] equal:@"Day Surgery"];
                           });
                    });
                           
            context(@"Serialize", ^
                    {
                        it(@"should serialize correctly", ^
                           {
                               MHVAppointment *appointment = (MHVAppointment*)[XReader newFromString:objectDefinition withRoot:[MHVAppointment XRootElement] asClass:[MHVAppointment class]];
                               
                               XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                               [writer writeStartElement:[MHVAppointment XRootElement]];
                               [appointment serialize:writer];
                               [writer writeEndElement];
                               
                               NSString *result = [writer newXmlString];
                               
                               [[result should] equal:objectDefinition];
                           });
                    });
         });

SPEC_END
