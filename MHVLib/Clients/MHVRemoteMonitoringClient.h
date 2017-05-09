//
// MHVRemoteMonitoringClient.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHVRemoteMonitoringClient : NSObject

@property (nonatomic, strong) NSString *id;

/**
 * Performs request
 *
 * @param path Request url.
 * @param method Request method.
 * @param pathParams Request path parameters.
 * @param queryParams Request query parameters.
 * @param formParams Request form parameters.
 * @param body Request body.
 * @param toClass the response should be deserialized to.
 * @param completionBlock The block will be executed when the request completed.
 *
 * @return The created session task.
 */
+ (NSURLSessionTask*) requestWithPath: (NSString* _Nonnull) path
                               method: (NSString* _Nonnull) method
                           pathParams: (NSDictionary * _Nullable) pathParams
                          queryParams: (NSDictionary* _Nullable) queryParams
                           formParams: (NSDictionary * _Nullable) formParams
                                 body: (id _Nullable) body
                              toClass: (Class) toClass
                      completionBlock: (void (^ _Nonnull)(id _Nullable output, NSError * _Nullable error))completionBlock;


@end

NS_ASSUME_NONNULL_END
