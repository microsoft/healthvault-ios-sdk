//
// MHVTimelineSnapshotViewController.m
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
#import "MHVTimelineSnapshotViewController.h"
#import "MHVStatusLabel.h"
#import "MHVTypeViewController.h"
#import "MHVMoreFeatures.h"
#import "MHVFeatureActions.h"
#import "MHVStatusLabel.h"

@interface MHVTimelineSnapshotViewController ()

@property (nonatomic, strong) MHVActionPlanTasksResponseTimelineTask_ *timeline;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet UITextField *numberOfTasksLabel;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@end

@implementation MHVTimelineSnapshotViewController

- (id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    
    if (self)
    {
        MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
        self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Timeline Snapshot";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTimeline];
}

- (void)loadTimeline
{
    [self.statusLabel showBusy];
    NSDate *now = [[NSDate alloc] init];
    NSDate *minusSixty = [now dateByAddingTimeInterval:-60*24*60*60];
    
    MHVLocalDate* startDate = [[MHVLocalDate alloc] initWithDate:minusSixty];
    
    MHVLocalDate* endDate = [[MHVLocalDate alloc] init];
    
    [self.connection.remoteMonitoringClient timelineGetWithTimeZone:startDate.timeZone startDate:startDate endDate:endDate planId:nil objectiveId:nil completion:^(MHVActionPlanTasksResponseTimelineTask_ * _Nullable output, NSError * _Nullable error)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {                 
                 self.timeline = output;
                 self.numberOfTasksLabel.text = [@(output.tasks.count) stringValue];
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
