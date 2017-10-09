//
//  MHVRestRequest.m
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

#import "MHVRestRequest.h"
#import "MHVValidator.h"
#import "MHVDictionaryExtensions.h"
#import "MHVValidator.h"
#import "MHVLogger.h"

@implementation MHVRestRequest

@synthesize cache = _cache;

- (instancetype)initWithBaseUrl:(NSURL *)baseUrl
                           path:(NSString *)path
                     httpMethod:(NSString *)httpMethod
                     pathParams:(NSDictionary<NSString *, NSString *> *_Nullable)pathParams
                    queryParams:(NSDictionary<NSString *, NSString *> *_Nullable)queryParams
                        headers:(NSDictionary<NSString *, NSString *> *_Nullable)headers
                           body:(NSData *_Nullable)body
                    isAnonymous:(BOOL)isAnonymous
{
    MHVASSERT_PARAMETER(path);
    MHVASSERT_PARAMETER(httpMethod);
    
    self = [super init];
    if (self)
    {
        _baseUrl = baseUrl;
        _path = path;
        _httpMethod = httpMethod;
        _pathParams = pathParams;
        _queryParams = queryParams;
        _headers = headers;
        _body = body;
        _isAnonymous = isAnonymous;
    }
    return self;
}

- (void)updateUrlWithServiceUrl:(NSURL *)serviceUrl
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:serviceUrl resolvingAgainstBaseURL:YES];
    
    // Path needs to start with / for NSURLComponents.  (stringByAppendingPathComponent will add correctly if self.path already starts with "/")
    urlComponents.path = [@"/" stringByAppendingPathComponent:self.path];

    urlComponents.query = [self.queryParams queryString];
    
    _url = urlComponents.URL;
}

- (void)updateUrlFromBaseUrl
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:self.baseUrl resolvingAgainstBaseURL:YES];
    
    // Append Path to base URL's path
    if (self.path)
    {
        // Path needs to start with / for NSURLComponents.  (stringByAppendingPathComponent will add correctly if self.path already starts with "/")
        urlComponents.path = [(urlComponents.path ?: @"/") stringByAppendingPathComponent:self.path];
    }
    
    urlComponents.query = [self.queryParams queryString];
    
    _url = urlComponents.URL;
}

- (NSString *)getCacheKey
{
    MHVLOG(@"getCacheKey not implemented for MHVRestRequest");
    return @"";
}

@end
