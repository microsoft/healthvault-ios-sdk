//
// MHVServiceResponse.h
// MHVLib
//
// Copyright 2017 Microsoft Corp.
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

@class MHVHttpServiceResponse;

@interface MHVServiceResponse : NSObject

// Gets the Http response code...
@property (assign) int statusCode;

/// Gets or sets the informational part of the response.
@property (strong) NSString *infoXml;

@property (nonatomic, strong) NSError *error;

/// Initializes a new instance of the HealthVaultResponse class.
/// @param response - the web response from server side.
/// @request - the original request.
- (instancetype)initWithWebResponse:(MHVHttpServiceResponse *)response;

@end
