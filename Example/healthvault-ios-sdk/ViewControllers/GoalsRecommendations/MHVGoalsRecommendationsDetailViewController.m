//
// MHVGoalsRecommendationsDetailViewController.m
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
#import "MHVGoalsRecommendationsDetailViewController.h"
#import "MHVTypeViewController.h"

#import <Foundation/Foundation.h>

@interface MHVGoalsRecommendationsDetailViewController ()

@property (nonatomic, strong) NSString *recommendationId;
@property (nonatomic, strong) MHVGoalRecommendationInstance *recommendation;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameValue;
@property (strong, nonatomic) IBOutlet UITextField *typeValue;

@property (strong, nonatomic) IBOutlet UITextField *unitsValue;
@property (strong, nonatomic) IBOutlet UITextField *maxValue;
@property (strong, nonatomic) IBOutlet UITextField *minValue;

@property (strong, nonatomic) IBOutlet UITextField *startDate;
@property (strong, nonatomic) IBOutlet UITextField *expirationDate;
@property (strong, nonatomic) IBOutlet UITextField *acknowledgedValue;

- (IBAction)acknowledgeRecommendation:(id)sender;
- (IBAction)deleteRecommendation:(id)sender;

@end

@implementation MHVGoalsRecommendationsDetailViewController

- (instancetype)initWithGoalRecommendationId:(NSString *)recommendationId
{
    self = [super init];
    self.recommendationId = recommendationId;
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recommendation = [[MHVGoalRecommendationInstance alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Recommendation Details";
    
    [self loadGoalRecommendation];
}

- (void) loadGoalRecommendation
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient goalRecommendationsGetByIdWithGoalRecommendationId:self.recommendationId completion:^(MHVGoalRecommendationInstance * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 self.nameValue.text = output.associatedGoal.name;
                 self.typeValue.text = output.associatedGoal.goalType.stringValue;
                 self.startDate.text = output.associatedGoal.startDate.description;
                 
                 self.expirationDate.text = output.expirationDate.description;
                 self.acknowledgedValue.text = output.acknowledged.stringValue;
                 
                 if (output.associatedGoal.range)
                 {
                     self.unitsValue.text = output.associatedGoal.range.units.stringValue;
                     self.maxValue.text = [output.associatedGoal.range.maximum stringValue];
                     self.minValue.text = [output.associatedGoal.range.minimum stringValue];
                 }
                 
                 self.recommendation = output;
                 
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

- (IBAction)acknowledgeRecommendation:(id)sender
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient goalRecommendationsAcknowledgeWithGoalRecommendationId:self.recommendationId completion:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 [self loadGoalRecommendation];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

- (IBAction)deleteRecommendation:(id)sender
{
    [self.statusLabel showBusy];
    
    [self.connection.remoteMonitoringClient goalRecommendationsDeleteWithGoalRecommendationId:self.recommendationId completion:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
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

@end
