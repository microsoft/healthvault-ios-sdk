//
//  MHVTypeListViewController.m
//  SDKFeatures
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVLib.h"
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


@implementation MHVTypeListViewController

@synthesize tableView = m_tableView;
@synthesize moreButton = m_moreButton;
@synthesize statusLabel = m_statusLabel;

-(void)dealloc
{
    m_tableView.dataSource = nil;
    m_tableView.delegate = nil;
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = [MHVClient current].currentRecord.name;

    m_classesForTypes = [MHVTypeListViewController classesForTypesToDemo];
    m_tableView.dataSource = self;
    m_tableView.delegate = self;
    
    [self addStandardFeatures];
}

//-------------------------------------
//
// UITableViewDataSource & Delegate
//
//-------------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_classesForTypes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [m_tableView dequeueReusableCellWithIdentifier:@"HVCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HVCell"];
    }
    
    NSString* typeName = [[m_classesForTypes objectAtIndex:indexPath.row] XRootElement];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class selectedCls = [m_classesForTypes objectAtIndex:indexPath.row];
    
    MHVTypeViewController* typeView = [[MHVTypeViewController alloc] initWithTypeClass:selectedCls useMetric:FALSE];
    if (!typeView)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVTypeViewController"];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:TRUE];
    
    return;
}

//-------------------------------------
//
// UI Handlers
//
//-------------------------------------

- (IBAction)moreFeatures:(id)sender
{
    [m_actions showFrom:m_moreButton];
}

//-------------------------------------
//
// Methods
//
//-------------------------------------

+(NSArray *)classesForTypesToDemo
{
    NSMutableArray* typeList = [[NSMutableArray alloc] init];
    
    [typeList addObject:[MHVBloodGlucose class]];
    [typeList addObject:[MHVBloodPressure class]];
    [typeList addObject:[MHVCondition class]];
    [typeList addObject:[MHVCholesterolV2 class]];
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
    
    [typeList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MHVItemDataTyped* t1 = (MHVItemDataTyped *) obj1;
        MHVItemDataTyped* t2 = (MHVItemDataTyped *) obj2;
        return [[[t1 class] XRootElement] compare:[[t2 class] XRootElement]];
    }];
    
    return typeList;
}

-(Class )getSelectedClass
{
    NSIndexPath* selectedRow = m_tableView.indexPathForSelectedRow;
    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [MHVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }
    
    return [m_classesForTypes objectAtIndex:selectedRow.row];
}

-(BOOL) addStandardFeatures
{
    m_features = [[MHVMoreFeatures alloc] init];
    HVCHECK_NOTNULL(m_features);
    m_features.controller = self;
    
    __weak __typeof__(m_features) weakFeatures = m_features;
    
    m_actions = [[MHVFeatureActions alloc] init];
    HVCHECK_NOTNULL(m_actions);
    
    [m_actions addFeature:@"Disconnect app" andAction:^{
        [weakFeatures disconnectApp];
    }];
    
    [m_actions addFeature:@"GetServiceDefintion" andAction:^{
        [weakFeatures getServiceDefinition];
    }];

    return TRUE;
    
LError:
    return FALSE;
}

@end
