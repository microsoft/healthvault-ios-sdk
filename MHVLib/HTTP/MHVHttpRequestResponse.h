//
//  HVURLRequestExtensions.h
//  MHVLib
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
#import "MHVHttp.h"


//-------------------------
//
// MHVHttpResponse
// Typically used just for a Get
//
//-------------------------

@interface MHVHttpResponse : MHVHttp
{
@protected
    NSURLResponse* m_response;
    NSMutableData* m_responseBody;
}

@property (readonly, nonatomic, strong) NSURLResponse* response;
@property (readonly, nonatomic, strong) NSMutableData* responseBody;

@end

//-------------------------
//
// MHVHttpRequestResponse - use for REST style operations
//
//-------------------------

@interface MHVHttpRequestResponse : MHVHttpResponse
{
@protected
    NSData* m_requestBody;
}

@property (readwrite, nonatomic, strong) NSData* requestBody;

@end
