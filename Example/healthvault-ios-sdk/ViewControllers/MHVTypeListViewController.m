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
#import "MHVActionPlansListViewController.h"
#import "MHVActionPlanTaskListViewController.h"
#import "MHVGoalsRecommendationsListViewController.h"
#import "MHVTimelineSnapshotViewController.h"

@interface MHVTypeListViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *moreButton;
@property (nonatomic, strong) IBOutlet MHVStatusLabel *statusLabel;

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;
@property (nonatomic, strong) NSDictionary *itemTypes;
@property (nonatomic, strong) NSDictionary *itemViewTypes;
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *itemSections;
@property (nonatomic, strong) MHVFeatureActions *actions;
@property (nonatomic, strong) MHVMoreFeatures *features;

@property (nonatomic, assign) BOOL hasLoadedPersonImage;

@end

@implementation MHVTypeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = [self personName];
    
    [self setupList];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self addStandardFeatures];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadPersonImage) name:kPersonalImageUpdateNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    NSUInteger index = [self.connection.personInfo.records indexOfObjectPassingTest:^BOOL(MHVRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        return [obj.ID isEqual:self.connection.personInfo.selectedRecordID];
    }];
    
    if (index != NSNotFound)
    {
        return self.connection.personInfo.records[index].displayName;
    }
    else
    {
        return self.connection.personInfo.name;
    }
}

- (void)downloadPersonImage
{
    [self.connection.thingClient getPersonalImageWithRecordId:self.connection.personInfo.selectedRecordID
                                                   completion:^(UIImage * _Nullable image, NSError * _Nullable error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (image)
             {
                 [self setTitleViewImage:image];
             }
         }];
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

- (UILabel *)labelForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 0)
    {
        title = @"Thing Types";
    }
    else if (section == 1)
    {
        title = @"Remote Monitoring Types";
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    label.textColor = UIColor.blackColor;
    label.text = title;
    [label sizeToFit];
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self labelForHeaderInSection:section].bounds.size.height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [self labelForHeaderInSection:section];
    
    label.frame = CGRectOffset(label.frame, 15, 0);
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.95];
    [containerView addSubview:label];
    
    return containerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.itemSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemSections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    NSString *typeName = self.itemSections[indexPath.section][indexPath.row];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *name = self.itemSections[indexPath.section][indexPath.row];
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
    [self.actions showWithViewController:self];
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
    NSMutableArray<NSString *> *hvTypeList = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *restTypeList = [[NSMutableArray alloc] init];
    
    NSMutableArray<Class> *thingTypes = [NSMutableArray new];
    
    //HealthVault Thing Types from cached types
    for (NSString *typeId in self.connection.cacheConfiguration.cacheTypeIds)
    {
        MHVThing *thing = [[MHVThing alloc] initWithType:typeId];
        [thingTypes addObject:[thing.data.typed class]];
    }
    
    for (int i = 0; i < thingTypes.count; i++)
    {
        NSString *name = [thingTypes[i] XRootElement];
        
        [hvTypeList addObject:name];
        [itemDictionary setObject:thingTypes[i] forKey:name];
        [viewDictionary setObject:[MHVTypeViewController class] forKey:name];
    }
    
    //Action Plan Types
    NSString *name = @"action plans";
    [restTypeList addObject:name];
    [itemDictionary setObject:[MHVActionPlan class] forKey:name];
    [viewDictionary setObject:[MHVActionPlansListViewController class] forKey:name];
    
    name = @"action plan tasks";
    [restTypeList addObject:name];
    [itemDictionary setObject:[MHVActionPlanTask class] forKey:name];
    [viewDictionary setObject:[MHVActionPlanTaskListViewController class] forKey:name];
    
    name = @"goals";
    [restTypeList addObject:name];
    [itemDictionary setObject:[MHVGoal class] forKey:name];
    [viewDictionary setObject:[MHVGoalsListViewController class] forKey:name];
    
    name = @"goal recommendations";
    [restTypeList addObject:name];
    [itemDictionary setObject:[MHVGoalRecommendation class] forKey:name];
    [viewDictionary setObject:[MHVGoalsRecommendationsListViewController class] forKey:name];
    
    name = @"timeline";
    [restTypeList addObject:name];
    [itemDictionary setObject:[MHVTimelineSnapshot class] forKey:name];
    [viewDictionary setObject:[MHVTimelineSnapshotViewController class] forKey:name];
    
    [hvTypeList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
     {
         return [obj1 compare:obj2];
     }];
    
    [restTypeList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
     {
         return [obj1 compare:obj2];
     }];
    
    _itemTypes = itemDictionary;
    _itemViewTypes = viewDictionary;
    _itemSections = @[hvTypeList, restTypeList];
}

- (Class)getSelectedClass
{
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;
    
    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [MHVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }
    
    NSString *typeName = self.itemSections[selectedRow.section][selectedRow.row];
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
    
    [self.actions addFeature:@"Demo ApplicationSettings" andAction:^
     {
         [weakFeatures demonstrateApplicationSettings];
     }];
    
    [self.actions addFeature:@"GetPersonInfo" andAction:^
     {
         [weakFeatures getPersonInfo];
     }];
    
    [self.actions addFeature:@"GetAuthorizedRecords" andAction:^
     {
         [weakFeatures getAuthorizedRecords];
     }];

    [self.actions addFeature:@"GetAuthorizedPeople" andAction:^
     {
         [weakFeatures getAuthorizedPeople];
     }];

    [self.actions addFeature:@"GetRecordOperations:1" andAction:^
     {
         [weakFeatures getRecordOperations];
     }];
    
    [self.actions addFeature:@"Authorize records" andAction:^
     {
         [weakFeatures authorizeAdditionalRecords];
     }];
    
    return TRUE;
}

@end
