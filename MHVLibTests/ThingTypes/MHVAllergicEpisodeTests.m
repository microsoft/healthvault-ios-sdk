//
// MHVAllergicEpisodeTests.m
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
#import "MHVAllergicEpisode.h"

SPEC_BEGIN(MHVAllergicEpisodeTests)

describe(@"MHVAllergicEpisode", ^
         {
             NSString *objectDefinition = @"<allergic-episode><when><date><y>2005</y><m>1</m><d>1</d></date><time><h>6</h><m>0</m><s>0</s><f>0</f></time></when><name><text>allergy to insects</text><code><value>V1506</value><family>icd</family><type>icd9cm</type><version>1</version></code></name><reaction><text>itchy, watery eyes</text><code><value>372.14</value><family>wc</family><type>reactions</type><version>1</version></code></reaction><treatment><text>Topical steroid cream and Antihistamines</text></treatment></allergic-episode>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVAllergicEpisode *episode = (MHVAllergicEpisode*)[XReader newFromString:objectDefinition withRoot:[MHVAllergicEpisode XRootElement] asClass:[MHVAllergicEpisode class]];
                                
                                [[episode.when.description should] equal:@"01/01/05 06:00 AM"];
                                [[episode.name.description should] equal:@"allergy to insects"];
                                [[episode.reaction.description should] equal:@"itchy, watery eyes"];
                                [[episode.treatment.description should] equal:@"Topical steroid cream and Antihistamines"];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVAllergicEpisode *episode = (MHVAllergicEpisode*)[XReader newFromString:objectDefinition withRoot:[MHVAllergicEpisode XRootElement] asClass:[MHVAllergicEpisode class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVAllergicEpisode XRootElement]];
                                [episode serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
             
         });
SPEC_END
