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
#import "MHVThingClient.h"
#import "MHVBlobPayloadThing.h"
#import "MHVErrorConstants.h"
#import "MHVHttpService.h"
#import "MHVServiceResponse.h"
#import "MHVConnection.h"
#import "MHVSodaConnection.h"
#import "MHVClientFactory.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVShellAuthServiceProtocol.h"
#import "MHVConfiguration.h"
#import "MHVServiceInstance.h"
#import "MHVSessionCredential.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVThingClientBlobFileTests)

describe(@"MHVThingClient", ^
{
    __block NSData *resultData;
    __block NSError *resultError;
    
    // Mocks
    NSURLSession *urlSession = [KWMock mockForClass:[NSURLSession class]];
    KWMock<MHVKeychainServiceProtocol> *keychainService = [KWMock mockForProtocol:@protocol(MHVKeychainServiceProtocol)];
    KWMock<MHVShellAuthServiceProtocol> *authService = [KWMock mockForProtocol:@protocol(MHVShellAuthServiceProtocol)];
    
    MHVClientFactory *clientFactory = [MHVClientFactory new];
    [(id)keychainService stub:@selector(setXMLObject:forKey:) andReturn:theValue(YES)];
    [(id)keychainService stub:@selector(xmlObjectForKey:) andReturn:nil];
    
    // Test http service
    MHVHttpService *httpService = [[MHVHttpService alloc] initWithURLSession:urlSession];
    
    // Test Connection
    MHVConnection *testConnection = [[MHVSodaConnection alloc] initWithConfiguration:[MHVConfiguration new]
                                                                   cacheSynchronizer:nil
                                                                  cacheConfiguration:nil
                                                                       clientFactory:clientFactory
                                                                         httpService:httpService
                                                                     keychainService:keychainService
                                                                    shellAuthService:authService];
    
    // Set serviceInstance for tests
    testConnection.serviceInstance = [[MHVServiceInstance alloc] init];
    testConnection.serviceInstance.healthServiceUrl = [NSURL URLWithString:@"https://test.url"];
    
    // Mock the download task which downloads to a temporary file
    [urlSession stub:@selector(downloadTaskWithRequest:completionHandler:) withBlock:^id(NSArray *params)
     {
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *path = [[paths firstObject] stringByAppendingPathComponent:@"downloaded.file"];
         
         [resultData writeToFile:path atomically:YES];
         
         void (^completion)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) = params[1];
         completion([NSURL fileURLWithPath:path], [NSURLResponse new], nil);
         
         return nil;
     }];
    
    let(thingClient, ^
        {
            return [[MHVThingClient alloc] initWithConnection:testConnection
                                                        cache:nil];
        });
    
    let(filePath, ^
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[paths firstObject] stringByAppendingPathComponent:@"test.file"];
            
            NSLog(@"File Path: %@", path);
            
            return path;
        });
    
    beforeEach(^
               {
                   resultData = nil;
                   
                   [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
               });
    
#pragma mark - Tests
    
    context(@"DownloadBlob File", ^
            {
                beforeEach(^
                           {
                               resultData = [@"1234567890" dataUsingEncoding:NSUTF8StringEncoding];
                               
                               MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] initWithBlobName:@""
                                                                                                    contentType:@"text/text"
                                                                                                         length:10
                                                                                                         andUrl:@"http://blob.test/path/blob"];
                               
                               [thingClient downloadBlob:blobPayload
                                              toFilePath:filePath
                                              completion:^(NSError *_Nullable error)
                                {
                                    resultData = [NSData dataWithContentsOfFile:filePath];
                                    resultError = error;
                                }];
                           });
                
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should have correct data", ^
                   {
                       [[expectFutureValue(resultData) shouldEventually] beNonNil];
                       
                       NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                       [[expectFutureValue(resultString) shouldEventually] equal:@"1234567890"];
                   });
            });
    
    context(@"DownloadBlob File Inline", ^
            {
                beforeEach(^
                           {
                               MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] init];
                               blobPayload.inlineData = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                               
                               [thingClient downloadBlob:blobPayload
                                              toFilePath:filePath
                                              completion:^(NSError *_Nullable error)
                                {
                                    resultData = [NSData dataWithContentsOfFile:filePath];
                                    resultError = error;
                                }];
                           });
                
                it(@"should have no error", ^
                   {
                       [[expectFutureValue(resultError) shouldEventually] beNil];
                   });
                it(@"should have correct data", ^
                   {
                       [[expectFutureValue(resultData) shouldEventually] beNonNil];
                       
                       NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                       [[expectFutureValue(resultString) shouldEventually] equal:@"123456"];
                   });
            });
    
    context(@"DownloadBlob File Errors", ^
            {
                it(@"should fail if blob payload is nil", ^
                   {
                       MHVBlobPayloadThing *nilBlob = nil;
                       [thingClient downloadBlob:nilBlob
                                      toFilePath:filePath
                                      completion:^(NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });

                it(@"should fail if toFilePath payload is nil", ^
                   {
                       MHVBlobPayloadThing *blobPayload = [[MHVBlobPayloadThing alloc] init];

                       NSString *nilFilePath = nil;
                       [thingClient downloadBlob:blobPayload
                                      toFilePath:nilFilePath
                                      completion:^(NSError *_Nullable error)
                        {
                            resultError = error;
                        }];
                       
                       [[expectFutureValue(resultError) shouldEventually] beNonNil];
                       [[expectFutureValue(theValue(resultError.code)) shouldEventually] equal:@(MHVErrorTypeRequiredParameter)];
                   });
            });
    
});

SPEC_END
