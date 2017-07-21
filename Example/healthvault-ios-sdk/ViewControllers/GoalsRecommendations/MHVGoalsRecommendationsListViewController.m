//
// MHVGoalsRecommendationsListViewController.m
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
#import "MHVGoalsRecommendationsListViewController.h"
#import "MHVGoalsRecommendationsDetailViewController.h"
#import "MHVStatusLabel.h"
#import "MHVTypeViewController.h"
#import "MHVMoreFeatures.h"
#import "MHVFeatureActions.h"
#import "MHVStatusLabel.h"

@interface MHVGoalsRecommendationsListViewController ()

@property (nonatomic, strong) NSArray<MHVGoalRecommendationInstance *> *recommendations;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

- (IBAction)addRecommendation:(id)sender;

@end

@implementation MHVGoalsRecommendationsListViewController

- (id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recommendations = [[NSArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Goal Recommendations";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadRecommendations];
}

- (IBAction)addRecommendation:(id)sender
{
    [self.statusLabel showBusy];
    
    MHVGoalRecurrenceMetrics *metrics = [[MHVGoalRecurrenceMetrics alloc] init];
    metrics.occurrenceCount = @(1);
    metrics.windowType = MHVGoalRecurrenceMetricsWindowTypeEnum.MHVDaily;
    
    MHVGoalRange *range = [[MHVGoalRange alloc] init];
    range.maximum = @(120);
    range.minimum = @(70);
    range.name = @"range";
    range.units = MHVGoalRangeUnitsEnum.MHVKilograms;
    
    
    MHVGoal *goal = [[MHVGoal alloc] init];
    goal.name = @"New goal recommendation";
    goal.goalType = MHVGoalGoalTypeEnum.MHVWeight;
    goal.startDate = [NSDate date];
    
    goal.recurrenceMetrics = metrics;
    goal.range = range;
    goal.identifier = nil;
    goal.endDate = nil;
    
    MHVGoalRecommendation *recommendation = [[MHVGoalRecommendation alloc] init];
    recommendation.expirationDate = [NSDate dateWithTimeInterval:60*60*24*14 sinceDate:[NSDate date]];
    recommendation.associatedGoal = goal;
    
    [self.connection.remoteMonitoringClient goalRecommendationsCreateWithGoalRecommendation:recommendation completion:^(MHVGoalRecommendationInstance * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 [self loadRecommendations];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

- (void)loadRecommendations
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient goalRecommendationsGetWithGoalTypes:nil goalWindowTypes:nil completion:^(MHVGoalRecommendationsResponse * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 self.recommendations = output.goalRecommendations;
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
    return [self.recommendations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    cell.textLabel.text = self.recommendations[indexPath.row].associatedGoal.name;
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
    NSString *recommendationId = self.recommendations[indexPath.row].identifier;
    
    MHVGoalsRecommendationsDetailViewController *typeView = [[MHVGoalsRecommendationsDetailViewController alloc] initWithGoalRecommendationId:recommendationId];
    
    if (!typeView || !recommendationId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVGoalsRecommendationsDetailViewController view for recommendation."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
}

@end
