//
//  MHVConnectionFactoryProtocol.h
//  MHVLib
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

#import <Foundation/Foundation.h>

@class MHVConfiguration;
@protocol MHVSodaConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVConnectionFactoryProtocol <NSObject>

/**
 Gets an instance of MHVSodaConnectionProtocol used to connect to HealthVault

 @param configuration Configuration required for authenticating the connection.
 @param completion Envoked when the operation completes. id<MHVSodaConnectionProtocol> An instance conforming to MHVSodaConnectionProtocol, will be nil if an error occurs. NSError object will be nil if there is no error when performing the operation.
 */
- (void)getOrCreatSodaConnectionWithConfiguration:(MHVConfiguration *)configuration
                                       completion:(void(^)(id<MHVSodaConnectionProtocol> _Nullable connection, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
