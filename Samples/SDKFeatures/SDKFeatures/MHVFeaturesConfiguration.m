//
//  MHVFeaturesConfiguration.m
//  SDKFeatures
//
//  Created by Nathan Malubay on 5/17/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MHVFeaturesConfiguration.h"

@implementation MHVFeaturesConfiguration

+ (MHVConfiguration *)configuration
{
    MHVConfiguration *config = [MHVConfiguration new];
    config.masterApplicationId = [[NSUUID alloc] initWithUUIDString:@"708995a6-4fba-42de-97a8-5feb54e944e8"];
    config.defaultHealthVaultUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform"];
    config.defaultShellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    
#if SHOULD_USE_MULTI_RECORD
    config.isMultiRecordApp = YES;
#endif

    return config;
}

@end
