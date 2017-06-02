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

// Gets the http response code...
@property (nonatomic, assign) int statusCode;

/// Gets or sets the informational part of the response.
@property (nonatomic, strong) NSString *infoXml;

/// Gets the response data
@property (nonatomic, strong) NSData *responseData;

@property (nonatomic, strong) NSError *error;

/// Initializes a new instance of the MHVServiceResponse class.
/// The response will be parsed into infoXml
/// @param response - the web response from server side.
/// @param isXML - whether the response HealthVault XML and infoXml should be filled.
- (instancetype)initWithWebResponse:(MHVHttpServiceResponse *)response isXML:(BOOL)isXML;

@end
