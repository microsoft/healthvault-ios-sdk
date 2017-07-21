//
// MHVActionPlanDetailViewController.m
// SDKFeatures
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

#import <Foundation/Foundation.h>
#import "MHVActionPlanDetailViewController.h"

@interface MHVActionPlanDetailViewController ()

@property (nonatomic, strong) NSString *planId;
@property (nonatomic, strong) MHVActionPlanInstance *plan;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameValue;
@property (strong, nonatomic) IBOutlet UITextField *categoryValue;
@property (strong, nonatomic) IBOutlet UITextField *statusValue;

@property (strong, nonatomic) IBOutlet UITextView *descriptionValue;

- (IBAction)updatePlan:(id)sender;
- (IBAction)deletePlan:(id)sender;

@end;


@implementation MHVActionPlanDetailViewController

- (instancetype)initWithPlanId:(NSString *)planId
{
    self = [super init];
    _planId = planId;
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    return self;
}

- (IBAction)updatePlan:(id)sender
{
    self.plan.name = self.nameValue.text;
    self.plan.descriptionText = self.descriptionValue.text;
    self.plan.category = [[MHVActionPlanInstanceCategoryEnum alloc] initWithString:self.categoryValue.text];
    self.plan.status = [[MHVActionPlanInstanceStatusEnum alloc] initWithString:self.statusValue.text];
    
    [self.connection.remoteMonitoringClient actionPlansReplaceWithActionPlan:self.plan completion:^(MHVActionPlanInstance * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

- (IBAction)deletePlan:(id)sender
{
    [self.connection.remoteMonitoringClient actionPlansDeleteWithActionPlanId:self.planId completion:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.plan = [[MHVActionPlanInstance alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Plan Details";
    
    [self loadPlan];
}

- (void) loadPlan
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient actionPlansGetByIdWithActionPlanId:self.planId completion:^(MHVActionPlanInstance * _Nullable output, NSError * _Nullable error) {
        [[ NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            if (!error) {
                _plan = output;
                
                self.nameValue.text = output.name;
                self.descriptionValue.text = output.descriptionText;
                self.categoryValue.text = output.category.stringValue;
                self.statusValue.text = output.status.stringValue;
                
                [self.statusLabel clearStatus];
            }
            else
            {
                [MHVUIAlert showInformationalMessage:error.description];
                [self.statusLabel showStatus:@"Failed"];
            }
        }];
    }];
}

@end;
