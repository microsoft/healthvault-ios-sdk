//
// MHVAerobicProfileTests.m
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
#import "MHVAerobicProfile.h"

SPEC_BEGIN(MHVAerobicProfileTests)

describe(@"MHVAerobicProfile", ^
         {
             NSString *objectDefinition = @"<aerobic-profile><when><date><y>2009</y><m>10</m><d>1</d></date><time><h>16</h><m>20</m><s>0</s><f>0</f></time></when><max-heartrate>140</max-heartrate><resting-heartrate>95</resting-heartrate><anaerobic-threshold>120</anaerobic-threshold><VO2-max><absolute>4</absolute><relative>38</relative></VO2-max><heartrate-zone-group><heartrate-zone><lower-bound><absolute-heartrate>85</absolute-heartrate></lower-bound><upper-bound><absolute-heartrate>135</absolute-heartrate></upper-bound></heartrate-zone></heartrate-zone-group></aerobic-profile>";
             
             context(@"Deserialize", ^
                    {
                        it(@"should deserialize correctly", ^
                           {
                               MHVAerobicProfile *profile = (MHVAerobicProfile*)[XReader newFromString:objectDefinition withRoot:[MHVAerobicProfile XRootElement] asClass:[MHVAerobicProfile class]];
                               
                               [[profile.when shouldNot] beNil];
                               [[theValue(profile.maxHeartrate.value) should] equal:theValue(140)];
                               [[theValue(profile.restingHeartrate.value) should] equal:theValue(95)];
                               [[theValue(profile.anaerobicThreshold.value) should] equal:theValue(120)];
                               [[theValue(profile.vO2Max.absolute.value) should] equal:theValue(4)];
                               [[theValue(profile.vO2Max.relative.value) should] equal:theValue(38)];
                               [[theValue(profile.heartrateZoneGroup.heartrateZone.lowerBound.absoluteHeartrate.value) should] equal:theValue(85)];
                               [[theValue(profile.heartrateZoneGroup.heartrateZone.upperBound.absoluteHeartrate.value) should] equal:theValue(135)];
                           });
                    });
             
             context(@"Serialize", ^
                     {
                        it(@"should serialize correctly", ^
                           {
                               MHVAerobicProfile *profile = (MHVAerobicProfile*)[XReader newFromString:objectDefinition withRoot:[MHVAerobicProfile XRootElement] asClass:[MHVAerobicProfile class]];
                               
                               XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                               [writer writeStartElement:[MHVAerobicProfile XRootElement]];
                               [profile serialize:writer];
                               [writer writeEndElement];
                               
                               NSString *result = [writer newXmlString];
                               
                               [[result should] equal:objectDefinition];
                           });
                     });
         });

SPEC_END
