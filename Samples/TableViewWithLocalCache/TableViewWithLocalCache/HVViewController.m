//
//  HVViewController.m
//  TableViewWithLocalCache
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
//

#import "HVViewController.h"

@implementation HVItemsDataSource


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d items", self.typeView.count];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Last Sync: %@",
            [self.typeView.lastUpdateDate toStringWithFormat:@"dd-MM-yyyy hh:mm:ss a"]
            ];
}

-(void)synchronizationCompletedInView:(HVTypeView *)view
{
    [super synchronizationCompletedInView:view];
    [self.parentController showStatus:nil];
}

-(void)synchronizationFailedInView:(HVTypeView *)view withError:(id)ex
{
    [super synchronizationFailedInView:view withError:ex];
    [self.parentController showStatus:@"Sync failed."];
}

-(NSString *)effectiveDateStringForItem:(HVItem *)item
{
    return [super effectiveDateStringForItem:item];
}

-(NSString *)descriptionStringForItem:(HVItem *)item
{
    return [super descriptionStringForItem:item];
}

@end

@interface HVViewController ()

-(void) startApp;
-(void) initInternal;
-(void) initTableForTypeID:(NSString *) typeID;

-(HVItem *) createRandomItem;

@end

@implementation HVViewController

-(void)showStatus:(NSString *)text
{
    self.title = text ? text : @"Weight";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startApp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startApp
{
    [self showStatus:@"Starting..."];
    [[HVClient current] startWithParentController:self andStartedCallback:^(id sender) {
        
        if ([HVClient current].provisionStatus == HVAppProvisionSuccess)
        {
            [self showStatus:@"Started."];
            [self initInternal];
        }
        else
        {
            [self showStatus:@"Startup failed."];
        }
    }];

}

-(void)initInternal
{
    NSString* typeID = [HVWeight typeID];
    [self showStatus:nil];
    
    [self initTableForTypeID:typeID];
}

-(void)initTableForTypeID:(NSString *)typeID
{
    HVRecordReference* record = [[HVClient current].records objectAtIndex:0];
    //
    // This data source will display items from the local store, only going to HealthVault
    // if the data is not locally available
    //
    m_dataSource = [[HVItemsDataSource alloc] initForTable:self.itemTable withRecord:record andTypeID:typeID];
    m_dataSource.parentController = self;
    
    if ((m_dataSource.typeView.count == 0) || [m_dataSource.typeView isStale:3600])
    {
        [self synchronize:nil];
    }
}

-(HVItem *)createRandomItem
{
    HVItem* item = [HVWeight newItem];
    
    item.weight.inPounds = [HVRandom randomDoubleInRangeMin:130 max:150];
    item.weight.when = [[HVDateTime alloc] initNow];
    
    return item;
}

- (IBAction)synchronize:(id)sender
{
    [self showStatus:@"Syncing..."];
    //
    // Synchronize only refetches updated item keys.
    // Actual items are downloaded only when they are actually accessed/needed AND if not already locally available.
    //
    [m_dataSource.typeView refreshWithCallback:^(HVTask *task) {
        @try
        {
            [task checkSuccess];
            [self showStatus:nil];
        }
        @catch (NSException *exception)
        {
            [self showStatus:@"Sync failed."];
        }
    }];;
}

- (IBAction)deleteLocal:(id)sender
{
    // Delete ALL locally cached data
    [m_dataSource.typeView.store resetData];
    
    [self.itemTable reloadData];
}
@end
