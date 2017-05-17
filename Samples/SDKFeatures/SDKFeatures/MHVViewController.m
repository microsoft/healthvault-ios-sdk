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

#import "MHVLib.h"
#import "MHVViewController.h"
#import "MHVTypeListViewController.h"

#import "MHVConfiguration.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVConnectionFactoryProtocol.h"
#import "MHVConnectionFactory.h"

@implementation MHVViewController

-(void)viewDidLoad
{
    self.navigationItem.title = nil;
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!m_starting && ![MHVClient current].isProvisioned)
    {
        [self startApp];
    }
}

-(void)startApp
{
    m_starting = TRUE;
    //
    // Startup the HealthVault Client
    // This will automatically ensure that application instance is correctly provisioned to access the user's HealthVault record
    // Look at ClientSettings.xml
    //
//    [[MHVClient current] startWithParentController:self andStartedCallback:^(id sender)
//     {
//         m_starting = FALSE;
//         if ([MHVClient current].provisionStatus == MHVAppProvisionSuccess)
//         {
//             [self startupSuccess];
//         }
//         else
//         {
//             [self startupFailed];
//         }
//     }];
    
    MHVConfiguration *config = [MHVConfiguration new];
    config.masterApplicationId = [[NSUUID alloc] initWithUUIDString:@"cf0cb893-d411-495c-b66f-9d72b4fd2b97"];
    config.defaultHealthVaultUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform"];
    config.defaultShellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [connection authenticateWithViewController:self
                                    completion:^(NSError * _Nullable error)
    {
        if (error)
        {
            [self startupFailed];
        }
    }];
    
}

-(void)startupSuccess
{
    [self showTypeList];
}

-(void)startupFailed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[MHVClient current].settings.appName
                                                                             message:NSLocalizedString(@"Provisioning not completed. Retry?", @"Message for retrying provisioning")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"No button") style:UIAlertActionStyleCancel handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Yes button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     [self startApp];
                                 }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showTypeList
{
    //
    // Navigate to the type list
    //
    MHVTypeListViewController* typeListController = [[MHVTypeListViewController alloc] init];
    [self.navigationController pushViewController:typeListController animated:TRUE];
}

@end
