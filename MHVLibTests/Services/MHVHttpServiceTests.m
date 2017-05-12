//
// MHVHttpServiceTests.h
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
#import "MHVHttpService.h"
#import "MHVBlobSource.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVHttpServiceTests)

describe(@"MHVHttpService", ^
{
    context(@"Requests", ^
    {
        id urlSessionMock = [NSURLSession mock];
        MHVHttpService *service = [[MHVHttpService alloc] initWithURLSession:urlSessionMock];
        
        let(spyRequest, ^
        {
            return [urlSessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:) atIndex:0];
        });
        
        it(@"should perform post to correct address", ^
           {
               //Send request
               [service sendRequestForURL:[NSURL URLWithString:@"https://test.com/path"]
                                     body:@"testbody"
                               completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) { }];

               //Verify URLRequest values
               NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
               
               [[[requested.URL absoluteString] should] equal:@"https://test.com/path"];
               [[requested.HTTPMethod should] equal:@"POST"];
               
               NSString *bodyAsString = [[NSString alloc] initWithData:requested.HTTPBody encoding:NSUTF8StringEncoding];
               [[bodyAsString should] equal:@"testbody"];
           });
        
        it(@"should include headers", ^
           {
               //Send request
               [service sendRequestForURL:[NSURL URLWithString:@"https://test.com/path"]
                                     body:@"testbody"
                                  headers:@{
                                            @"Header-One" : @"ABC",
                                            @"Header-Two" : @"123",
                                            }
                               completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) { }];
               
               //Verify URLRequest values
               NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
               
               [[[requested.URL absoluteString] should] equal:@"https://test.com/path"];
               [[requested.HTTPMethod should] equal:@"POST"];
               
               NSString *bodyAsString = [[NSString alloc] initWithData:requested.HTTPBody encoding:NSUTF8StringEncoding];
               [[bodyAsString should] equal:@"testbody"];
               
               [[requested.allHTTPHeaderFields[@"Header-One"] should] equal:@"ABC"];
               [[requested.allHTTPHeaderFields[@"Header-Two"] should] equal:@"123"];
           });

        it(@"should perform get to correct address", ^
           {
               //Send request
               [service sendRequestForURL:[NSURL URLWithString:@"https://test.com/path"]
                                     body:nil
                               completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) { }];
               
               //Verify URLRequest values
               NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
               
               [[[requested.URL absoluteString] should] equal:@"https://test.com/path"];
               [[requested.HTTPMethod should] equal:@"GET"];
               
               [[requested.HTTPBody should] beNil];
           });
    });

    context(@"Downloads", ^
            {
                id urlSessionMock = [NSURLSession mock];
                MHVHttpService *service = [[MHVHttpService alloc] initWithURLSession:urlSessionMock];
                
                let(spyRequest, ^
                    {
                        return [urlSessionMock captureArgument:@selector(downloadTaskWithRequest:completionHandler:) atIndex:0];
                    });
                
                it(@"should download data from correct address", ^
                   {
                       //Send request
                       [service downloadDataWithUrl:[NSURL URLWithString:@"https://test.com/download"]
                                       completion:^(NSData *_Nullable data, NSError *_Nullable error) { }];
                       
                       //Verify URLRequest values
                       NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
                       
                       [[[requested.URL absoluteString] should] equal:@"https://test.com/download"];
                       [[requested.HTTPMethod should] equal:@"GET"];
                       [[requested.HTTPBody should] beNil];
                   });
                
                it(@"should download file from correct address", ^
                   {
                       //Send request
                       [service downloadFileWithUrl:[NSURL URLWithString:@"https://test.com/download"]
                                         toFilePath:@"ToPath"
                                         completion:^(NSError *_Nullable error) { }];
                       
                       //Verify URLRequest values
                       NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
                       
                       [[[requested.URL absoluteString] should] equal:@"https://test.com/download"];
                       [[requested.HTTPMethod should] equal:@"GET"];
                       [[requested.HTTPBody should] beNil];
                   });
                
            });
    
    context(@"Uploads", ^
            {
                id urlSessionMock = [NSURLSession mock];
                MHVHttpService *service = [[MHVHttpService alloc] initWithURLSession:urlSessionMock];
                
                NSString *string = [@"B" stringByPaddingToLength:1000 withString:@"A" startingAtIndex:0];
                NSData *blobData = [string dataUsingEncoding:NSUTF8StringEncoding];
                MHVBlobMemorySource *blobSource = [[MHVBlobMemorySource alloc] initWithData:blobData];
                
                let(spyRequest, ^
                    {
                        return [urlSessionMock captureArgument:@selector(dataTaskWithRequest:completionHandler:) atIndex:0];
                    });
                
                it(@"should upload data to correct address", ^
                   {
                       //Send request
                       [service uploadBlobSource:blobSource
                                           toUrl:[NSURL URLWithString:@"https://test.com/upload"]
                                       chunkSize:123456
                                      completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                       
                       //Verify URLRequest values
                       NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
                       
                       [[[requested.URL absoluteString] should] equal:@"https://test.com/upload"];
                       [[requested.HTTPMethod should] equal:@"POST"];
                       [[theValue(requested.HTTPBody.length) should] equal:@(1000)];
                       [[requested.allHTTPHeaderFields[@"Content-Range"] should] equal:@"bytes 0-999/*"];
                   });

                it(@"should upload using chunk size", ^
                   {
                       //Send request
                       [service uploadBlobSource:blobSource
                                           toUrl:[NSURL URLWithString:@"https://test.com/upload"]
                                       chunkSize:500
                                      completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error) { }];
                       
                       //Verify URLRequest values
                       NSURLRequest *requested = (NSURLRequest *)spyRequest.argument;
                       
                       [[theValue(requested.HTTPBody.length) should] equal:@(500)];
                       [[requested.allHTTPHeaderFields[@"Content-Range"] should] equal:@"bytes 0-499/*"];
                   });
            });
});

SPEC_END
