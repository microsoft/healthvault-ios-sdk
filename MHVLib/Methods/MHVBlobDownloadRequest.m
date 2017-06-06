//
//  MHVBlobDownloadRequest.m
//  MHVLib
//
//  Created by Michael Burford on 6/2/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVCommon.h"
#import "MHVBlobDownloadRequest.h"

@implementation MHVBlobDownloadRequest

@synthesize cache = _cache;

- (instancetype)initWithURL:(NSURL *)url
                 toFilePath:(NSString *)toFilePath
{
    MHVASSERT_PARAMETER(url);
    MHVASSERT_PARAMETER(toFilePath);
    
    self = [super init];
    if (self)
    {
        _url = url;
        _toFilePath = toFilePath;
        _isAnonymous = YES;
    }
    return self;
}

- (NSString *)getCacheKey
{
    [NSException throwNotImpl];
    return @"";
}

@end
