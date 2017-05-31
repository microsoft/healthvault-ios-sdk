//
// MHVGoalDetailViewController.m
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
#import "MHVGoalDetailViewController.h"
#import "MHVGoalsApi.h"
#import "MHVConfiguration.h"
#import "MHVConnection.h"
#import "MHVGoal.h"

@interface MHVGoalDetailViewController ()

@property (nonatomic, strong) NSString *goalId;
@property (nonatomic, strong) MHVGoal *goal;
@property (nonatomic, strong) MHVConnection *connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameValue;
@property (strong, nonatomic) IBOutlet UITextField *typeValue;

@property (strong, nonatomic) IBOutlet UITextField *unitsValue;
@property (strong, nonatomic) IBOutlet UITextField *maxValue;
@property (strong, nonatomic) IBOutlet UITextField *minValue;

@property (strong, nonatomic) IBOutlet UITextField *startDate;

- (IBAction)updateGoal:(id)sender;
- (IBAction)deleteGoal:(id)sender;

@end;

@implementation MHVGoalDetailViewController

- (instancetype)initWithGoalId:(NSString *)goalId
{
    self = [super init];
    _goalId = goalId;
    return self;
}

- (IBAction)deleteGoal:(id)sender
{
    [self.connection.remoteMonitoringClient deleteGoalWithGoalId:_goalId completion:^(MHVSystemObject * _Nullable output, NSError * _Nullable error) {
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

- (IBAction)updateGoal:(id)sender
{
    self.goal.name = self.nameValue.text;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.goal.range.maximum = [formatter numberFromString:self.maxValue.text];
    self.goal.range.minimum = [formatter numberFromString:self.minValue.text];
    self.goal.range.name = @"range";
    self.goal.range.units = self.unitsValue.text;
    
    [self.connection.remoteMonitoringClient putGoalWithGoal:_goal completion:^(MHVGoal * _Nullable output, NSError * _Nullable error) {
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
    self.goal = [[MHVGoal alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Goal Details";

    [self loadGoal];
}

- (void) loadGoal
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [self.connection.remoteMonitoringClient getGoalByIdWithGoalId:_goalId completion:^(MHVGoal *response, NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
              if (!error)
              {
                  self.nameValue.text = response.name;
                  self.typeValue.text = response.goalType;
                  self.startDate.text = response.startDate.toString;
                  
                  if (response.range)
                  {
                      self.unitsValue.text = response.range.units;
                      self.maxValue.text = [response.range.maximum stringValue];
                      self.minValue.text = [response.range.minimum stringValue];
                  }
                  
                  self.goal = response;
                  
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

@end
