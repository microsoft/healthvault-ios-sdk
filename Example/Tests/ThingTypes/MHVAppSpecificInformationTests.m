//
// MHVAppSpecificInformationTests.m
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
#import "MHVAppSpecificInformation.h"

SPEC_BEGIN(MHVAppSpecificInformationTests)

describe(@"MHVAppSpecificInformation", ^
         {
             NSString *objectDefinition = @"<app-specific><format-appid>MyAppName</format-appid><format-tag>MyAppTag</format-tag><when><date><y>2007</y><m>8</m><d>7</d></date><time><h>0</h><m>0</m><s>0</s><f>0</f></time></when><summary>Test summary</summary></app-specific>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVAppSpecificInformation *info = (MHVAppSpecificInformation*)[XReader newFromString:objectDefinition withRoot:[MHVAppSpecificInformation XRootElement] asClass:[MHVAppSpecificInformation class]];
                                
                                [[info.formatAppId should] equal:@"MyAppName"];
                                [[info.formatTag should] equal:@"MyAppTag"];
                                [[info.when.description should] equal:@"08/07/07 12:00 AM"];
                                [[info.summary should] equal:@"Test summary"];
                                [[info.any should] beNil];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVAppSpecificInformation *info = (MHVAppSpecificInformation*)[XReader newFromString:objectDefinition withRoot:[MHVAppSpecificInformation XRootElement] asClass:[MHVAppSpecificInformation class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVAppSpecificInformation XRootElement]];
                                [info serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];

                            });
                     });
         });
SPEC_END
