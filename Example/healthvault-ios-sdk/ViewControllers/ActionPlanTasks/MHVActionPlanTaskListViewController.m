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
#import "MHVActionPlanTaskDetailViewController.h"

@interface MHVActionPlanTaskListViewController ()

@property (nonatomic, strong) NSArray<MHVActionPlanTaskInstance *> *taskList;
@property (nonatomic, strong) MHVActionPlanInstance *plan;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

- (IBAction)addTask:(id)sender;

@end

@implementation MHVActionPlanTaskListViewController

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    return self;
}

- (IBAction)addTask:(id)sender
{
    if (self.plan == nil)
    {
        [MHVUIAlert showInformationalMessage:@"You must create an action plan before adding a task."];
        [self.statusLabel showStatus:@"Failed"];
        return;
    }

    [self.statusLabel showBusy];
    NSNumber *rand = @(arc4random_uniform(100));

    // Create a random task since the UI for these can be complicated.

    MHVActionPlanTrackingPolicy *policy = [[MHVActionPlanTrackingPolicy alloc] init];
    policy.isAutoTrackable = @(NO);

    MHVActionPlanFrequencyTaskCompletionMetrics *metrics = [[MHVActionPlanFrequencyTaskCompletionMetrics alloc] init];
    metrics.occurrenceCount = @(1);
    metrics.windowType = MHVActionPlanFrequencyTaskCompletionMetricsWindowTypeEnum.MHVDaily;

    MHVActionPlanTask *frequencyTask = [[MHVActionPlanTask alloc] init];
    NSString *taskName =[NSString stringWithFormat:@"My new task #%@", rand];
    frequencyTask.name = taskName;
    frequencyTask.shortDescription = @"Do an activity to get some exercise.";
    frequencyTask.longDescription = @"Go for a run, hike a mountain, ride your bike around town, or something else to get moving.";
    frequencyTask.imageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1rXx2?ver=d68e";
    frequencyTask.thumbnailImageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1s2KS?ver=0ad8";
    frequencyTask.taskType = MHVActionPlanTaskTaskTypeEnum.MHVOther;
    frequencyTask.signupName = taskName;
    frequencyTask.trackingPolicy = policy;
    frequencyTask.completionType = MHVActionPlanTaskCompletionTypeEnum.MHVFrequency;
    frequencyTask.frequencyTaskCompletionMetrics = metrics;
    frequencyTask.associatedPlanId = self.plan.identifier;
    frequencyTask.associatedObjectiveIds = @[[self.plan.objectives.firstObject identifier]];
    
    [self.connection.remoteMonitoringClient actionPlanTasksCreateWithActionPlanTask:frequencyTask completion:^(MHVActionPlanTaskInstance* _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 [self loadActionPlanTasks];
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
    self.taskList = [[NSArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Action Plan Tasks";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadActionPlanTasks];
    [self loadActionPlan];
}

- (void)loadActionPlanTasks
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient actionPlanTasksGetWithActionPlanTaskStatus:MHVActionPlanTaskInstanceStatusEnum.MHVInProgress completion:^(MHVActionPlanTasksResponseActionPlanTaskInstance_ * _Nullable output, NSError * _Nullable error) {
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

- (void)loadActionPlan
{
    [self.connection.remoteMonitoringClient actionPlansGetWithCompletion:^(MHVActionPlansResponseActionPlanInstance_ * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 if (output.plans && output.plans.count > 0)
                 {
                     self.plan = output.plans[0];
                 }
                 else
                 {
                     self.plan = nil;
                 }
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed to retrieve an action plan"];
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
    NSString *taskId = self.taskList[indexPath.row].identifier;
    
    
    MHVActionPlanTaskDetailViewController *typeView = [[MHVActionPlanTaskDetailViewController alloc] initWithTaskId:taskId];

    if (!typeView || !taskId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVActionPlanTaskDetailViewController view for task."];
        return;
    }

    [self.navigationController pushViewController:typeView animated:YES];
}

@end
