//
// MHVGoalsListViewController.m
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
#import "MHVGoalsApi.h"
#import "MHVGoalAddViewController.h"
#import "MHVGoalsListViewController.h"
#import "MHVGoalDetailViewController.h"
#import "MHVFeaturesConfiguration.h"
#import "MHVConfiguration.h"
#import "MHVConnection.h"

@interface MHVGoalsListViewController ()

@property (nonatomic, strong) NSMutableDictionary *goals;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;
@property (nonatomic, strong) MHVConnection *connection;

@end

@implementation MHVGoalsListViewController

- (id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _goals = [[NSMutableDictionary alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Goals List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadGoals];
}

- (void)loadGoals
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [_connection.remoteMonitoringClient getActiveGoalsWithTypes:nil windowTypes:nil
                                                     completion:^(MHVGoalsResponse *response, NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
            if (!error)
            {
                NSMutableDictionary *goalDictionary = [[NSMutableDictionary alloc] init];
             
                for (MHVGoal *goal in response.goals) {
                    goalDictionary[goal.name] = goal._id;
                }
             
                _goals = goalDictionary;
             
                [self.tableView reloadData];
             
                [self.statusLabel clearStatus];
            }
          }];
     }];
}

- (IBAction)addGoal:(id)sender
{
    id view = [[MHVGoalAddViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

// -------------------------------------
//
// UITableViewDataSource & Delegate
//
// -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_goals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    NSArray *keys = [self.goals allKeys];
    
    NSString *typeName = keys[indexPath.row];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *values = [self.goals allValues];
    NSString *goalId = values[indexPath.row];
    
    id typeView = [[MHVGoalDetailViewController alloc] initWithGoalId:goalId];
    
    if (!typeView || !goalId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVTypeViewController view for goal."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
}

@end
