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

@end;

@implementation MHVGoalDetailViewController

- (id)initWithGoalId:(NSString *)goalId
{
    self = [super init];
    _goalId = goalId;
    return self;
}

- (IBAction)deleteGoal:(id)sender
{
    [_connection.remoteMonitoringClient deleteGoalWithGoalId:_goalId completion:^(MHVSystemObject * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }];
    }];
}

- (IBAction)updateGoal:(id)sender
{
    _goal.name = self.nameValue.text;
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    _goal.range.maximum = [f numberFromString:self.maxValue.text];
    _goal.range.minimum = [f numberFromString:self.minValue.text];
    _goal.range.name = @"range";
    _goal.range.units = self.unitsValue.text;
    
    [_connection.remoteMonitoringClient putGoalWithGoal:_goal completion:^(MHVGoal * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _goal = [[MHVGoal alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Goal Details";

    [self loadGoal];
}

- (void) loadGoal
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [_connection.remoteMonitoringClient getGoalByIdWithGoalId:_goalId completion:^(MHVGoal *response, NSError *error)
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
                  
                  _goal = response;
                  
                  [self.statusLabel clearStatus];
              }
          }];
     }];
}

@end
