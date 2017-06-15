//
// MHVAdvanceDirectiveTests.m
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
#import "MHVAdvanceDirective.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVAdvanceDirectiveTests)

describe(@"MHVAdvanceDirective", ^
{
    // Object definition taken from https://developer.healthvault.com/DataTypes/Example?TypeId=822a5e5a-14f1-4d06-b92f-8f3f1b05218f
    
    NSString *objectDefinition = @"<directive><start-date><structured><date><y>2008</y><m>1</m><d>1</d></date><time><h>23</h><m>12</m><s>0</s><f>0</f></time></structured></start-date><stop-date><structured><date><y>2008</y><m>1</m><d>25</d></date><time><h>11</h><m>54</m><s>0</s><f>0</f></time></structured></stop-date><description>DNR</description><full-resuscitation>true</full-resuscitation><additional-instructions>Additional directive instructions</additional-instructions><attending-physician><name><full>Scott Pratt</full><title><text>Mr</text><code><value>Mr</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>Scott</first><middle/><last>Pratt</last><suffix><text>Jr</text><code><value>Jr</value><family>wc</family><type>name-sufixes</type><version>1</version></code></suffix></name><organization>Green Fields</organization><professional-training>MBBS MD</professional-training><id>32323232</id><contact><address><description>12323 Apt#234</description><is-primary>true</is-primary><street>14th Ave NE</street><city>Redmond</city><state>WA</state><postcode>98052</postcode><country>USA</country></address><phone><description>Work</description><is-primary>true</is-primary><number>4259999999</number></phone><email><description>Work</description><is-primary>true</is-primary><address>scott@greenfields.com</address></email></contact><type><text>Provider</text><code><value>2</value><family>wc</family><type>person-types</type><version>1</version></code></type></attending-physician><attending-physician-endorsement><date><y>2008</y><m>1</m><d>2</d></date><time><h>3</h><m>34</m><s>0</s><f>0</f></time></attending-physician-endorsement><attending-nurse><name><full>Melinda Cromer</full><title><text>Mis</text><code><value>Mis</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>Melinda</first><middle/><last>Cromer</last></name><organization>Green Fields</organization><professional-training>A2Z training</professional-training><id>8787878</id><contact><address><description>45454 Apt#C111</description><is-primary>true</is-primary><street>20th St SW</street><city>Redmond</city><state>WA</state><postcode>98053</postcode><country>US</country></address><phone><description>Work</description><is-primary>true</is-primary><number>4259999999</number></phone><email><description>Work</description><is-primary>true</is-primary><address>melinda.c@greenfields.com</address></email></contact><type><text>Emergency Contact</text><code><value>1</value><family>wc</family><type>person-types</type><version>1</version></code></type></attending-nurse><attending-nurse-endorsement><date><y>2008</y><m>1</m><d>2</d></date><time><h>10</h><m>0</m><s>0</s><f>0</f></time></attending-nurse-endorsement><expiration-date><date><y>2008</y><m>1</m><d>25</d></date><time><h>11</h><m>50</m><s>0</s><f>0</f></time></expiration-date><discontinuation-date><structured><date><y>1000</y><m>1</m><d>1</d></date><time><h>0</h><m>0</m><s>0</s><f>0</f></time></structured></discontinuation-date><discontinuation-physician><name><full>Scott Pratt</full><title><text>Mr</text><code><value>Mr</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>Scott</first><middle/><last>Pratt</last></name><organization>Green Fields</organization><professional-training>A2Z Training</professional-training><id>32323232</id><contact><address><description>12323 Apt#234</description><is-primary>true</is-primary><street>14th Ave NE</street><city>Redmond</city><state>WA</state><postcode>98052</postcode><country>USA</country></address><phone><description>Work</description><is-primary>true</is-primary><number>4259999999</number></phone><email><description>Work</description><is-primary>true</is-primary><address>scott@greenfields.com</address></email></contact><type><text>Provider</text><code><value>2</value><family>wc</family><type>person-types</type><version>1</version></code></type></discontinuation-physician><discontinuation-physician-endorsement><date><y>2008</y><m>1</m><d>25</d></date><time><h>11</h><m>54</m><s>0</s><f>0</f></time></discontinuation-physician-endorsement><discontinuation-nurse><name><full>Melinda Cromer</full><title><text>Mis</text><code><value>Mis</value><family>wc</family><type>name-prefixes</type><version>1</version></code></title><first>Melinda</first><middle/><last>Cromer</last></name><organization>Green Fields</organization><professional-training>A2Z training</professional-training><id>8787878</id><contact><address><description>45454 Apt#C111</description><is-primary>true</is-primary><street>20th St SW</street><city>Redmond</city><state>WA</state><postcode>98053</postcode><country>US</country></address><phone><description>Work</description><is-primary>true</is-primary><number>4259999999</number></phone><email><description>Work</description><is-primary>true</is-primary><address>melinda.c@greenfields.com</address></email></contact><type><text>Emergency Contact</text><code><value>1</value><family>wc</family><type>person-types</type><version>1</version></code></type></discontinuation-nurse><discontinuation-nurse-endorsement><date><y>2008</y><m>1</m><d>25</d></date><time><h>11</h><m>54</m><s>0</s><f>0</f></time></discontinuation-nurse-endorsement></directive>";
    
    context(@"Deserialize", ^
            {
                it(@"should deserialize correclty", ^
                   {
                       MHVAdvanceDirective *directive = (MHVAdvanceDirective*)[XReader newFromString:objectDefinition withRoot:[MHVAdvanceDirective XRootElement] asClass:[MHVAdvanceDirective class]];
                       
                       // Validating some key values for each property, but not every property
                       [[directive.startDate.description should]equal:@"01/01/08 11:12 PM"];
                       [[directive.stopDate.description should]equal:@"01/25/08 11:54 AM"];
                       [[directive.descriptionText should] equal:@"DNR"];
                       [[theValue(directive.fullResuscitation.value) should] equal:theValue(YES)];
                       [[directive.prohibitedInterventions should] beNil];          // No example data at the moment, so should be nil
                       [[directive.additionalInstructions should] equal:@"Additional directive instructions"];
                       [[directive.attendingPhysician.identifier should] equal:@"32323232"];
                       [[directive.attendingPhysicianEndorsement.description should] equal:@"01/02/08 03:34 AM"];
                       [[directive.attendingNurse.identifier should] equal:@"8787878"];
                       [[directive.attendingNurseEndorsement.description should] equal:@"01/02/08 10:00 AM"];
                       [[directive.expirationDate.description should] equal:@"01/25/08 11:50 AM"];
                       [[directive.discontinuationDate.description should] equal:@"01/01/00 12:00 AM"];
                       [[directive.discontinuationPhysician.identifier should] equal:@"32323232"];
                       [[directive.discontinuationPhysicianEndorsement.description should] equal:@"01/25/08 11:54 AM"];
                       [[directive.discontinuationNurse.identifier should] equal:@"8787878"];
                       [[directive.discontinuationNurseEndorsement.description should] equal:@"01/25/08 11:54 AM"];
                   });
            });
    context(@"Serialize", ^
            {
                it(@"should serialize correctly", ^
                   {
                       MHVAdvanceDirective *directive = (MHVAdvanceDirective*)[XReader newFromString:objectDefinition withRoot:[MHVAdvanceDirective XRootElement] asClass:[MHVAdvanceDirective class]];
                       XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                       [writer writeStartElement:[MHVAdvanceDirective XRootElement]];
                       [directive serialize:writer];
                       [writer writeEndElement];
                       
                       NSString *result = [writer newXmlString];
                       
                       [[result should] equal:objectDefinition];
                   });
            });
});

SPEC_END
