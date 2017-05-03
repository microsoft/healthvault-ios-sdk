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
// Application Startup
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

-(void)startApp
{
    //
    // Startup the HealthVault Client
    // This will automatically ensure that application instance is correctly provisioned to access the user's HealthVault record
    // Look at ClientSettings.xml
    //
    [[MHVClient current] startWithParentController:self andStartedCallback:^(id sender) 
    {
        if ([MHVClient current].provisionStatus == HVAppProvisionSuccess)
        {
            [self startupSuccess];
        }
        else
        {
            [self startupFailed];
        }
    }];
}

-(void)startupSuccess
{
    //
    // Update the UI to show the record owner's display name
    //
    NSString* displayName = [MHVClient current].currentRecord.displayName;
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Weight", displayName];
    //
    // Fetch list of weights from HealthVault
    //
    [self getWeightsFromHealthVault];   
}

-(void)startupFailed
{
    [MHVUIAlert showWithMessage:@"Provisioning not completed. Retry?" callback:^(id sender) {
        
        MHVUIAlert *alert = (MHVUIAlert *) sender;
        if (alert.result == HVUIAlertOK)
        {
            [self startApp];
        }
    }];
}

//-------------------------------------------
//
// Get/Put items to/from HealthVault
//
//-------------------------------------------
-(void)getWeightsFromHealthVault
{
    [[MHVClient current].currentRecord getItemsForClass:[MHVWeight class] callback:^(MHVTask *task) 
    {
        @try {
            //
            // Save the collection of items retrieved
            //
            HVCLEAR(m_items);
            m_items = [((MHVGetItemsTask *) task).itemsRetrieved retain];
            //
            // Refresh UI
            //
            [self refreshView];
        }
        @catch (NSException *exception) {
            [MHVUIAlert showInformationalMessage:exception.description];
        }
    }];
}

//
// Push a new weight into HealthVault
//
-(void)putWeightInHealthVault:(MHVItem *)item
{
    [[MHVClient current].currentRecord putItem:item callback:^(MHVTask *task) 
    {
        @try {
            //
            // Throws if there was a failure. Look at MHVServerException for details
            //
            [task checkSuccess];  
            //
            // Refresh with the latest list of weights from HealthVault
            //
            [self getWeightsFromHealthVault];  
        }
        @catch (NSException *exception) {
            [MHVUIAlert showInformationalMessage:exception.description];
        }
    } ];
}

-(void)removeWeightFromHealthVault:(MHVItemKey *)itemKey
{
    [[MHVClient current].currentRecord removeItemWithKey:itemKey callback:^(MHVTask *task) {
        @try {
            [task checkSuccess];  
            //
            // Refresh
            //
            [self getWeightsFromHealthVault];
        }
       @catch (NSException *exception) {
            [MHVUIAlert showInformationalMessage:exception.description];
        }
    }];
}

//
// Create a new random weight between 130 and 150 pounds, and the current date&time
//
-(MHVItem *)newWeight
{
    MHVItem* item = [MHVWeight newItem];
 
    double pounds = roundToPrecision([MHVRandom randomDoubleInRangeMin:130 max:150], 2);
    item.weight.inPounds = pounds;
    item.weight.when = [[[MHVDateTime alloc] initNow] autorelease];
    
    return item;
}

-(void)changeWeight:(MHVItem *)item
{
    item.weight.inPounds = [MHVRandom randomDoubleInRangeMin:130 max:150];
}

-(void)getWeightsForLastNDays:(int)numDays
{
    //
    // Set up a filter for HealthVault items
    //
    MHVItemFilter* itemFilter = [[[MHVItemFilter alloc] initWithTypeClass:[MHVWeight class]] autorelease];  // Querying for weights
    //
    // We only want weights no older than numDays
    //
    itemFilter.effectiveDateMin = [[[NSDate alloc] initWithTimeIntervalSinceNow:(-(numDays * (24 * 3600)))] autorelease]; // Interval is in seconds
    //
    // Create a query to issue
    //
    MHVItemQuery* query = [[[MHVItemQuery alloc] initWithFilter:itemFilter] autorelease];
    
    [[MHVClient current].currentRecord getItems:query callback:^(MHVTask *task) {
        
        @try {
            //
            // Save the collection of items retrieved
            //
            HVCLEAR(m_items);
            m_items = [((MHVGetItemsTask *) task).itemsRetrieved retain];
            //
            // Refresh UI
            //
            [self refreshView];
        }
        @catch (NSException *exception) {
            [MHVUIAlert showInformationalMessage:exception.description];
        }       
    }];
}

//-------------------------------------------
//
// Displaying a list of Weights in a Table View
//
//-------------------------------------------
        
-(void)refreshView
{
    [self.itemsTable reloadData];
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
    NSInteger itemIndex = indexPath.row;
    //
    // Retrieve weight information for the given HealthVault item
    //
    MHVWeight* weight = [m_items itemAtIndex:itemIndex].weight;
    //
    // Display it in the table cell for the current row
    //
    UITableViewCell *cell = [self getCellFor:tableView];
    [self displayWeight:weight inCell:cell];
     
    return cell;
}

-(void)displayWeight:(MHVWeight *)weight inCell:(UITableViewCell *)cell
{
    //
    // Display WHEN the weight measurement was taken
    //
    cell.textLabel.text = [weight.when toStringWithFormat:@"MM/dd/YY hh:mm aaa"];
    //
    // Display the weight in pounds
    //
    cell.detailTextLabel.text = [weight stringInPoundsWithFormat:@"%.2f lb"];

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
    [self getWeightsFromHealthVault];
}

//
// Generate a random new weight entry for today and add it to HealthVault
//
- (IBAction)addButtonClicked:(id)sender 
{
    MHVItem* item = [[self newWeight] autorelease];
    [self putWeightInHealthVault:item];
}

//
// Delete the selected item from HealthVault
//
- (IBAction)deleteButtonClicked:(id)sender 
{
    NSIndexPath* selection = [self.itemsTable indexPathForSelectedRow];
    if (!selection)
    {
        return;
    }
    
    NSUInteger itemIndex = selection.row;
    [self removeWeightFromHealthVault:[m_items itemAtIndex:itemIndex].key];
}

//
// Change the selected item to a new weight and push it to HealthVault
//
- (IBAction)updateButtonClicked:(id)sender 
{
    NSIndexPath* selection = [self.itemsTable indexPathForSelectedRow];
    if (!selection)
    {
        return;
    }
    
    NSUInteger itemIndex = selection.row;
    MHVItem* item = [m_items itemAtIndex:itemIndex];

    [self changeWeight:item];
    
    [self putWeightInHealthVault:item];
}

//
// User may want to disconnect their account
//
- (IBAction)disconnectClicked:(id)sender
{
    [MHVUIAlert showYesNoWithMessage:@"Are you sure you want to disconnect this application from HealthVault?\r\nIf you click Yes, you will need to re-authorize the app." callback:^(id sender) {
        
        MHVUIAlert* alert = (MHVUIAlert *) sender;
        if (alert.result != HVUIAlertOK)
        {
            return;
        }
        HVCLEAR(m_items);
        [self refreshView];
        //
        // REMOVE RECORD AUTHORIZATION.
        //
        [[MHVClient current].user removeAuthForRecord:[MHVClient current].currentRecord withCallback:^(MHVTask *task) {
            
            [[MHVClient current] resetProvisioning];  // Removes local state
            //
            // Restart app auth
            //
            [self startApp];
        }];
    }];
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
