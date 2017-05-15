//
//  MHVMasterViewController.m
//  HelloHealthVault
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "MHVMasterViewController.h"

@implementation MHVMasterViewController
@synthesize itemsTable;

//---------------------------
//
// HealthVault code
//
//---------------------------
-(void)startApp
{
    [[MHVClient current] startWithParentController:self andStartedCallback:^(id sender) 
     {
         if ([MHVClient current].provisionStatus == HVAppProvisionSuccess)
         {
             self.navigationItem.title = [MHVClient current].currentRecord.name;  // Show the record owner's name
             [self getWeights];   
         }
     }];
}

-(void)getWeights
{
    [[MHVClient current].currentRecord getItemsForType:[MHVWeight typeID] callback:^(MHVTask *task) 
     {
         m_items = [((MHVGetThingsTask *) task).itemsRetrieved retain];
         //
         // Refresh UI
         //
         [self.itemsTable reloadData];
     }];
    
}

-(void)displayItemAtIndex:(NSUInteger)index inCell:(UITableViewCell *)cell
{
    MHVWeight* weight = [m_items itemAtIndex:index].weight;
    //
    // Display WHEN the weight measurement was taken
    //
    cell.textLabel.text = [weight.when toStringWithFormat:@"MM/dd/YY hh:mm aaa"];
    //
    // Display the weight in pounds
    //
    cell.detailTextLabel.text = [weight stringInPounds];
    
}

-(void)addNewWeight
{
    MHVThing* item = [[MHVWeight newItem] autorelease];
    
    item.weight.inPounds = 135;
    item.weight.when = [[MHVDateTime alloc] initNow];  
    
    [[MHVClient current].currentRecord putItem:item callback:^(MHVTask *task) 
     {
         [self getWeights];  // refresh the UI  
     } ];
}

//---------------------------
//
// Standard View and UITableView stuff
//
//---------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.itemsTable.dataSource = self;
    //
    // Start the HealthVault client
    //
    [self startApp];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //
    // If we've already retrieved items, then one row per item
    //
    if (m_items)
    {
        return m_items.count;
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self getCellFor:tableView];
    [self displayItemAtIndex:indexPath.row inCell:cell];
     
    return cell;
}

-(UITableViewCell *)getCellFor:(UITableView *)table
{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"HV"];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HV"] autorelease];
    }
    
    return cell;
}

//-------------------------------------------
//
// Button Handlers
//
//-------------------------------------------
//
// Refresh Displayed Data from HealthVault
//
- (IBAction)refreshButtonClicked:(id)sender 
{
    [self getWeights];
}

//
// Generate a random new weight entry for today and add it to HealthVault
//
- (IBAction)addButtonClicked:(id)sender 
{
    [self addNewWeight];
}

//-------------------------------------------
//
// Standard View Infrastructure
//
//-------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Hello HV", @"Master view title");
    }
    return self;
}
					
- (void)dealloc
{
    [m_items release];
    [itemsTable release];
    [super dealloc];
}

#pragma mark - Table View

- (void)viewDidUnload {
    [self setItemsTable:nil];
    [super viewDidUnload];
}
@end
