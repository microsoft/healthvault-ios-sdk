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
#import "MHVActionPlanTaskListViewController.h"

@interface MHVTypeListViewController ()

@property (nonatomic, strong) NSDictionary *itemTypes;
@property (nonatomic, strong) NSDictionary *itemViewTypes;
@property (nonatomic, strong) NSArray *itemList;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;

@property (nonatomic, assign) BOOL hasLoadedPersonImage;

@end

@implementation MHVTypeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = [self personName];

    [self setupList];
    
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
    
    [connection.thingClient getPersonalImageWithRecordId:connection.personInfo.selectedRecordID
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
    return [self.itemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }

    NSString *typeName = _itemList[indexPath.row];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = _itemList[indexPath.row];
    Class selectedCls = [self.itemTypes objectForKey:name];
    Class controllerClass = [self.itemViewTypes objectForKey:name];

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

- (void)setupList
{
    NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *viewDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *typeList = [[NSMutableArray alloc] init];
    
    NSArray<Class> *thingTypes = @[[MHVBloodGlucose class],
                            [MHVBloodPressure class],
                            [MHVCondition class],
                            [MHVCholesterol class],
                            [MHVDietaryIntake class],
                            [MHVDailyMedicationUsage class],
                            [MHVImmunization class],
                            [MHVEmotionalState class],
                            [MHVExercise class],
                            [MHVMedication class],
                            [MHVProcedure class],
                            [MHVSleepJournalAM class],
                            [MHVWeight class],
                            [MHVFile class],
                            [MHVHeartRate class]];

    for (int i = 0; i < thingTypes.count; i++) {
        NSString *name = [thingTypes[i] XRootElement];
        [typeList addObject:name];
        [itemDictionary setObject:thingTypes[i] forKey:name];
        [viewDictionary setObject:[MHVTypeViewController class] forKey:name];
    }
    
    NSString *name = @"action plans [REST]";
    [typeList addObject:name];
    [itemDictionary setObject:[MHVActionPlan class] forKey:name];
    [viewDictionary setObject:[MHVActionPlansListViewController class] forKey:name];
    
    name = @"action plan tasks [REST]";
    [typeList addObject:name];
    [itemDictionary setObject:[MHVActionPlanTask class] forKey:name];
    [viewDictionary setObject:[MHVActionPlanTaskListViewController class] forKey:name];
    
    name = @"goals [REST]";
    [typeList addObject:name];
    [itemDictionary setObject:[MHVGoal class] forKey:name];
    [viewDictionary setObject:[MHVGoalsListViewController class] forKey:name];

    [typeList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];

    _itemTypes = itemDictionary;
    _itemViewTypes = viewDictionary;
    _itemList = typeList;
}

- (Class)getSelectedClass
{
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;

    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [MHVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }

    NSString *typeName = _itemList[selectedRow.row];
    return [self.itemTypes objectForKey:typeName];
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
