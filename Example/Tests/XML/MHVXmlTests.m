//
//  MHVXmlTests.m
//  MHVLib
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
//


#import <XCTest/XCTest.h>
#import "MHVAllergy.h"
#import "MHVHeartRate.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVXmlTests)

describe(@"XML", ^
{
    context(@"Serialize", ^
            {
                let(writer, ^
                    {
                        return [[XWriter alloc] initWithBufferSize:2048];
                    });
                
                let(thing, ^
                    {
                        MHVAllergy *allergy = [[MHVAllergy alloc] initWithName:@"TestAllergy"];
                        allergy.reaction = [[MHVCodableValue alloc] initWithText:@"TestReaction"];
                        
                        MHVThing *thing = [[MHVThing alloc] initWithTypedData:allergy];
                        thing.key = [[MHVThingKey alloc] initWithID:@"000000-0000-0000-000000" andVersion:@"1.2.3"];
                        
                        return thing;
                    });
                
                it(@"should serialize thing without blobs", ^
                   {
                       [thing serialize:writer];
                       
                       NSString *string = [writer newXmlString];
                       
                       [[string should] equal:(@"<thing-id version-stamp=\"1.2.3\">000000-0000-0000-000000</thing-id>"\
                                               "<type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id>"\
                                               "<flags>0</flags>"\
                                               "<data-xml><allergy><name><text>TestAllergy</text></name><reaction><text>TestReaction</text></reaction></allergy><common/></data-xml>")];
                   });
                
                it(@"should serialize thing with blobs", ^
                   {
                       MHVBlobPayloadThing *blobThing = [[MHVBlobPayloadThing alloc] initWithBlobName:@"BlobName"
                                                                                       contentType:@"image/jpeg"
                                                                                            length:12345
                                                                                            andUrl:@"https://www.healthvault.com/test-blob-url"];
                       [thing.blobs addOrUpdateBlob:blobThing];
                       
                       [thing serialize:writer];
                       
                       NSString *string = [writer newXmlString];
                       
                       [[string should] equal:(@"<thing-id version-stamp=\"1.2.3\">000000-0000-0000-000000</thing-id>"\
                                               "<type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id>"\
                                               "<flags>0</flags>"\
                                               "<data-xml><allergy><name><text>TestAllergy</text></name><reaction><text>TestReaction</text></reaction></allergy><common/></data-xml>"\
                                               "<blob-payload><blob><blob-info><name>BlobName</name><content-type>image/jpeg</content-type></blob-info>"\
                                               "<content-length>12345</content-length><blob-ref-url>https://www.healthvault.com/test-blob-url</blob-ref-url></blob></blob-payload>")];
                   });
            });
    
    context(@"Deserialize", ^
            {
                it(@"should deserialize thing", ^
                   {
                       NSString *xml = (@"<wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\">"\
                                        "<group><thing><thing-id version-stamp=\"ad57ba08-3ee2-4080-8886-165b61979301\">a9ce136b-43d5-4bdf-a7f6-e64c7e3f728c</thing-id>"\
                                        "<type-id name=\"Heart rate\">b81eb4a6-6eac-4292-ae93-3872d6870994</type-id>"\
                                        "<thing-state>Active</thing-state><flags>0</flags><eff-date>2017-05-02T13:18:32</eff-date>"\
                                        "<data-xml><heart-rate><when><date><y>2017</y><m>5</m><d>2</d></date><time><h>13</h><m>18</m><s>32</s></time></when>"\
                                        "<value>106</value></heart-rate></data-xml>"\
                                        "</thing></group></wc:info>");
                       
                       XReader *reader = [[XReader alloc] initFromString:xml];
                       
                       //Can query for several things at once, should have one result
                       MHVThingQueryResults *results = (MHVThingQueryResults *)[NSObject newFromReader:reader withRoot:@"info" asClass:[MHVThingQueryResults class]];
                       [[theValue(results.hasResults) should] beYes];
                       [[theValue(results.results.count) should] equal:@(1)];
                       
                       //The Result should have one thing
                       MHVThingQueryResultInternal *result = [results.results objectAtIndex:0];
                       [[theValue(result.hasThings) should] beYes];
                       [[theValue(result.things.count) should] equal:@(1)];
                       
                       //The typed thing in the results should be heartrate
                       MHVThing *thing = [result.things objectAtIndex:0];
                       [[thing should] beKindOfClass:[MHVThing class]];
                       [[thing.data.typed should] beKindOfClass:[MHVHeartRate class]];
                       
                       //The heartrate value should be 106
                       MHVHeartRate *heartRate = (MHVHeartRate *)thing.data.typed;
                       [[theValue(heartRate.bpmValue) should] equal:@(106)];
                   });
            });
});

SPEC_END
