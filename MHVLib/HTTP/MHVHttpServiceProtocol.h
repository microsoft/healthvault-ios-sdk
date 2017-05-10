//
// MHVHttpServiceProtocol.h
// MHVLib
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

#import <Foundation/Foundation.h>
@protocol MHVBlobSource;
@class MHVHttpServiceResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVHttpServiceProtocol <NSObject>

/**
 Send a request to HealthVault service

 @param url the endpoint for the request
 @param dataString data to send as POST body (usually XML)
 @param completion response containing result of the operation, or error
 */
- (void)sendRequestForURL:(NSURL *)url
                 withData:(NSString *)dataString
               completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion;

/**
 Send a request to HealthVault service

 @param url the endpoint for the request
 @param dataString data to send as POST body (usually XML)
 @param headers HTTP headers to add to the request for authentication, etc. 
        Dictionary key is HTTP header ie "Content-Type"
 @param completion response containing result of the operation, or error
 */
- (void)sendRequestForURL:(NSURL *)url
                 withData:(NSString *)dataString
                  headers:(NSDictionary<NSString *, NSString *> *_Nullable)headers
               completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion;

/**
 Download a file from HealthVault service to a local file path

 @param url the endpoint for the request
 @param path local file path where the downloaded file will be stored
        For security, the file's protection attributes will be set to NSFileProtectionComplete
 @param completion error if the download failed
 */
- (void)downloadFileWithUrl:(NSURL *)url
                 toFilePath:(NSString *)path
                 completion:(void (^)(NSError *_Nullable error))completion;

/**
 Upload to HealthVault blob storage

 @param blobSource data source for blob (NSData, file, etc)
 @param toUrl the endpoint for the request
 @param chunkSize size is given by HealthVault service when requesting to upload a blob
 @param completion response containing result of the operation, or error
 */
- (void)uploadBlobSource:(id<MHVBlobSource>)blobSource
                   toUrl:(NSURL *)url
               chunkSize:(NSUInteger)chunkSize
              completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
