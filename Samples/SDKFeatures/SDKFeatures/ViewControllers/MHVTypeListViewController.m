//
// MHVTypeListViewController.m
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

#import "MHVTypeListViewController.h"
#import "MHVDietaryIntakeFactory.h"
#import "MHVEmotionalStateFactory.h"
#import "MHVExerciseFactory.h"
#import "MHVSleepJournalAMFactory.h"
#import "MHVMedicationUsageFactory.h"
#import "MHVBloodGlucoseFactory.h"
#import "MHVBloodPressureFactory.h"
#import "MHVCholesterolFactory.h"
#import "MHVWeightFactory.h"
#import "MHVUIAlert.h"
#import "MHVFeaturesConfiguration.h"

#import "MHVGoalsListViewController.h"
#import "MHVGoal.h"
#import "MHVActionPlansListViewController.h"
#import "MHVActionPlan.h"

@interface MHVTypeListViewController ()

@property (nonatomic, strong) NSDictionary *classesForTypes;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;

@end

@implementation MHVTypeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = [self personName];

    self.classesForTypes = [MHVTypeListViewController classesForTypesToDemo];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self downloadPersonImage];

    [self addStandardFeatures];
}

- (NSString *)personName
{
#if SHOULD_USE_LEGACY
    return [self personNameLegacy];
#else
    return [self personNameNew];
#endif
}

- (NSString *)personNameLegacy
{
    return [MHVClient current].currentRecord.name;
}

- (NSString *)personNameNew
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    NSUInteger index = [connection.personInfo.records indexOfRecordID:connection.personInfo.selectedRecordID];
    if (index != NSNotFound)
    {
        return connection.personInfo.records[index].displayName;
    }
    else
    {
        return connection.personInfo.name;
    }
}

- (void)downloadPersonImage
{
#if SHOULD_USE_LEGACY
    [self downloadPersonImageLegacy];
#else
    [self downloadPersonImageNew];
#endif
}

- (void)downloadPersonImageLegacy
{
    [[MHVClient current].currentRecord downloadPersonalImageWithCallback:^(MHVTask *task)
     {
         @try
         {
             [task checkSuccess];
             
             if (task.result)
             {
                 UIImage *personImage = [UIImage imageWithData:task.result];
                 
                 if (personImage)
                 {
                     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                     imageView.image = personImage;
                     imageView.contentMode = UIViewContentModeScaleAspectFit;
                     
                     self.navigationItem.titleView = imageView;
                 }
             }
         }
         @catch (NSException *exception)
         {
         }
     }];
}

- (void)downloadPersonImageNew
{
    MHVThingQuery *query = [[MHVThingQuery alloc] initWithTypeID:MHVPersonalImage.typeID];    
    query.view.sections = MHVThingSection_Blobs;

    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.thingClient getThingsWithQuery:query
                                      recordId:connection.personInfo.selectedRecordID
                                    completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
    {
        NSLog(@"Blobs In Progress... Thing Count: %li", things.count);
    }];
}

// -------------------------------------
//
// UITableViewDataSource & Delegate
//
// -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.classesForTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    NSArray *keys = [self.classesForTypes allKeys];

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
    NSArray *keys = [self.classesForTypes allKeys];
    Class selectedCls = NSClassFromString(keys[indexPath.row]);
    
    Class controllerClass = [self.classesForTypes objectForKey:keys[indexPath.row]];

    id typeView = [[controllerClass alloc] initWithTypeClass:selectedCls useMetric:FALSE];

    if (!typeView)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVTypeViewController"];
        return;
    }

    [self.navigationController pushViewController:typeView animated:TRUE];

    return;
}

// -------------------------------------
//
// UI Handlers
//
// -------------------------------------

- (IBAction)moreFeatures:(id)sender
{
    [self.actions showFrom:self.moreButton];
}

// -------------------------------------
//
// Methods
//
// -------------------------------------

+ (NSDictionary *)classesForTypesToDemo
{
    NSMutableDictionary *typeDictionary = [[NSMutableDictionary alloc] init];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVBloodGlucose class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVBloodPressure class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVCondition class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVCholesterol class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVDietaryIntake class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVDailyMedicationUsage class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVImmunization class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVEmotionalState class])];
    
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVExercise class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVMedication class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVProcedure class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVSleepJournalAM class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVWeight class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVFile class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVEmotionalState class])];
    [typeDictionary setObject:[MHVTypeViewController class] forKey:NSStringFromClass([MHVHeartRate class])];
    
    [typeDictionary setObject:[MHVGoalsListViewController class] forKey:NSStringFromClass([MHVGoal class])];
    [typeDictionary setObject:[MHVActionPlansListViewController class] forKey:NSStringFromClass([MHVActionPlan class])];

    /*
    [typeList sortUsingComparator:^NSComparisonResult (id obj1, id obj2)
    {
        MHVThingDataTyped *t1 = (MHVThingDataTyped *)obj1;
        MHVThingDataTyped *t2 = (MHVThingDataTyped *)obj2;
        return [[[t1 class] XRootElement] compare:[[t2 class] XRootElement]];
    }];
    */
    
    return typeDictionary;
}

- (Class)getSelectedClass
{
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;

    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [MHVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }

    NSArray *keys = [self.classesForTypes allKeys];
    return NSClassFromString(keys[selectedRow.row]);}

- (BOOL)addStandardFeatures
{
    self.features = [[MHVMoreFeatures alloc] init];
    MHVCHECK_NOTNULL(self.features);
    self.features.listController = self;

    __weak __typeof__(self.features)weakFeatures = self.features;

    self.actions = [[MHVFeatureActions alloc] init];
    MHVCHECK_NOTNULL(self.actions);

    [self.actions addFeature:@"Disconnect app" andAction:^
    {
        [weakFeatures disconnectApp];
    }];

    [self.actions addFeature:@"GetServiceDefintion" andAction:^
    {
        [weakFeatures getServiceDefinition];
    }];
    
    [self.actions addFeature:@"Authorize records" andAction:^
    {
         [weakFeatures authorizeAdditionalRecords];
    }];

    return TRUE;
}

@end
