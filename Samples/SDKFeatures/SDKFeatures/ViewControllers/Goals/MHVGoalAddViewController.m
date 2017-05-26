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
#import "MHVGoalsApi.h"
#import "MHVConfiguration.h"
#import "MHVConnection.h"
#import "MHVGoal.h"

@interface MHVGoalAddViewController ()

@property (nonatomic, strong) MHVConnection *connection;

@end;

@implementation MHVGoalAddViewController

- (IBAction)saveGoal:(id)sender
{
    MHVGoalRecurrenceMetrics *metrics = [[MHVGoalRecurrenceMetrics alloc] init];
    metrics.occurrenceCount = [NSNumber numberWithInt:1];
    metrics.windowType = @"Daily";
    
    MHVGoalRange *range = [[MHVGoalRange alloc] init];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    range.maximum = [f numberFromString:self.maxValue.text];
    range.minimum = [f numberFromString:self.minValue.text];
    range.name = @"range";
    range.units = self.unitsValue.text;
    
    
    MHVGoal *goal = [[MHVGoal alloc] init];
    goal.name = self.nameValue.text;
    goal.goalType = self.typeValue.text;
    goal.startDate = [[NSDate alloc] init];
    
    goal.recurrenceMetrics = metrics;
    goal.range = range;
    goal._id = nil;
    goal.endDate = nil;
    
    MHVGoalsWrapper *wrapper = [[MHVGoalsWrapper alloc] init];
    wrapper.goals = [[NSArray<MHVGoal> alloc] initWithObjects:goal, nil];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [_connection.remoteMonitoringClient createGoalsWithGoalsWrapper:wrapper completion:^(MHVSystemObject * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           if (!error)
           {
               [self.navigationController popViewControllerAnimated:YES];
           }
           else
           {
               // show the error.
           }
        }];
    }];
}

@end
