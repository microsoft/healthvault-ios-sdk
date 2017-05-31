//
// MHVActionPlanTaskViewController.m
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
#import "MHVActionPlanTaskListViewController.h"
#import "MHVActionPlanTasksApi.h"
#import "MHVConnection.h"


@interface MHVActionPlanTaskListViewController ()

@property (nonatomic, strong) NSArray<MHVActionPlanTaskInstance *> *taskList;
@property (nonatomic, strong) MHVConnection *connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@end

@implementation MHVActionPlanTaskListViewController

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.taskList = [[NSArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Action Plan Tasks";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadActionPlanTasks];
}

- (void)loadActionPlanTasks
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient actionPlanTasksGetActionPlanTasksWithActionPlanTaskStatus:@"InProgress" maxPageSize:nil completion:^(MHVActionPlanTasksResponseActionPlanTaskInstance_ * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 self.taskList = output.tasks;
                 
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

// -------------------------------------
//
// UITableViewDataSource & Delegate
//
// -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    cell.textLabel.text = self.taskList[indexPath.row].name;
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
    NSString *taskId = self.taskList[indexPath.row]._id;
    
    /*
    id typeView = [[MHVActionPlanDetailViewController alloc] initWithPlanId:planId];
    
    if (!typeView || !planId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVActionPlanDetailViewController view for plan."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
    */
}

@end
