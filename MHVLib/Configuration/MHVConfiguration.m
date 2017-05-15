//
//  MHVConfiguration.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/15/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVConfiguration.h"
#import "MHVConfigurationConstants.h"

@implementation MHVConfiguration

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Set default values
        self.defaultHealthVaultUrl = [[NSURL alloc] initWithString:kDefaultHealthVaultRootUrlString];
        self.defaultShellUrl = [[NSURL alloc] initWithString:kDefaultShellUrlString];
        self.requestTimeoutDuration = kDefaultRequestTimeoutDurationInSeconds;
        self.requestTimeToLiveDuration = kDefaultRequestTimeToLiveDurationInSeconds;
        self.retryOnInternal500Count = kDefaultRetryOnInternal500Count;
        self.retryOnInternal500SleepDuration = kDefaultRetryOnInternal500SleepDurationInSeconds;
        self.inlineBlobHashBlockSize = kDefaultBlobChunkSizeInBytes;
    }
    
    return self;
}

- (void)setDefaultHealthVaultUrl:(NSURL *)defaultHealthVaultUrl
{
    _defaultHealthVaultUrl = [self ensureTrailingSlashOnUrl:defaultHealthVaultUrl];
}

- (void)setDefaultShellUrl:(NSURL *)defaultShellUrl
{
    _defaultShellUrl = [self ensureTrailingSlashOnUrl:defaultShellUrl];
}

- (void)setRestHealthVaultUrl:(NSURL *)restHealthVaultUrl
{
    _restHealthVaultUrl = [self ensureTrailingSlashOnUrl:restHealthVaultUrl];
}

#pragma mark - Helpers

- (NSURL *)ensureTrailingSlashOnUrl:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    
    if ([urlString hasSuffix:@"/"])
    {
        return url;
    }
    
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", urlString, @"/"]];
}

@end
