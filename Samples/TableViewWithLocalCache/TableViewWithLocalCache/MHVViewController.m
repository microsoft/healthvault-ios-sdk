//
//  MHVViewController.m
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

#import "MHVViewController.h"

@implementation MHVItemsDataSource


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%lu items", (unsigned long)self.typeView.count];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Last Sync: %@",
            [self.typeView.lastUpdateDate toStringWithFormat:@"dd-MM-yyyy hh:mm:ss a"]
            ];
}

-(void)synchronizationCompletedInView:(MHVTypeView *)view
{
    [super synchronizationCompletedInView:view];
    [self.parentController showStatus:nil];
}

-(void)synchronizationFailedInView:(MHVTypeView *)view withError:(id)ex
{
    [super synchronizationFailedInView:view withError:ex];
    [self.parentController showStatus:@"Sync failed."];
}

-(NSString *)effectiveDateStringForItem:(MHVItem *)item
{
    return [super effectiveDateStringForItem:item];
}

-(NSString *)descriptionStringForItem:(MHVItem *)item
{
    return [super descriptionStringForItem:item];
}

@end

@interface MHVViewController ()

-(void) startApp;
-(void) initInternal;
-(void) initTableForTypeID:(NSString *) typeID;

-(MHVItem *) createRandomItem;

@end

@implementation MHVViewController

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
    [[MHVClient current] startWithParentController:self andStartedCallback:^(id sender) {
        
        if ([MHVClient current].provisionStatus == HVAppProvisionSuccess)
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
    NSString* typeID = [MHVWeight typeID];
    [self showStatus:nil];
    
    [self initTableForTypeID:typeID];
}

-(void)initTableForTypeID:(NSString *)typeID
{
    MHVRecordReference* record = [[MHVClient current].records objectAtIndex:0];
    //
    // This data source will display items from the local store, only going to HealthVault
    // if the data is not locally available
    //
    m_dataSource = [[MHVItemsDataSource alloc] initForTable:self.itemTable withRecord:record andTypeID:typeID];
    m_dataSource.parentController = self;
    
    if ((m_dataSource.typeView.count == 0) || [m_dataSource.typeView isStale:3600])
    {
        [self synchronize:nil];
    }
}

-(MHVItem *)createRandomItem
{
    MHVItem* item = [MHVWeight newItem];
    
    item.weight.inPounds = [MHVRandom randomDoubleInRangeMin:130 max:150];
    item.weight.when = [[MHVDateTime alloc] initNow];
    
    return item;
}

- (IBAction)synchronize:(id)sender
{
    [self showStatus:@"Syncing..."];
    //
    // Synchronize only refetches updated item keys.
    // Actual items are downloaded only when they are actually accessed/needed AND if not already locally available.
    //
    [m_dataSource.typeView refreshWithCallback:^(MHVTask *task) {
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
