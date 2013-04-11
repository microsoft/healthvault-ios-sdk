//
//  HVMoreFeatures.m
//  SDKFeatures
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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

#import "HVMoreFeatures.h"

@implementation HVMoreFeatures

+(void)disconnectApp:(UIViewController *)parentController
{
    [HVUIAlert showYesNoWithMessage:@"Are you sure you want to disconnect this application from HealthVault?\r\nIf you click Yes, you will need to re-authorize the next time you run it." callback:^(id sender) {
        
        HVUIAlert* alert = (HVUIAlert *) sender;
        if (alert.result != HVUIAlertOK)
        {
            return;
        }

        [[HVClient current].user removeAuthForRecord:[HVClient current].currentRecord withCallback:^(HVTask *task) {
            
            [[HVClient current] resetProvisioning];  // Removes local state
            
            [parentController.navigationController popViewControllerAnimated:TRUE];
        }];
    }];
}

+(void)getServiceDefinition
{
    [[[[HVGetServiceDefinitionTask alloc] initWithCallback:^(HVTask *task) {
        
        [task checkSuccess];
        HVServiceDefinition* serviceDef = ((HVGetServiceDefinitionTask *) task).serviceDef;
        //
        // Show some sample information
        //
        HVConfigurationEntry* configEntry = [serviceDef.platform.config objectAtIndex:0];
        HVConfigurationEntry* configEntry2 = [serviceDef.platform.config objectAtIndex:1];
        NSMutableString* output = [[[NSMutableString alloc] init] autorelease];
        
        [output appendLines:17, @"Some data from ServiceDefinition",
                               @"[PlatformUrl]", serviceDef.platform.url,
                               @"[PlatformVersion]", serviceDef.platform.version,
                               @"[ShellUrl]", serviceDef.shell.url,
                               @"[ShellRedirect]", serviceDef.shell.redirectUrl,
                               @"[Example Config Entries]",
                               configEntry.key, @"==", configEntry.value, @"==========",
                               configEntry2.key, @"==", configEntry2.value];
        
        [HVUIAlert showInformationalMessage:output];
        
    }] autorelease] start];
}

@end
