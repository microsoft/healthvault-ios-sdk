//
// MHVRemoteMonitoringClientProtocol.h
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

@protocol MHVRemoteMonitoringClientProtocol <NSObject>

/**
 * Performs request
 *
 * @param path Request url.
 * @param method Request method, "GET", "POST", "PATCH", etc
 * @param pathParams Request path parameters.  Values in {brackets} in the path will be replaced by values from this dictionary
 *        pathParams { @"date" : @"2017-05-23" } with path @"endDate={date}" would result in @"endDate=2017-05-23"
 * @param queryParams Request query parameters dictionary
 * @param formParams Request form parameters.
 * @param body Request body.
 * @param toClass the class the response should be deserialized to.
 * @param completion The block will be executed when the request completed.
 *
 * @return The created session task.
 */
+ (NSURLSessionTask *)requestWithPath:(NSString *)path
                               method:(NSString *)method
                           pathParams:(NSDictionary<NSString *, NSString *> *_Nullable)pathParams
                          queryParams:(NSDictionary<NSString *, NSString *> *_Nullable)queryParams
                           formParams:(NSDictionary<NSString *, NSString *> *_Nullable)formParams
                                 body:(NSData *_Nullable)body
                              toClass:(Class)toClass
                           completion:(void(^)(id _Nullable output, NSError *_Nullable error))completion;

- (void)requestWithPath:(NSString *)path
                 method:(NSString *)method
             pathParams:(NSDictionary<NSString *, NSString *> *_Nullable)pathParams
            queryParams:(NSDictionary<NSString *, NSString *> *_Nullable)queryParams
             formParams:(NSDictionary<NSString *, NSString *> *_Nullable)formParams
                   body:(NSData *_Nullable)body
                toClass:(Class)toClass
             completion:(void(^)(id _Nullable output, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
