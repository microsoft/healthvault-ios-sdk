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

#import "MHVViewController.h"
#import "MHVTypeListViewController.h"
#import "healthvault_ios_sdk_Example-Swift.h"

@interface MHVViewController ()

@property (nonatomic, assign) BOOL starting;

@end

@implementation MHVViewController

- (void)viewDidLoad
{
    self.navigationItem.title = nil;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.starting)
    {
        [self startApp];
    }
}

- (void)startApp
{
    self.starting = YES;
    
    // Authentication and setup flow.
    // Consumers will create a configuration and override the default properties
    // Using the connection factory, create a connection.
    // Then authenticate the connection.
    // The connection is stored in the connection factory and can be used to get clients to make requests.
    
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    // Must setup cache configuration with the typeIds for the Thing types to be cached
    connection.cacheConfiguration.cacheTypeIds = @[[MHVBloodGlucose typeID],
                                                   [MHVBloodPressure typeID],
                                                   [MHVCondition typeID],
                                                   [MHVCholesterol typeID],
                                                   [MHVPersonalContactInfo typeID],
                                                   [MHVDietaryIntake typeID],
                                                   [MHVDailyMedicationUsage typeID],
                                                   [MHVImmunization typeID],
                                                   [MHVEmotionalState typeID],
                                                   [MHVExercise typeID],
                                                   [MHVMedication typeID],
                                                   [MHVProcedure typeID],
                                                   [MHVSleepJournalAM typeID],
                                                   [MHVWeight typeID],
                                                   [MHVFile typeID],
                                                   [MHVPersonalImage typeID],
                                                   [MHVHeartRate typeID]];
        
    [connection authenticateWithViewController:self
                                    completion:^(NSError *_Nullable error)
     {
         self.starting = NO;
         
         if (error)
         {
             [self startupFailed];
         }
         else
         {
             if (connection.personInfo.records.count == 1)
             {
                 [self showTypeList];
             }
             else
             {
                 [self showRecordSelector];
             }
         }
     }];
}

- (void)startupFailed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"]
                                                                             message:NSLocalizedString(@"Provisioning not completed. Retry?", @"Message for retrying provisioning")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"No button") style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Yes button") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action)
                                {
                                    [self startApp];
                                }]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self presentViewController:alertController animated:YES completion:nil];
     }];
}

- (void)showTypeList
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         //
         // Navigate to the type list
         //
         MHVTypeListViewController *typeListController = [[MHVTypeListViewController alloc] init];
         
         [self.navigationController pushViewController:typeListController animated:TRUE];
     }];
}

- (void)showRecordSelector
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         //
         // Navigate to the record selector list
         //
         MHVRecordListViewController *recordListController = [[MHVRecordListViewController alloc] init];
         
         [self.navigationController pushViewController:recordListController animated:TRUE];
     }];
}

@end
