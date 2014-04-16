//
//  HVViewController.m
//  TableViewWithSynchronizedType
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


@implementation HVWeightTypeDataSource

-(NSString *)effectiveDateStringForItem:(HVItem *)item
{
    return [item.effectiveDate toStringWithFormat:@"MM-dd-yyyy hh:mm a"];
}

-(NSString *)descriptionStringForItem:(HVItem *)item
{
    return [item.weight stringInPoundsWithFormat:@"%.2f lbs"];
}

@end

@interface HVViewController ()

-(double) generateRandomWeight;

-(void) startApp;
-(BOOL) initInternal;
-(BOOL) initUITableViewDataSource;
-(BOOL) initCommitScheduler;
-(void) subscribeToNotifications;
-(void) unsubscribeToNotifications;

-(void) addNewItem;
-(void) deleteItem;
-(void) updateItem;

-(void) refreshView;
-(void) refreshViewIfNecessary;
-(void) refreshViewCompleted:(HVTask *) task;

//
// Handle notifications about commit activity
//
-(void) onCommitStarted:(NSNotification *) notification;
-(void) onCommitFinished:(NSNotification *) notification;
-(void) onCommitError:(NSNotification *) notification;

@end

@implementation HVViewController

-(void)showStatus:(NSString *)text
{
    self.statusLabel.text = text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startApp];
}

-(void)viewWillClose
{
    [m_commitScheduler cancelActiveCommits];
    [self unsubscribeToNotifications];
}

//--------------------------------------
//
// Initialization
//
//--------------------------------------

-(void)startApp
{
    [self showStatus:@"Starting"];
    [[HVClient current] startWithParentController:self andStartedCallback:^(id sender) {
        
        if ([HVClient current].provisionStatus == HVAppProvisionSuccess)
        {
            [self showStatus:nil];
            [self initInternal];
        }
        else
        {
            [self showStatus:@"Startup failed."];
        }
    }];
}

-(BOOL)initInternal
{
    self.title = @"Weight";
    
    m_type = [[[HVClient current] getCurrentRecordStore] getSynchronizedTypeForTypeID:[HVWeight typeID]];
    HVCHECK_NOTNULL(m_type);
    
    HVCHECK_SUCCESS([self initUITableViewDataSource]);
    HVCHECK_SUCCESS([self initCommitScheduler]);
    [self subscribeToNotifications];
    
    [self refreshViewIfNecessary];
    
    return TRUE;
    
LError:
    [HVUIAlert showInformationalMessage:@"Could not initialize application."];
    return FALSE;
}

-(BOOL)initUITableViewDataSource
{
    m_dataSource = [[HVWeightTypeDataSource alloc] initForTable:self.itemTable withType:m_type];
    HVCHECK_NOTNULL(m_dataSource);
    
    m_dataSource.rowAnimation = UITableViewRowAnimationRight;
    m_dataSource.cellStyle = UITableViewCellStyleValue1;
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)initCommitScheduler
{
    //
    // You don't have to use a commit scheduler. You could also commit changes manually by calling
    // the appropriate methods on HVLocalVault or HVLocalRecordStore
    // This will try to automatically upload changes every 15 seconds..
    //
    m_commitScheduler = [[HVItemCommitScheduler alloc] initWithFrequency:15];
    HVCHECK_NOTNULL(m_commitScheduler);
    
    m_commitScheduler.isEnabled = TRUE;
    return TRUE;
    
LError:
    return FALSE;
}

-(void)subscribeToNotifications
{
    //
    // Subscribe to notifications about background commit activity
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onCommitStarted:)
     name:HVItemChangeManagerStartingCommitNotification
     ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onCommitFinished:)
     name:HVItemChangeManagerFinishedCommitNotification
     ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onCommitError:)
     name:HVItemChangeManagerExceptionNotification
     ];
}

-(void)unsubscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//--------------------------------------
//
// UI Action handlers
//
//--------------------------------------
- (IBAction)addNew:(id)sender
{
    [self addNewItem];
}

- (IBAction)deleteItem:(id)sender {
    [self deleteItem];
}

- (IBAction)updateItem:(id)sender
{
    [self updateItem];
}

- (IBAction)synchronize:(id)sender
{
    if ([m_type hasPendingChanges])
    {
        [m_commitScheduler commitChanges];
    }
    else
    {
        [self refreshView];
    }
}

- (IBAction)deleteLocalItems:(id)sender
{
    [m_type removeAllLocalItems];
    [m_dataSource reloadAllItems];
}

//--------------------------------------
//
// Methods
//
//--------------------------------------

-(double)generateRandomWeight
{
    return roundToPrecision([HVRandom randomDoubleInRangeMin:130 max:150], 2);
}

-(void)addNewItem
{
    HVItem* item = [HVWeight newItem];
    
    [item.weight setInPounds:[self generateRandomWeight]];
    item.weight.when = [[HVDateTime alloc] initNow];
    
    [m_type addNewItem:item];
    [m_dataSource updateTableForNewItem:item];
}

-(void)deleteItem
{
    NSIndexPath* selection = [self.itemTable indexPathForSelectedRow];
    if (!selection)
    {
        [HVUIAlert showInformationalMessage:@"Please select an item to delete"];
        return;
    }
    
    NSUInteger itemIndex = selection.row;
    if ([m_type removeItemAtIndex:itemIndex])
    {
        [m_dataSource removeTableRowAtIndex:itemIndex];
    }
}

-(void)updateItem
{
    NSIndexPath* selection = [self.itemTable indexPathForSelectedRow];
    if (!selection)
    {
        [HVUIAlert showInformationalMessage:@"Please select an item to update"];
        return;
    }
    
    NSUInteger itemIndex = selection.row;
    //
    // To edit an item, we must first open it for editing
    //
    HVItemEditOperation* editOp = [m_type openItemForEditAtIndex:itemIndex];
    if (!editOp)
    {
        [HVUIAlert showInformationalMessage:@"Item is locked."];
        return;
    }
    
    HVItem* item = editOp.item;
    item.weight.inPounds = [self generateRandomWeight];
    //
    // This will commit the change. You can also call [editOp cancel]
    //
    [editOp commit];
    [m_dataSource reloadItem:item];
}

-(void)refreshView
{
    [self showStatus:@"Refreshing view..."];
    
    self.activeTask = [m_type refreshWithCallback:^(HVTask *task)
    {
        [self refreshViewCompleted:task];
    }];
    
    if (!self.activeTask)
    {
        [HVUIAlert showInformationalMessage:@"Could not begin refreshing view."];
    }
}

-(void)refreshViewIfNecessary
{
    if (m_type.count == 0 || [m_type isStale:3600]) // If view is older than 1 hour
    {
        [self refreshView];
    }
}

-(void)refreshViewCompleted:(HVTask *)task
{
    @try
    {
        self.activeTask = nil;
        
        [task checkSuccess];
        [self showStatus:nil];
    }
    @catch (NSException *exception)
    {
        [HVUIAlert showInformationalMessage:exception.description];
    }
}

//--------------------------------------
//
// Notification handlers
//
//--------------------------------------

-(void)onCommitStarted:(NSNotification *)notification
{
    [self showStatus:@"Committing changes..."];
}

-(void)onCommitFinished:(NSNotification *)notification
{
    [self showStatus:nil];
}

-(void)onCommitError:(NSNotification *)notification
{
    [self showStatus:@"Commit error."];
}

@end
