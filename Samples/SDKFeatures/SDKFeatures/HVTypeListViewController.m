//
//  HVTypeListViewController.m
//  SDKFeatures
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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

#import "HVLib.h"
#import "HVTypeListViewController.h"
#import "HVDietaryIntakeFactory.h"
#import "HVEmotionalStateFactory.h"
#import "HVExerciseFactory.h"
#import "HVSleepJournalAMFactory.h"
#import "HVMedicationUsageFactory.h"
#import "HVBloodGlucoseFactory.h"
#import "HVBloodPressureFactory.h"
#import "HVCholesterolFactory.h"
#import "HVWeightFactory.h"

static const NSInteger c_numSecondsInDay = 86400;

@implementation HVTypeListViewController

@synthesize tableView = m_tableView;
@synthesize moreButton = m_moreButton;
@synthesize statusLabel = m_statusLabel;

-(void)dealloc
{
    m_tableView.dataSource = nil;
    m_tableView.delegate = nil;
    
    [m_tableView release];
    [m_moreButton release];
    [m_classesForTypes release];
    [m_actions release];
    [m_features release];
    
    [super dealloc];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [HVClient current].currentRecord.name;

    m_classesForTypes = [[HVTypeListViewController classesForTypesToDemo] retain];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HVCell"] autorelease];
        HVCHECK_NOTNULL(cell);
    }
    
    NSString* typeName = [[m_classesForTypes objectAtIndex:indexPath.row] XRootElement];
    cell.textLabel.text = typeName;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
    
LError:
    return nil;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class selectedCls = [m_classesForTypes objectAtIndex:indexPath.row];
    
    HVTypeViewController* typeView = [[[HVTypeViewController alloc] initWithTypeClass:selectedCls useMetric:FALSE] autorelease];
    HVCHECK_NOTNULL(typeView);
    
    [self.navigationController pushViewController:typeView animated:TRUE];
    
    return;
    
LError:
    [HVUIAlert showInformationalMessage:@"Could not create HVTypeViewController"];
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
    NSMutableArray* typeList = [[[NSMutableArray alloc] init] autorelease];
    
    [typeList addObject:[HVBloodGlucose class]];
    [typeList addObject:[HVBloodPressure class]];
    [typeList addObject:[HVCondition class]];
    [typeList addObject:[HVCholesterolV2 class]];
    [typeList addObject:[HVDietaryIntake class]];
    [typeList addObject:[HVDailyMedicationUsage class]];
    [typeList addObject:[HVImmunization class]];
    [typeList addObject:[HVEmotionalState class]];
    [typeList addObject:[HVExercise class]];
    [typeList addObject:[HVMedication class]];
    [typeList addObject:[HVProcedure class]];
    [typeList addObject:[HVSleepJournalAM class]];
    [typeList addObject:[HVWeight class]];
    [typeList addObject:[HVFile class]];
    
    [typeList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        HVItemDataTyped* t1 = (HVItemDataTyped *) obj1;
        HVItemDataTyped* t2 = (HVItemDataTyped *) obj2;
        return [[[t1 class] XRootElement] compare:[[t2 class] XRootElement]];
    }];
    
    return typeList;
}

-(Class )getSelectedClass
{
    NSIndexPath* selectedRow = m_tableView.indexPathForSelectedRow;
    if (!selectedRow || selectedRow.row == NSNotFound)
    {
        [HVUIAlert showInformationalMessage:@"Please select a data type"];
        return nil;
    }
    
    return [m_classesForTypes objectAtIndex:selectedRow.row];
}

-(BOOL) addStandardFeatures
{
    m_features = [[HVMoreFeatures alloc] init];
    HVCHECK_NOTNULL(m_features);
    m_features.controller = self;
    
    m_actions = [[HVFeatureActions alloc] init];
    HVCHECK_NOTNULL(m_actions);
    
    [m_actions addFeature:@"Disconnect app" andAction:^{
        [m_features disconnectApp];
    }];
    
    [m_actions addFeature:@"GetServiceDefintion" andAction:^{
        [m_features getServiceDefinition];
    }];

    return TRUE;
    
LError:
    return FALSE;
}

@end
