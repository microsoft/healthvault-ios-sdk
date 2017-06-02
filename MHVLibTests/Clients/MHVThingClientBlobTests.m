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
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperationStep1;
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperationStep2;
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperationStep3;
    
    __block MHVServiceResponse *serviceResponseForBeginPut;
    __block MHVServiceResponse *serviceResponseForBlobUpload;
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id(NSArray *params)
     {
         if (!requestedServiceOperationStep1)
         {
             requestedServiceOperationStep1 = params[0];
         }
         else if (!requestedServiceOperationStep2)
         {
             requestedServiceOperationStep2 = params[0];
         }
         else if (!requestedServiceOperationStep3)
         {
             requestedServiceOperationStep3 = params[0];
         }
         
         void (^completion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
         if ([params[0] isKindOfClass:[MHVBlobUploadRequest class]])
         {
             completion(serviceResponseForBlobUpload, nil);
         }
         else
         {
             completion(serviceResponseForBeginPut, nil);
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
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    [thingClient refreshBlobUrlsForThing:allergyThing
                                                recordId:recordId
                                              completion:^(MHVThing *_Nullable thing, NSError *_Nullable error) { }];
                });
                
                let(method, ^{
                    return (MHVMethod *)requestedServiceOperationStep1;
                });
                
                it(@"should get things", ^
                   {
                       [[method.name should] equal:@"GetThings"];
                   });
                it(@"should not be anonymous", ^
                   {
                       [[theValue(method.isAnonymous) should] beNo];
                   });
                it(@"should use correct recordId", ^
                   {
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                   });
                it(@"should have correct info xml", ^
                   {
                       [[theValue([method.parameters containsString:@"<id>AllergyThingKey</id><format><section>core</section>"\
                                   "<section>blobpayload</section><xml/></format></group></info>"]) should] beYes];
                   });
            });
    
    context(@"RefreshBlobUrlsForThing Errors", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                });
                
                it(@"should fail if thing is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient refreshBlobUrlsForThing:nil
                                                   recordId:recordId
                                                 completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if record id is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient refreshBlobUrlsForThing:allergyThing
                                                   recordId:nil
                                                 completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"RefreshBlobUrlsForThingCollection", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    [thingClient refreshBlobUrlsForThings:[[MHVThingCollection alloc] initWithThings:@[allergyThing, fileThing]]
                                                 recordId:recordId
                                               completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error) { }];
                });
                
                let(method, ^{
                    return (MHVMethod *)requestedServiceOperationStep1;
                });
                
                it(@"should get things", ^
                   {
                       [[method.name should] equal:@"GetThings"];
                   });
                it(@"should not be anonymous", ^
                   {
                       [[theValue(method.isAnonymous) should] beNo];
                   });
                it(@"should use correct recordId", ^
                   {
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                   });
                it(@"should have correct info xml", ^
                   {
                       [[theValue([method.parameters containsString:@"<id>AllergyThingKey</id><id>FileThingKey</id><format>"\
                                   "<section>core</section><section>blobpayload</section><xml/></format></group></info>"]) should] beYes];
                   });
            });
    
    context(@"RefreshBlobUrlsForThingCollection Errors", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                });
                
                it(@"should fail if thing collection is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient refreshBlobUrlsForThings:nil
                                                    recordId:recordId
                                                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
                it(@"should fail if record id is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient refreshBlobUrlsForThings:allergyThing
                                                    recordId:nil
                                                  completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
    context(@"DownloadBlob Data", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                         contentType:@"image/jpg"
                                                                                              length:123456
                                                                                              andUrl:@"http://blob.test/path/blob"];
                    [thingClient downloadBlobData:blobPayload
                                       completion:^(NSData * _Nullable data, NSError * _Nullable error) { }];
                });
                
                let(blobDownloadRequest, ^{
                    return (MHVBlobDownloadRequest *)requestedServiceOperationStep1;
                });
                
                it(@"should use correct URL", ^
                   {
                       [[blobDownloadRequest.url.absoluteString should] equal:@"http://blob.test/path/blob"];
                   });
                
                it(@"should not have file path", ^
                   {
                       [[blobDownloadRequest.toFilePath should] beNil];
                   });
                
                it(@"should be an anonymous request", ^
                   {
                       [[theValue(blobDownloadRequest.isAnonymous) should] beYes];
                   });
            });
    
    context(@"DownloadBlob File", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                         contentType:@"image/jpg"
                                                                                              length:123456
                                                                                              andUrl:@"http://blob.test/path/blob"];
                    [thingClient downloadBlob:blobPayload
                                   toFilePath:@"//to/path/name.xyz"
                                   completion:^(NSError * _Nullable error) { }];
                });
                
                let(blobDownloadRequest, ^{
                    return (MHVBlobDownloadRequest *)requestedServiceOperationStep1;
                });
                
                it(@"should use correct URL", ^
                   {
                       [[blobDownloadRequest.url.absoluteString should] equal:@"http://blob.test/path/blob"];
                   });
                
                it(@"should have file path", ^
                   {
                       [[blobDownloadRequest.toFilePath should] equal:@"//to/path/name.xyz"];
                   });
                
                it(@"should be an anonymous request", ^
                   {
                       [[theValue(blobDownloadRequest.isAnonymous) should] beYes];
                   });
            });
    
    context(@"DownloadBlob Data Inline", ^
            {
                __block NSData *returnedData;
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] init];
                    blobPayload.inlineData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    
                    [thingClient downloadBlobData:blobPayload
                                       completion:^(NSData * _Nullable data, NSError * _Nullable error)
                     {
                         returnedData = data;
                     }];
                });
                
                it(@"should return data", ^
                   {
                       [[expectFutureValue(returnedData) shouldEventually] beNonNil];
                       
                       NSString *dataString = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];
                       
                       [[dataString should] equal:@"123456"];
                   });
            });
    
    context(@"DownloadBlob Errors", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                });
                
                it(@"should fail if blob payload is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient downloadBlobData:nil
                                          completion:^(NSData * _Nullable data, NSError * _Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
                
            });

    context(@"UploadBlob step 1", ^
            {
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                    
                    [thingClient addBlobSource:blobSource
                                       toThing:fileThing
                                          name:nil
                                   contentType:@"text/text"
                                      recordId:recordId
                                    completion:^(MHVThing * _Nullable thing, NSError * _Nullable error) { }];
                });
                
                it(@"should begin blob put", ^
                   {
                       MHVMethod *method = (MHVMethod *)requestedServiceOperationStep1;
                       
                       [[method.name should] equal:@"BeginPutBlob"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                   });
            });

    context(@"UploadBlob step 2", ^
            {
                //Mock response for step 1
                NSString *xmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.BeginPutBlob\"><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN</blob-ref-url><blob-chunk-size>123456</blob-chunk-size><max-blob-size>1073741824</max-blob-size><blob-hash-algorithm>SHA256Block</blob-hash-algorithm><blob-hash-parameters><block-size>654321</block-size></blob-hash-parameters></wc:info></response>";
                
                MHVHttpServiceResponse *httpResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[xmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                 statusCode:0];
                
                serviceResponseForBeginPut = [[MHVServiceResponse alloc] initWithWebResponse:httpResponse isXML:YES];
                
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                    
                    [thingClient addBlobSource:blobSource
                                       toThing:fileThing
                                          name:nil
                                   contentType:@"text/text"
                                      recordId:recordId
                                    completion:^(MHVThing * _Nullable thing, NSError * _Nullable error) { }];
                });
                
                let(blobUploadRequest, ^{
                    return (MHVBlobUploadRequest *)requestedServiceOperationStep2;
                });
                
                it(@"should use upload to correct URL", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep2) shouldEventually] beNonNil];
                       
                       [[blobUploadRequest.destinationURL.absoluteString should] equal:@"https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN"];
                   });                

                it(@"should include chunk size", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep2) shouldEventually] beNonNil];
                       
                       [[theValue(blobUploadRequest.chunkSize) should] equal:@(123456)];
                   });
            });

    context(@"UploadBlob step 3", ^
            {
                //Mock response for step 1
                NSString *putXmlResponse = @"<response><status><code>0</code></status><wc:info xmlns:wc=\"urn:com.microsoft.wc.methods.response.BeginPutBlob\"><blob-ref-url>https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN</blob-ref-url><blob-chunk-size>123456</blob-chunk-size><max-blob-size>1073741824</max-blob-size><blob-hash-algorithm>SHA256Block</blob-hash-algorithm><blob-hash-parameters><block-size>654321</block-size></blob-hash-parameters></wc:info></response>";
                
                MHVHttpServiceResponse *putResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:[putXmlResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                 statusCode:0];
                
                serviceResponseForBeginPut = [[MHVServiceResponse alloc] initWithWebResponse:putResponse isXML:YES];
                
                //Mock response for step 2
                MHVHttpServiceResponse *uploadResponse = [[MHVHttpServiceResponse alloc] initWithResponseData:nil
                                                                                                   statusCode:0];

                serviceResponseForBlobUpload = [[MHVServiceResponse alloc] initWithWebResponse:uploadResponse isXML:NO];
                
                __block MHVThing *resultThing;
                
                beforeAll(^{
                    requestedServiceOperationStep1 = nil;
                    requestedServiceOperationStep2 = nil;
                    
                    NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                    MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
                    
                    [thingClient addBlobSource:blobSource
                                       toThing:fileThing
                                          name:nil
                                   contentType:@"text/text"
                                      recordId:recordId
                                    completion:^(MHVThing * _Nullable thing, NSError * _Nullable error) { }];
                });
                
                let(blobUpdateThing, ^{
                    return (MHVMethod *)requestedServiceOperationStep3;
                });
                
                it(@"should PutThings to update thing", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep3) shouldEventually] beNonNil];
                       
                       [[blobUpdateThing.name should] equal:@"PutThings"];
                   });
                
                it(@"should have correct recordId", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep3) shouldEventually] beNonNil];
                       
                       [[blobUpdateThing.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                   });

                it(@"should have posted blob url", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep3) shouldEventually] beNonNil];
                       
                       [[theValue([blobUpdateThing.parameters containsString:@"https://platform.healthvault-ppe.com/streaming/wildcatblob.ashx?blob-ref-token=TOKEN"]) should] beYes];
                   });

                it(@"should have posted correct content length", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep3) shouldEventually] beNonNil];
                       
                       [[theValue([blobUpdateThing.parameters containsString:@"<content-length>6</content-length>"]) should] beYes];
                   });

                it(@"should have posted correct content type", ^
                   {
                       [[expectFutureValue(requestedServiceOperationStep3) shouldEventually] beNonNil];
                       
                       [[theValue([blobUpdateThing.parameters containsString:@"<content-type><text>content/type</text></content-type>"]) should] beYes];
                   });
            });
});

SPEC_END
