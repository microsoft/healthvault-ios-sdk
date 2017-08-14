//
//  MHVFeaturesConfiguration.m
//  SDKFeatures
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

#import "MHVFeaturesConfiguration.h"

@implementation MHVFeaturesConfiguration

+ (MHVConfiguration *)configuration
{
    MHVConfiguration *config = [MHVConfiguration new];

    /*
    config.masterApplicationId = [[NSUUID alloc] initWithUUIDString:@"7c81b435-f091-4444-9534-59eb53da66c9"];
    config.defaultHealthVaultUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform"];
    config.defaultShellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    config.restHealthVaultUrl = [[NSURL alloc] initWithString:@"https://data.ppe.microsofthealth.net"];
    config.restVersion = @"1.0-rc";
     */
    
    
     config.masterApplicationId = [[NSUUID alloc] initWithUUIDString:@"34998e3c-ba6e-49da-bd57-55c0817491e0"];
     config.defaultHealthVaultUrl = [[NSURL alloc] initWithString:@"https://platform.hvazads03.healthvault-test.com/platform"];
     config.defaultShellUrl = [[NSURL alloc] initWithString:@"https://account.hvazads03.healthvault-test.com"];
     config.restHealthVaultUrl = [[NSURL alloc] initWithString:@"https://hvc-dev-khvwus01.westus2.cloudapp.azure.com"];
     config.restVersion = @"2.0-preview";
    
    
    
#if SHOULD_USE_MULTI_RECORD
    config.isMultiRecordApp = YES;
#endif
    
    return config;
}

@end
