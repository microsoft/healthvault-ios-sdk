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
#import "MHVGoalAddViewController.h"
#import "MHVGoalsListViewController.h"
#import "MHVGoalDetailViewController.h"

@interface MHVGoalsListViewController ()

@property (nonatomic, strong) NSArray<MHVGoal *> *goals;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

- (IBAction)addGoal:(id)sender;

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
    _goals = [[NSArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Goals List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadGoals];
}

- (void)loadGoals
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [self.connection.remoteMonitoringClient goalsGetActiveWithTypes:nil windowTypes:nil completion:^(MHVGoalsResponse * _Nullable output, NSError * _Nullable error) {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
            if (!error)
            {
                self.goals = output.goals;
                [self.tableView reloadData];
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
    return [self.goals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    cell.textLabel.text = self.goals[indexPath.row].name;
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
    NSString *goalId = self.goals[indexPath.row].identifier;
    
    MHVGoalDetailViewController *typeView = [[MHVGoalDetailViewController alloc] initWithGoalId:goalId];
    
    if (!typeView || !goalId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVTypeViewController view for goal."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
}

@end
