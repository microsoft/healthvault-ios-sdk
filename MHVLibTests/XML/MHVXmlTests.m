//
//  MHVXmlTests.m
//  MHVLib
//
//  Created by Michael Burford on 5/12/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
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
                
                let(item, ^
                    {
                        MHVAllergy *allergy = [[MHVAllergy alloc] initWithName:@"TestAllergy"];
                        allergy.reaction = [[MHVCodableValue alloc] initWithText:@"TestReaction"];
                        
                        MHVItem *item = [[MHVItem alloc] initWithTypedData:allergy];
                        item.key = [[MHVItemKey alloc] initWithID:@"000000-0000-0000-000000" andVersion:@"1.2.3"];
                        
                        return item;
                    });
                
                it(@"should serialize item without blobs", ^
                   {
                       [item serialize:writer];
                       
                       NSString *string = [writer newXmlString];
                       
                       [[string should] equal:(@"<thing-id version-stamp=\"1.2.3\">000000-0000-0000-000000</thing-id>"\
                                               "<type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id>"\
                                               "<flags>0</flags>"\
                                               "<data-xml><allergy><name><text>TestAllergy</text></name><reaction><text>TestReaction</text></reaction></allergy><common/></data-xml>")];
                   });
                
                it(@"should serialize item with blobs", ^
                   {
                       MHVBlobPayloadItem *blobItem = [[MHVBlobPayloadItem alloc] initWithBlobName:@"BlobName"
                                                                                       contentType:@"image/jpeg"
                                                                                            length:12345
                                                                                            andUrl:@"https://www.healthvault.com/test-blob-url"];
                       [item.blobs addOrUpdateBlob:blobItem];
                       
                       [item serialize:writer];
                       
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
                it(@"should deserialize item", ^
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
                       MHVItemQueryResults *results = [NSObject newFromReader:reader withRoot:@"info" asClass:[MHVItemQueryResults class]];
                       [[theValue(results.hasResults) should] beYes];
                       [[theValue(results.results.count) should] equal:@(1)];
                       
                       //The Result should have one item
                       MHVItemQueryResult *result = [results.results objectAtIndex:0];
                       [[theValue(result.hasItems) should] beYes];
                       [[theValue(result.items.count) should] equal:@(1)];
                       
                       //The typed item in the results should be heartrate
                       MHVItem *item = [result.items objectAtIndex:0];
                       [[item should] beKindOfClass:[MHVItem class]];
                       [[item.data.typed should] beKindOfClass:[MHVHeartRate class]];
                       
                       //The heartrate value should be 106
                       MHVHeartRate *heartRate = item.data.typed;
                       [[theValue(heartRate.bpmValue) should] equal:@(106)];
                   });
            });
});

SPEC_END
