//
// MHVThingClientTests.m
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
#import "MHVErrorConstants.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVThingClientTests)

describe(@"MHVThingClient", ^
{
    __block id<MHVHttpServiceOperationProtocol> requestedServiceOperation;
    
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    [mockConnection stub:@selector(executeHttpServiceOperation:completion:) withBlock:^id(NSArray *params)
    {
        requestedServiceOperation = params[0];
        
        void (^completion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error) = params[1];
        completion(nil, nil);
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
            MHVFile *file = [[MHVFile alloc] init];
            
            MHVThing *thing = [[MHVThing alloc] initWithTypedData:file];
            thing.key = [[MHVThingKey alloc] initWithID:@"FileThingKey" andVersion:@"FileVersion"];
            
            return thing;
        });

    context(@"GetThings", ^
            {
                it(@"should get with thing id", ^
                   {
                       [thingClient getThingWithThingId:[[NSUUID alloc] initWithUUIDString:@"10000000-1000-1000-1000-100000000000"]
                                               recordId:recordId
                                             completion:^(MHVThing *_Nullable thing, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)requestedServiceOperation;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[theValue([method.parameters containsString:@"<id>10000000-1000-1000-1000-100000000000</id><format><section>core</section><xml/></format></group></info>"]) should] beYes];
                   });
  
                it(@"should get for thing class", ^
                   {
                       [thingClient getThingsForThingClass:[MHVAllergy class]
                                                     query:[MHVThingQuery new]
                                                  recordId:recordId
                                                completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error) { }];
                       
                       MHVMethod *method = (MHVMethod *)requestedServiceOperation;
                       
                       [[method.name should] equal:@"GetThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[theValue([method.parameters containsString:@"<filter><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><thing-state>Active</thing-state></filter>"\
                                   "<format><section>core</section><xml/></format></group></info>"]) should] beYes];
                   });
                
                it(@"should fail if thing id is nil", ^
                   {
                       __block NSError *requestError;
                       [thingClient getThingWithThingId:nil
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
                       [thingClient getThingWithThingId:[[NSUUID alloc] initWithUUIDString:@"10000000-1000-1000-1000-100000000000"]
                                               recordId:nil
                                             completion:^(MHVThing *_Nullable thing, NSError *_Nullable error)
                        {
                            requestError = error;
                        }];
                       
                       [[requestError should] beNonNil];
                       [[theValue(requestError.code) should] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });

    context(@"PutThings", ^
            {
                it(@"should create new thing", ^
                   {
                       [thingClient createNewThing:allergyThing
                                          recordId:recordId
                                        completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)requestedServiceOperation;
                       
                       [[method.name should] equal:@"PutThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing><type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><flags>0</flags>"\
                        "<data-xml><allergy><name><text>Bees</text></name><reaction><text>Itching</text></reaction></allergy><common/></data-xml></thing></info>"];
                   });
                
                it(@"should update a thing", ^
                   {
                       [thingClient updateThing:allergyThing
                                       recordId:recordId
                                     completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)requestedServiceOperation;
                       
                       [[method.name should] equal:@"PutThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id>"\
                        "<type-id>52bf9104-2c5e-4f1f-a66d-552ebcc53df7</type-id><flags>0</flags><data-xml>"\
                        "<allergy><name><text>Bees</text></name><reaction><text>Itching</text></reaction></allergy><common/></data-xml></thing></info>"];
                   });
            });

    context(@"DeleteThings", ^
            {
                it(@"should delete a thing", ^
                   {
                       [thingClient removeThing:allergyThing
                                       recordId:recordId
                                     completion:^(NSError *error) { }];
                       
                       MHVMethod *method = (MHVMethod *)requestedServiceOperation;
                       
                       [[method.name should] equal:@"RemoveThings"];
                       [[theValue(method.isAnonymous) should] beNo];
                       [[method.recordId.UUIDString should] equal:@"20000000-2000-2000-2000-200000000000"];
                       [[method.parameters should] equal:@"<info><thing-id version-stamp=\"AllergyVersion\">AllergyThingKey</thing-id></info>"];
                   });
            });

    context(@"RefreshBlobUrlsForThing", ^
            {
                beforeAll(^{
                    [thingClient refreshBlobUrlsForThing:allergyThing
                                                recordId:recordId
                                              completion:^(MHVThing *_Nullable thing, NSError *_Nullable error) { }];
                });
                
                let(method, ^{
                    return (MHVMethod *)requestedServiceOperation;
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
                    [thingClient refreshBlobUrlsForThings:[[MHVThingCollection alloc] initWithThings:@[allergyThing, fileThing]]
                                                 recordId:recordId
                                               completion:^(MHVThingCollection *_Nullable things, NSError *_Nullable error) { }];
                });
                
                let(method, ^{
                    return (MHVMethod *)requestedServiceOperation;
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
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                         contentType:@"image/jpg"
                                                                                              length:123456
                                                                                              andUrl:@"http://blob.test/path/blob"];
                    [thingClient downloadBlobData:blobPayload
                                       completion:^(NSData * _Nullable data, NSError * _Nullable error) { }];
                });
                
                let(blobDownloadRequest, ^{
                    return (MHVBlobDownloadRequest *)requestedServiceOperation;
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
                    MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                         contentType:@"image/jpg"
                                                                                              length:123456
                                                                                              andUrl:@"http://blob.test/path/blob"];
                    [thingClient downloadBlob:blobPayload
                                   toFilePath:@"//to/path/name.xyz"
                                   completion:^(NSError * _Nullable error) { }];
                });
                
                let(blobDownloadRequest, ^{
                    return (MHVBlobDownloadRequest *)requestedServiceOperation;
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
});

SPEC_END
