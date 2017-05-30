//
// MHVActionPlansListViewController.m
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
#import "MHVActionPlansListViewController.h"
#import "MHVActionPlanDetailViewController.h"
#import "MHVConnection.h"
#import "MHVActionPlansApi.h"

@interface MHVActionPlansListViewController ()

@property (nonatomic, strong) NSMutableDictionary *actionPlans;
@property (nonatomic, strong) MHVConnection *connection;

@end

@implementation MHVActionPlansListViewController

- (id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _actionPlans = [[NSMutableDictionary alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Action Plans List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadActionPlans];
}

- (void)loadActionPlans
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [_connection.remoteMonitoringClient getActionPlansWithMaxPageSize:[NSNumber numberWithInt:10] completion:^(MHVActionPlansResponseActionPlanInstance_ * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
            if (!error)
            {
                NSMutableDictionary *planDictionary = [[NSMutableDictionary alloc] init];
                
                for (MHVActionPlanInstance *instance in output.plans) {
                    planDictionary[instance.name] = instance._id;
                }
                
                _actionPlans = planDictionary;
                [self.tableView reloadData];
                
                [self.statusLabel clearStatus];
            }
         }];
    }];
}

- (IBAction)addActionPlan:(id)sender
{
    // Create a new action plan, we don't allow input here because plans are fairly complicated. Just create one.
    
    MHVObjective *objective = [[MHVObjective alloc] init];
    objective._description = @"A sample objective which encourages you to get more activity.";
    objective.name = @"Start doing some fun activities.";
    objective.outcomeName = @"Exercise hours / week";
    objective.outcomeType = @"ExerciseHoursPerWeek";
    objective.state = @"Active";
    objective._id = [[NSUUID UUID] UUIDString];
    
    MHVActionPlanTrackingPolicy *policy = [[MHVActionPlanTrackingPolicy alloc] init];
    policy.isAutoTrackable = [NSNumber numberWithBool:NO];
    
    MHVActionPlanFrequencyTaskCompletionMetrics *metrics = [[MHVActionPlanFrequencyTaskCompletionMetrics alloc] init];
    metrics.reminderState = @"Off";
    metrics.scheduledDays = @[@"Monday", @"Wednesday", @"Friday"];
    metrics.occurrenceCount = [NSNumber numberWithInt:1];
    metrics.windowType = @"Daily";
    
    MHVActionPlanTask *frequencyTask = [[MHVActionPlanTask alloc] init];
    frequencyTask.name = @"Do a fun activity.";
    frequencyTask.shortDescription = @"Do an activity to get some exercise.";
    frequencyTask.longDescription = @"Go for a run, hike a mountain, ride your bike around town, or something else to get moving.";
    frequencyTask.imageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1rXx2?ver=d68e";
    frequencyTask.thumbnailImageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1s2KS?ver=0ad8";
    frequencyTask.taskType = @"Other";
    frequencyTask.signupName = @"Do a fun activity.";
    frequencyTask.associatedObjectiveIds = [[NSArray alloc] initWithObjects:objective._id, nil];
    frequencyTask.trackingPolicy = policy;
    frequencyTask.completionType = @"Frequency";
    frequencyTask.frequencyTaskCompletionMetrics = metrics;
    
    MHVActionPlan *newPlan = [[MHVActionPlan alloc] init];
    NSNumber *rand = [NSNumber numberWithUnsignedInteger:arc4random_uniform(100)];
    newPlan.name = [NSString stringWithFormat:@"My new plan (%@)", rand];
    newPlan._description = @"A sample activity plan";
    newPlan.imageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE10omP?ver=59cf";
    newPlan.thumbnailImageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE10omP?ver=59cf";
    newPlan.category = @"Activity";
    newPlan.objectives = [[NSArray<MHVObjective> alloc] initWithObjects:objective, nil];
    newPlan.associatedTasks = [[NSArray<MHVActionPlanTask> alloc] initWithObjects:frequencyTask, nil];
    
    [_connection.remoteMonitoringClient createActionPlanWithActionPlan:newPlan completion:^(MHVSystemObject * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 [self loadActionPlans];
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
    return [_actionPlans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    NSArray *keys = [self.actionPlans allKeys];
    
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
    NSArray *values = [self.actionPlans allValues];
    NSString *planId = values[indexPath.row];
    
    id typeView = [[MHVActionPlanDetailViewController alloc] initWithPlanId:planId];
    
    if (!typeView || !planId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVActionPlanDetailViewController view for plan."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
}

@end
