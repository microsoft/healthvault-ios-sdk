//
// MHVThingClientBlobTests.m
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
//

#import <XCTest/XCTest.h>
#import "MHVCommon.h"
#import "MHVThingClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVMethod.h"
#import "MHVAllergy.h"
#import "MHVFile.h"
#import "MHVRestRequest.h"
#import "MHVBlobDownloadRequest.h"
#import "MHVBlobUploadRequest.h"
#import "MHVErrorConstants.h"
#import "MHVServiceResponse.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVThingClientBlobTests)

describe(@"MHVThingClient", ^
{
    //Operation and response for mocking executeHttpServiceOperation
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperation;
    __block MHVServiceResponse *serviceResponse;
    
    //Upload blob has additional operations and responses
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperationForUploadBlob;
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperationForPutThings;
    __block MHVServiceResponse *serviceResponseForUploadBlob;
    __block MHVServiceResponse *serviceResponseForPutThings;
    
    //Results
    __block MHVThing *resultThing;
    __block MHVThingCollection *resultThings;
    __block NSError *resultError;
    __block NSData *resultData;

    beforeEach(^{
        requestedServiceOperation = nil;
        requestedServiceOperationForUploadBlob = nil;
        requestedServiceOperationForPutThings = nil;
        
        serviceResponse = nil;
        serviceResponseForUploadBlob = nil;
        serviceResponseForPutThings = nil;
        
        resultThing = nil;
        resultThings = nil;
        resultError = nil;
        resultData = nil;
    });
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id (NSArray *params)
     {
         void (^completion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
         
         if (!requestedServiceOperation)
         {
             requestedServiceOperation = params[0];
             completion(serviceResponse, nil);
         }
         else if (!requestedServiceOperationForUploadBlob)
         {
             requestedServiceOperationForUploadBlob = params[0];
             completion(serviceResponseForUploadBlob, nil);
         }
         else if (!requestedServiceOperationForPutThings)
         {
             requestedServiceOperationForPutThings = params[0];
             completion(serviceResponseForPutThings, nil);
         }
         
         return nil;
     }];
    
    NSUUID *recordId = [[NSUUID alloc] initWithUUIDString:@"20000000-2000-2000-2000-200000000000"];
    
    let(thingClient, ^
        {
            return [[MHVThingClient alloc] initWithConnection:mockConnection];
        });
    
    let(allergyThing, ^
        {
            MHVAllergy *allergy = [[MHVAllergy alloc] initWithName:@"Bees"];
            allergy.reaction = [[MHVCodableValue alloc] initWithText:@"Itching"];
            
            MHVThing *thing = [[MHVThing alloc] initWithTypedData:allergy];
            thing.key = [[MHVThingKey alloc] initWithID:@"AllergyThingKey" andVersion:@"AllergyVersion"];
            
            return thing;
        });
    
    let(fileThing, ^
        {
            MHVThing *thing = [MHVFile newThingWithName:@"FileName" andContentType:@"content/type"];
            thing.key = [[MHVThingKey alloc] initWithID:@"FileThingKey" andVersion:@"FileVersion"];
            
            return thing;
        });
    
    context(@"RefreshBlobUrlsForThing", ^
            {
                beforeEach(^{
                    // Mock response for refresh blob url
                    NSString *refreshBlobXmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\"><group name=\"648F6C9F-9B07-4272-89F4-19F923D1C65E\"><thing><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id><type-id name=\"File\">bd0403c5-4ae2-4b0e-a8db-1888678e4528</type-id><thing-state>Active</thing-state><flags>0</flags><eff-date>2017-06-02T22:01:52.471</eff-date><data-xml><file><name>FILENAME.JPG</name><size>4491016</size><content-type><text>image/jpeg</text></content-type></file><common /></data-xml><blob-payload><blob><blob-info><name/><content-type>image/jpeg</content-type><hash-info><algorithm>SHA256Block</algorithm><params><block-size>2097152</block-size></params><hash>D4karBmHN0/IYQEMAZg3lyTK62Bi5+rmOf8JtvzPnUo=</hash></hash-info></blob-info><content-length>4491016</content-length><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN</blob-ref-url></blob></blob-payload></thing></group></wc:info></response>";
                    
                    MHVHttpServiceResponse *refreshBlobResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[refreshBlobXmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                         statusCode:0];
                    
                    serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:refreshBlobResponse isXML:YES];
                    
                    [thingClient refreshBlobUrlsForThing:allergyThing
                                                recordId:recordId
                                              completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                    {
                        resultThing = thing;
                        resultError = error;
                    }];
                });
                
                it(@"should be same thing", ^
                   {
                       [[expectFutureValue(resultThing.key.thingID) shouldEventually] equal:allergyThing.key.thingID];
                   });
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should have correct URL for blob", ^
                   {
                       [[expectFutureValue(resultThing.blobs.getDefaultBlob.blobUrl) shouldEventually] equal:@"https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN"];
                   });
            });
    
    context(@"RefreshBlobUrlsForThing Errors", ^
            {
                it(@"should fail if thing is nil", ^
                   {
                       [thingClient refreshBlobUrlsForThing:nil
                                                   recordId:recordId
                                                 completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(resultThing) shouldEventually] beNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if record id is nil", ^
                   {
                       [thingClient refreshBlobUrlsForThing:allergyThing
                                                   recordId:nil
                                                 completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(resultThing) shouldEventually] beNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"RefreshBlobUrlsForThingCollection", ^
            {
                beforeEach(^{
                    // Mock response for refresh blob urls
                    NSString *refreshBlobXmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.GetThings3\"><group name=\"648F6C9F-9B07-4272-89F4-19F923D1C65E\"><thing><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id><type-id name=\"File\">bd0403c5-4ae2-4b0e-a8db-1888678e4528</type-id><thing-state>Active</thing-state><flags>0</flags><eff-date>2017-06-02T22:01:52.471</eff-date><data-xml><file><name>FILENAME.JPG</name><size>4491016</size><content-type><text>image/jpeg</text></content-type></file><common /></data-xml><blob-payload><blob><blob-info><name/><content-type>image/jpeg</content-type><hash-info><algorithm>SHA256Block</algorithm><params><block-size>2097152</block-size></params><hash>D4karBmHN0/IYQEMAZg3lyTK62Bi5+rmOf8JtvzPnUo=</hash></hash-info></blob-info><content-length>4491016</content-length><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN</blob-ref-url></blob></blob-payload></thing>"\
                    "<thing><thing-id version-stamp=\"FileVersion\">FileThingKey</thing-id><type-id name=\"File\">bd0403c5-4ae2-4b0e-a8db-1888678e4528</type-id><thing-state>Active</thing-state><flags>0</flags><eff-date>2017-06-02T22:01:52.471</eff-date><data-xml><file><name>FILENAME.JPG</name><size>4491016</size><content-type><text>image/jpeg</text></content-type></file><common /></data-xml><blob-payload><blob><blob-info><name/><content-type>image/jpeg</content-type><hash-info><algorithm>SHA256Block</algorithm><params><block-size>2097152</block-size></params><hash>D4karBmHN0/IYQEMAZg3lyTK62Bi5+rmOf8JtvzPnUo=</hash></hash-info></blob-info><content-length>4491016</content-length><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=FILETOKEN</blob-ref-url></blob></blob-payload></thing></group></wc:info></response>";
                    
                    MHVHttpServiceResponse *refreshBlobResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[refreshBlobXmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                            statusCode:0];
                    
                    serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:refreshBlobResponse isXML:YES];
                    
                    [thingClient refreshBlobUrlsForThings:[[MHVThingCollection alloc] initWithThings:@[allergyThing, fileThing]]
                                                 recordId:recordId
                                               completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
                    {
                        resultThings = things;
                        resultError = error;
                    }];
                });
                
                 it(@"should be 2 things", ^
                   {
                       [[expectFutureValue(theValue(resultThings.count)) shouldEventually] equal:@(2)];
                   });
                it(@"should contain things", ^
                   {
                       [[expectFutureValue(theValue([resultThings containsThingID:allergyThing.thingID])) shouldEventually] beYes];
                       [[expectFutureValue(theValue([resultThings containsThingID:fileThing.thingID])) shouldEventually] beYes];
                   });
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should have correct urls for blobs", ^
                   {
                       [[expectFutureValue(theValue([resultThings containsThingID:allergyThing.thingID])) shouldEventually] beYes];
                       [[expectFutureValue(theValue([resultThings containsThingID:fileThing.thingID])) shouldEventually] beYes];
                       
                       MHVThing *resultAllergyThing = [resultThings objectAtIndex:[resultThings indexOfThingID:allergyThing.thingID]];
                       MHVThing *resultFileThing = [resultThings objectAtIndex:[resultThings indexOfThingID:fileThing.thingID]];
                       
                       [[resultAllergyThing.blobs.getDefaultBlob.blobUrl should] equal:@"https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN"];
                       [[resultFileThing.blobs.getDefaultBlob.blobUrl should] equal:@"https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=FILETOKEN"];
                   });
            });
    
    context(@"RefreshBlobUrlsForThingCollection Errors", ^
            {
                it(@"should fail if thing collection is nil", ^
                   {
                       [thingClient refreshBlobUrlsForThings:nil
                                                    recordId:recordId
                                                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(resultThing) shouldEventually] beNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if record id is nil", ^
                   {
                       [thingClient refreshBlobUrlsForThings:allergyThing
                                                    recordId:nil
                                                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(resultThing) shouldEventually] beNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"DownloadBlob Data", ^
            {
                beforeEach(^{
                    MHVHttpServiceResponse *refreshBlobResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[@"1234567890" dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                            statusCode:0];
                    
                    serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:refreshBlobResponse isXML:NO];
                    
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                         contentType:@"text/text"
                                                                                              length:10
                                                                                              andUrl:@"http://blob.test/path/blob"];
                    [thingClient downloadBlobData:blobPayload
                                       completion:^(NSData *_Nullable data, NSError *_Nullable error)
                    {
                        resultData = data;
                        resultError = error;
                    }];
                });
                
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should have correct data", ^
                   {
                       [[expectFutureValue([[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]) shouldEventually] equal:@"1234567890"];
                   });
            });
    
    context(@"DownloadBlob Data Inline", ^
            {
                beforeEach(^{
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] init];
                    blobPayload.inlineData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    
                    [thingClient downloadBlobData:blobPayload
                                       completion:^(NSData *_Nullable data, NSError *_Nullable error)
                     {
                         resultData = data;
                     }];
                });
                
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should return data", ^
                   {
                       [[expectFutureValue(resultData) shouldEventually] beNonNil];
                       
                       NSString *dataString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                       
                       [[dataString should] equal:@"123456"];
                   });
            });
    
    context(@"DownloadBlob Errors", ^
            {
                it(@"should fail if blob payload is nil", ^
                   {
                       [thingClient downloadBlobData:nil
                                          completion:^(NSData *_Nullable data, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"AddBlobToThing Errors", ^
            {
                it(@"should fail if blobSource is nil", ^
                   {
                       [thingClient addBlobSource:nil
                                          toThing:fileThing
                                             name:nil
                                      contentType:@"text/text"
                                         recordId:recordId
                                       completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if toThing is nil", ^
                   {
                       NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                       MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                       
                       [thingClient addBlobSource:blobSource
                                          toThing:nil
                                             name:nil
                                      contentType:@"text/text"
                                         recordId:recordId
                                       completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if contentType is nil", ^
                   {
                       NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                       MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                       
                       [thingClient addBlobSource:blobSource
                                          toThing:fileThing
                                             name:nil
                                      contentType:nil
                                         recordId:recordId
                                       completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if recordId is nil", ^
                   {
                       NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                       MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                       
                       [thingClient addBlobSource:blobSource
                                          toThing:fileThing
                                             name:nil
                                      contentType:@"text/text"
                                         recordId:nil
                                       completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"AddBlobToThing", ^
            {
                beforeEach(^{
                    // Mock response for get blob upload info with BeginPutBlob
                    NSString *beginPutXmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.BeginPutBlob\"><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN</blob-ref-url><blob-chunk-size>123456</blob-chunk-size><max-blob-size>1073741824</max-blob-size><blob-hash-algorithm>SHA256Block</blob-hash-algorithm><blob-hash-parameters><block-size>654321</block-size></blob-hash-parameters></wc:info></response>";
                    
                    MHVHttpServiceResponse *beginPutResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[beginPutXmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                         statusCode:0];
                    
                    serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:beginPutResponse isXML:YES];
                    
                    // Mock response for uploading data
                    MHVHttpServiceResponse *uploadResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:nil
                                                                                                       statusCode:0];
                    
                    serviceResponseForUploadBlob = [[MHVServiceResponse alloc] initWithWebResponse:uploadResponse isXML:NO];
                    
                    // Mock response for update thing with PutThings
                    NSString *putThingsXmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.PutThings\">" \
                    "<thing-id version-stamp=\"11111111-1111-1111-1111-111111111111\">22222222-2222-2222-2222-222222222222</thing-id></wc:info></response>";
                    
                    MHVHttpServiceResponse *putThingsResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[putThingsXmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                          statusCode:0];
                    
                    serviceResponseForPutThings = [[MHVServiceResponse alloc] initWithWebResponse:putThingsResponse isXML:YES];
                    
                    // Create data for blob
                    NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                    
                    [thingClient addBlobSource:blobSource
                                       toThing:fileThing
                                          name:nil
                                   contentType:@"text/text"
                                      recordId:recordId
                                    completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                     {
                         resultThing = thing;
                     }];
                });
                
                it(@"should have resultThing", ^
                   {
                       [[expectFutureValue(resultThing) shouldEventually] beNonNil];
                   });
                it(@"resultThing should have 1 blob", ^
                   {
                       [[expectFutureValue(theValue(resultThing.blobs.things.count)) shouldEventually] equal:@(1)];
                   });
                it(@"resultThing blob should be correct size", ^
                   {
                       [[expectFutureValue(theValue(resultThing.blobs.getDefaultBlob.length)) shouldEventually] equal:@(6)];
                   });
                it(@"resultThing blob should have correct content type", ^
                   {
                       [[expectFutureValue(resultThing.blobs.getDefaultBlob.contentType) shouldEventually] equal:@"text/text"];
                   });
            });
});

SPEC_END
