//
//  MHVConfigurationConstants.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/15/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#ifndef MHVConfigurationConstants_h
#define MHVConfigurationConstants_h

/*
 The default number of internal retries.
 */
static NSInteger const kDefaultRetryOnInternal500Count = 2;

/*
 Default URL for Shell application
 */
static NSString *const kDefaultShellUrlString = @"https://account.healthvault.com";

/*
 Default URL for HealthVault application
 */
static NSString *const kDefaultHealthVaultRootUrlString = @"https://platform.healthvault.com/platform/";

/*
 Default sleep duration in seconds.
 */
static NSTimeInterval const kDefaultRetryOnInternal500SleepDurationInSeconds = 60;

/*
 The default request time to live value.
 */
static NSTimeInterval const kDefaultRequestTimeToLiveDurationInSeconds = 60 * 30;

/*
 The default request time out value.
 */
static NSTimeInterval const kDefaultRequestTimeoutDurationInSeconds = 30;

/*
 The default blob upload chunk size.
 */
static NSInteger const kDefaultBlobChunkSizeInBytes = 1 << 21; // 2Mb.

#endif /* MHVConfigurationConstants_h */
