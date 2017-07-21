//
// MHVActionPlanTaskDetailViewController.m
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
#import "MHVActionPlanTaskDetailViewController.h"

@interface MHVActionPlanTaskDetailViewController ()

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) MHVActionPlanTaskInstance *task;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameValue;
@property (strong, nonatomic) IBOutlet UITextField *statusValue;
@property (strong, nonatomic) IBOutlet UITextView *shortDescriptionValue;
@property (strong, nonatomic) IBOutlet UITextField *startDate;

- (IBAction)updateTask:(id)sender;
- (IBAction)deleteTask:(id)sender;
- (IBAction)trackTask:(id)sender;

@end

@implementation MHVActionPlanTaskDetailViewController

- (instancetype)initWithTaskId:(NSString *)taskId
{
    self = [super init];
    
    if (self)
    {
        _taskId = taskId;
        
        MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
        _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.task = [[MHVActionPlanTaskInstance alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Task Details";
    
    [self loadTask];
}

- (void)deleteTask:(id)sender
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient actionPlanTasksDeleteWithActionPlanTaskId:self.taskId completion:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.statusLabel clearStatus];
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

- (void)loadTask
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient actionPlanTasksGetByIdWithActionPlanTaskId:self.taskId completion:^(MHVActionPlanTaskInstance * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 self.task = output;
                 self.nameValue.text = output.name;
                 self.statusValue.text = output.status.stringValue;
                 self.shortDescriptionValue.text = output.shortDescription;
                 self.startDate.text = output.startDate.description;
                 
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

- (void)updateTask:(id)sender
{
    [self.statusLabel showBusy];
    
    self.task.name = self.nameValue.text;
    self.task.status = [[MHVActionPlanTaskInstanceStatusEnum alloc] initWithString:self.statusValue.text];
    self.task.shortDescription = self.shortDescriptionValue.text;
    
    [self.connection.remoteMonitoringClient actionPlanTasksUpdateWithActionPlanTask:self.task completion:^(MHVActionPlanTaskInstance * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.statusLabel showStatus:@"Success"];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

// uses the TaskTrackingApi
- (void)trackTask:(id)sender
{
    [self.statusLabel showBusy];
    
    MHVZonedDateTime* dt = [[MHVZonedDateTime alloc] init];
    
    MHVTaskTrackingOccurrence* occurrence = [[MHVTaskTrackingOccurrence alloc] init];
    occurrence.taskId = self.taskId;
    occurrence.trackingDateTime = dt;
    
    [self.connection.remoteMonitoringClient taskTrackingPostWithTaskTrackingOccurrence:occurrence completion:^(NSObject * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error) {
                 [self.statusLabel showStatus:@"Success"];
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
