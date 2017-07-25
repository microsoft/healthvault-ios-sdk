//
// MHVGoalAddViewController.m
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
#import "MHVGoalAddViewController.h"
#import "MHVGoalsListViewController.h"

@interface MHVGoalAddViewController ()

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITextField *nameValue;
@property (strong, nonatomic) IBOutlet UITextField *typeValue;

@property (strong, nonatomic) IBOutlet UITextField *unitsValue;
@property (strong, nonatomic) IBOutlet UITextField *maxValue;
@property (strong, nonatomic) IBOutlet UITextField *minValue;

@property (strong, nonatomic) IBOutlet UITextField *startDate;

- (IBAction)saveGoal:(id)sender;

@end;

@implementation MHVGoalAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveGoal:)];
}

- (IBAction)saveGoal:(id)sender
{
    MHVGoalRecurrenceMetrics *metrics = [[MHVGoalRecurrenceMetrics alloc] init];
    metrics.occurrenceCount = [NSNumber numberWithInt:1];
    metrics.windowType = MHVGoalRecurrenceMetricsWindowTypeEnum.MHVDaily;
    
    MHVGoalRange *range = [[MHVGoalRange alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    range.maximum = [formatter numberFromString:self.maxValue.text];
    range.minimum = [formatter numberFromString:self.minValue.text];
    range.name = @"range";
    range.units = [[MHVGoalRangeUnitsEnum alloc] initWithString:self.unitsValue.text];
    
    
    MHVGoal *goal = [[MHVGoal alloc] init];
    goal.name = self.nameValue.text;
    goal.goalType = [[MHVGoalGoalTypeEnum alloc] initWithString:self.typeValue.text];
    goal.startDate = [[NSDate alloc] init];
    
    goal.recurrenceMetrics = metrics;
    goal.range = range;
    goal.identifier = nil;
    goal.endDate = nil;
    
    MHVGoalsWrapper *wrapper = [[MHVGoalsWrapper alloc] init];
    wrapper.goals = [[NSArray<MHVGoal> alloc] initWithObjects:goal, nil];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [self.connection.remoteMonitoringClient goalsCreateWithGoalsWrapper:wrapper completion:^(MHVGoalsResponse * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           if (!error)
           {
               [self.navigationController popViewControllerAnimated:YES];
           }
           else
           {
               [MHVUIAlert showInformationalMessage:error.description];
           }
        }];
    }];
}

@end
