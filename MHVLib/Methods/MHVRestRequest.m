//
//  MHVRestRequest.m
//  MHVLib
//
//  Created by Michael Burford on 5/22/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVCommon.h"
#import "MHVRestRequest.h"
#import "MHVCommon.h"

@implementation MHVRestRequest

@synthesize cache = _cache;

- (instancetype)initWithPath:(NSString *)path
                  httpMethod:(NSString *)httpMethod
                  pathParams:(NSDictionary<NSString *, NSString *> *_Nullable)pathParams
                 queryParams:(NSDictionary<NSString *, NSString *> *_Nullable)queryParams
                  formParams:(NSDictionary<NSString *, NSString *> *_Nullable)formParams
                        body:(NSData *_Nullable)body
                 isAnonymous:(BOOL)isAnonymous
{
    MHVASSERT_PARAMETER(path);
    MHVASSERT_PARAMETER(httpMethod);
    
    self = [super init];
    if (self)
    {
        _path = path;
        _httpMethod = httpMethod;
        _pathParams = pathParams;
        _queryParams = queryParams;
        _formParams = formParams;
        _body = body;
        _isAnonymous = isAnonymous;
    }
    return self;
}

- (void)updateUrlWithServiceUrl:(NSURL *)serviceUrl
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:serviceUrl resolvingAgainstBaseURL:YES];
    
    //Path needs to start with / for NSURLComponents
    if (![self.path hasPrefix:@"/"])
    {
        _path = [NSString stringWithFormat:@"/%@", _path];
    }
    urlComponents.path = self.path;
    
    urlComponents.query = [self.queryParams queryString];
    
    _url = urlComponents.URL;
}

- (NSString *)getCacheKey
{
    [NSException throwNotImpl];
    return @"";
}

@end
