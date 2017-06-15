//
// MHVConcernsTests.m
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
#import "MHVConcern.h"

SPEC_BEGIN(MHVConcernTests)

describe(@"MHVConvern", ^
         {
             NSString *objectDefinition = @"<concern><description><text>Underweight child</text><code><value>3544</value><family>Mayo</family><type>MayoHealthConcerns</type><version>2.0</version></code></description><status><text>Active</text><code><value>active</value><family>wc</family><type>concern-status</type><version>1</version></code></status></concern>";
             context(@"Deserialize", ^
                     {
                        it(@"should deserialize correctly", ^
                           {
                               MHVConcern *concern = (MHVConcern*)[XReader newFromString:objectDefinition withRoot:[MHVConcern XRootElement] asClass:[MHVConcern class]];
                               
                               [[concern.descriptionText.description should] equal:@"Underweight child"];
                               [[concern.status.description should] equal:@"Active"];
                           });
                     });
             
             context(@"Serialize", ^
                     {
                        it(@"should serialize correctly", ^
                           {
                               MHVConcern *concern = (MHVConcern*)[XReader newFromString:objectDefinition withRoot:[MHVConcern XRootElement] asClass:[MHVConcern class]];
                               
                               XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                               [writer writeStartElement:[MHVConcern XRootElement]];
                               [concern serialize:writer];
                               [writer writeEndElement];
                               
                               NSString *result = [writer newXmlString];
                               
                               [[result should] equal:objectDefinition];
                           });
                     });
         });

SPEC_END
