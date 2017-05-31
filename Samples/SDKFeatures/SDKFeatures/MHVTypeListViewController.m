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

@interface MHVTypeListViewController ()

@property (nonatomic, strong) NSArray *classesForTypes;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;

@property (nonatomic, assign) BOOL hasLoadedPersonImage;

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

    [self addStandardFeatures];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Load image after view has appeared to avoid flickering if image set while view is animating
    if (!self.hasLoadedPersonImage)
    {
        self.hasLoadedPersonImage = YES;
        
        [self downloadPersonImage];
    }
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
    [self downloadPersonalImageLegacy];
#else
    [self downloadPersonalImageNew];
#endif
}

- (void)downloadPersonalImageLegacy
{
    [[MHVClient current].currentRecord downloadPersonalImageWithCallback:^(MHVTask *task)
     {
         @try
         {
             [task checkSuccess];
             
             if (task.result)
             {
                 UIImage *image = [UIImage imageWithData:task.result];
                 
                 if (image)
                 {
                     [self setTitleViewImage:image];
                 }
             }
         }
         @catch (NSException *exception)
         {
         }
     }];
}

- (void)downloadPersonalImageNew
{
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [connection.personClient getPersonalImageWithRecordId:connection.personInfo.selectedRecordID
                                               completion:^(UIImage * _Nullable image, NSError * _Nullable error)
     {
        if (image)
        {
            [self setTitleViewImage:image];
        }
    }];
}

- (void)setTitleViewImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *imageContainer = [[UIView alloc] initWithFrame:imageView.bounds];
    [imageContainer addSubview:imageView];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.navigationItem.titleView = imageContainer;
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

    NSString *typeName = [[self.classesForTypes objectAtIndex:indexPath.row] XRootElement];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class selectedCls = [self.classesForTypes objectAtIndex:indexPath.row];

    MHVTypeViewController *typeView = [[MHVTypeViewController alloc] initWithTypeClass:selectedCls useMetric:FALSE];

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

+ (NSArray *)classesForTypesToDemo
{
    NSMutableArray *typeList = [[NSMutableArray alloc] init];

    [typeList addObject:[MHVBloodGlucose class]];
    [typeList addObject:[MHVBloodPressure class]];
    [typeList addObject:[MHVCondition class]];
    [typeList addObject:[MHVCholesterol class]];
    [typeList addObject:[MHVDietaryIntake class]];
    [typeList addObject:[MHVDailyMedicationUsage class]];
    [typeList addObject:[MHVImmunization class]];
    [typeList addObject:[MHVEmotionalState class]];
    [typeList addObject:[MHVExercise class]];
    [typeList addObject:[MHVMedication class]];
    [typeList addObject:[MHVProcedure class]];
    [typeList addObject:[MHVSleepJournalAM class]];
    [typeList addObject:[MHVWeight class]];
    [typeList addObject:[MHVFile class]];
    [typeList addObject:[MHVHeartRate class]];

    [typeList sortUsingComparator:^NSComparisonResult (id obj1, id obj2)
    {
        MHVThingDataTyped *t1 = (MHVThingDataTyped *)obj1;
        MHVThingDataTyped *t2 = (MHVThingDataTyped *)obj2;
        return [[[t1 class] XRootElement] compare:[[t2 class] XRootElement]];
    }];

    return typeList;
}

- (Class)getSelectedClass
{
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;

    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [MHVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }

    return [self.classesForTypes objectAtIndex:selectedRow.row];
}

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
