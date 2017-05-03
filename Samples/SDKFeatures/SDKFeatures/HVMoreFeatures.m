//
//  HVMoreFeatures.m
//  SDKFeatures
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

#import "HVMoreFeatures.h"
#import "HVTypeListViewController.h"

@implementation HVMoreFeatures

@synthesize controller = m_controller;  // Weak ref

-(void)disconnectApp
{
    [HVUIAlert showYesNoWithMessage:@"Are you sure you want to disconnect this application from HealthVault?\r\nIf you click Yes, you will need to re-authorize the next time you run it." callback:^(id sender) {
        
        HVUIAlert* alert = (HVUIAlert *) sender;
        if (alert.result != HVUIAlertOK)
        {
            return;
        }
        
        [m_controller.statusLabel showBusy];
        //
        // REMOVE RECORD AUTHORIZATION.
        //
        [[HVClient current].user removeAuthForRecord:[HVClient current].currentRecord withCallback:^(HVTask *task) {
            
            [[HVClient current] resetProvisioning];  // Removes local state
            
            [m_controller.navigationController popViewControllerAnimated:TRUE];
        }];
    }];
}

-(void)getServiceDefinition
{
    [m_controller.statusLabel showBusy];
    //
    // LAUNCH the GetServiceDefinition task
    //
    [[[HVGetServiceDefinitionTask alloc] initWithCallback:^(HVTask *task) {
        //
        // Verify success. This will throw if there was a failure
        // You can also detect failure by checking task.hasError
        //
        [task checkSuccess];  
        
        HVServiceDefinition* serviceDef = ((HVGetServiceDefinitionTask *) task).serviceDef;
        // 
        // Show some sample information to the user
        //
        HVConfigurationEntry* configEntry = [serviceDef.platform.config objectAtIndex:0];
        HVConfigurationEntry* configEntry2 = [serviceDef.platform.config objectAtIndex:1];
        NSMutableString* output = [[NSMutableString alloc] init];
        
        [output appendLines:17, @"Some data from ServiceDefinition",
                               @"[PlatformUrl]", serviceDef.platform.url,
                               @"[PlatformVersion]", serviceDef.platform.version,
                               @"[ShellUrl]", serviceDef.shell.url,
                               @"[ShellRedirect]", serviceDef.shell.redirectUrl,
                               @"[Example Config Entries]",
                               configEntry.key, @"==", configEntry.value, @"==========",
                               configEntry2.key, @"==", configEntry2.value];
        
        [HVUIAlert showInformationalMessage:output];
        
        [m_controller.statusLabel clearStatus];
        
    }] start];  // NOTE: Make sure you always call start
}

@end
