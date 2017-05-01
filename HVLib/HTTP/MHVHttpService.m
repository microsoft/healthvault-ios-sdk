//
// MHVHttpService.m
// HVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVHttpService.h"
#import "MHVHttpResponse.h"
#import "Logger.h"

@interface MHVHttpService () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSOperationQueue *certificateCheckQueue;

@end

@implementation MHVHttpService

- (instancetype)initWithURLSessionConfiguration:(NSURLSessionConfiguration *_Nullable)urlSessionConfiguration
{
    if (!urlSessionConfiguration)
    {
        urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    self = [super init];
    if (self)
    {
        _urlSession = [[NSURLSession sessionWithConfiguration:urlSessionConfiguration
                                                     delegate:self
                                                delegateQueue:nil] retain];
        
        _certificateCheckQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)sendRequestForURL:(NSURL *)url
                 withData:(NSString *)dataString
               completion:(void (^)(MHVHttpResponse *_Nullable response, NSError *_Nullable error))completion
{
    NSURLRequest *request = [self requestWithUrl:url data:dataString];

    [Logger write:[NSString stringWithFormat:@"Begin request %li", (long)dataString.hash]];

    [[self.urlSession dataTaskWithRequest:(NSURLRequest *)request
                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
          
          [Logger write:[NSString stringWithFormat:@"Response for %li has status code: %li", (long)dataString.hash, (long)statusCode]];
          
          if (error)
          {
              completion(nil, error);
              return;
          }
          
          MHVHttpResponse *mhvResponse = [[MHVHttpResponse alloc] initWithResponseData:data
                                                                            statusCode:statusCode];
          
          completion(mhvResponse, nil);
      }] resume];
}

- (void)downloadFileWithUrl:(NSURL *)url
                 toFilePath:(NSString *)path
                 completion:(void (^)(NSError *_Nullable error))completion
{
    NSURLRequest *request = [self requestWithUrl:url data:nil];
    
    [[self.urlSession downloadTaskWithRequest:request
                            completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (error)
          {
              completion(error);
              return;
          }
          
          NSError *fileError;
          if (![[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:&fileError])
          {
              completion(fileError);
          }
          else
          {
              completion(nil);
          }
      }] resume];
}

- (void)uploadFileWithPath:(NSString *)path
                     toUrl:(NSURL *)url
                completion:(void (^)(NSError *_Nullable error))completion
{
    NSURLRequest *request = [self requestWithUrl:url data:nil];
    
    [[self.urlSession uploadTaskWithRequest:request
                                   fromFile:[NSURL fileURLWithPath:path]
                          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          completion(error);
      }] resume];
}

#pragma mark -

- (NSURLRequest *)requestWithUrl:(NSURL *)url data:(NSString *)dataString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    if (dataString)
    {
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        
        request.HTTPMethod = @"POST";
        request.HTTPBody = data;
        
        [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    }
    
    return request;
}

#pragma mark - NSURLSessionDelegate

- (void)     URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler
{
    // Check if certificate chain is valid or returns an error (SecTrustEvaluate is syncronous, so perform check on a Queue)
    [self.certificateCheckQueue addOperationWithBlock:^
     {
         SecTrustResultType result;
         SecTrustEvaluate([challenge.protectionSpace serverTrust], &result);
         
         // Unspecified is a valid certificate, but not specifically accepted in the keychain (iOS's normal response)
         if (result == kSecTrustResultUnspecified ||
             result == kSecTrustResultProceed)
         {
             completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
         }
         else
         {
             NSLog(@"SecTrustEvaluate failed %li", (long)result);
             
             completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
         }
     }];
}

@end
