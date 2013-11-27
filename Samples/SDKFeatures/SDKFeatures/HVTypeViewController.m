//
//  HVTypeViewController.m
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

#import "HVTypeViewController.h"

@interface HVTypeViewController (HVPrivate)

-(HVItemCollection *) createRandomForDay:(NSDate *) date isMetric:(BOOL) metric;

//
// Creates multiple random items.. one each for each day in the give range
//
-(void) addRandomForDaysFrom:(NSDate *) start to:(NSDate *) end isMetric:(BOOL) metric;


//
// Completion methods
//
-(BOOL) getItemsCompleted:(HVTask *) task;
-(BOOL) putItemsCompleted:(HVTask *) task forDate:(NSDate *) date;
-(BOOL) removeItemCompleted:(HVTask *) task;

-(NSDate *) getNextDayAfter:(NSDate *) current endDate:(NSDate *) end;

@end

static const NSInteger c_numSecondsInDay = 86400;

@implementation HVTypeViewController

@synthesize items = m_items;
@synthesize itemTable = m_itemTable;
@synthesize statusLabel = m_statusLabel;
@synthesize moreActions = m_moreActions;

-(id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    HVCHECK_SELF;
    
    m_typeClass = typeClass;
    m_useMetric = metric;
    HVRETAIN(m_moreFeatures, [typeClass moreFeatures]);
    if (m_moreFeatures)
    {
        m_moreFeatures.controller = self;
    }
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    m_itemTable.dataSource = nil;
    
    [m_itemTable release];
    [m_statusLabel release];
    [m_moreActions release];
    [m_items release];
    [m_moreFeatures release];
    
    [super dealloc];
}


- (IBAction)addItem:(id)sender
{
    [self addRandomData:m_useMetric];
}

- (IBAction)removeItem:(id)sender
{
    [self removeCurrentItem];
}

- (IBAction)moreClicked:(id)sender
{
    if (m_moreFeatures)
    {
        [m_moreFeatures showFrom:m_moreActions];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!m_typeClass)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
        return;
    }

    m_itemTable.dataSource = self;
    
    //
    // When you click add, we add new items with random, but plausible data
    //
    // Data is created in the time range [TODAY, (Today - m_maxDaysOffsetRandoData)]
    // If m_createMultiple is TRUE, adds random data for EACH day in the range
    // Else only adds random data for the LAST day in the range.
    //
    // If m_maxDaysOffsetRandomData is 0, creates random data for TODAY
    //
    m_maxDaysOffsetRandomData = 0; // 90;
    m_createMultiple = FALSE;  
    
    self.navigationItem.title = [m_typeClass XRootElement]; // Every HVItemDataTyped implements this..
    if (!m_moreFeatures)
    {
        [m_moreActions setEnabled:FALSE];
    }
    
    [self getItemsFromHealthVault];
}

//-------------------------------------
//
// UITableViewDataSource
//
//-------------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([NSArray isNilOrEmpty:m_items])
    {
        return 0;
    }
    
    return m_items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [m_itemTable dequeueReusableCellWithIdentifier:@"HVItem"];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HVItem"] autorelease];
        HVCHECK_NOTNULL(cell);
    }
    
    HVItem* item = [m_items itemAtIndex:indexPath.row];
    NSString* whenString = [item.data.typed dateString];
    if ([NSString isNilOrEmpty:whenString])
    {
        whenString = [item.effectiveDate toStringWithStyle:NSDateFormatterShortStyle];
    }
    cell.textLabel.text = whenString;
    
    NSString* details;
    if (m_useMetric)
    {
        details = [item.data.typed detailsStringMetric];
    }
    else
    {
        details = [item.data.typed detailsString];
    }
    cell.detailTextLabel.text = details;
    
    return cell;
    
LError:
    return nil;
}

-(void)refreshView
{
    [self getItemsFromHealthVault];
}

//-------------------------------------
//
// Methods
//
//-------------------------------------

-(HVItem *)getSelectedItem
{
    if (!m_items)
    {
        return nil;
    }
    
    NSIndexPath* selectedRow = m_itemTable.indexPathForSelectedRow;
    if (!selectedRow ||
        selectedRow.row == NSNotFound ||
        selectedRow.row >= m_items.count)
    {
        return nil;
    }
    
    return [m_items itemAtIndex:selectedRow.row];
}

-(void)getItemsFromHealthVault
{
    [m_statusLabel showBusy];
    
    [[HVClient current].currentRecord getItemsForClass:m_typeClass callback:^(HVTask *task) {
        
        [self getItemsCompleted:task];
    }];
}

-(void)addRandomData:(BOOL)isMetric
{
    NSDate* end = [NSDate date];
    NSTimeInterval interval = -(c_numSecondsInDay * m_maxDaysOffsetRandomData);
    NSDate* date = [end dateByAddingTimeInterval:interval];
    if (!m_createMultiple)
    {
        end = date;
    }
    
    [self addRandomForDaysFrom:date to:end isMetric:isMetric];
    
}

-(void)removeCurrentItem
{
    HVItem* selectedItem = [self getSelectedItem];
    if (!selectedItem)
    {
        return;
    }
    
    [HVUIAlert showYesNoWithMessage:@"Permanently delete this item?" callback:^(id sender) {
        if (((HVUIAlert *)sender).result != HVUIAlertOK)
        {
            return;
        }
        //
        // REMOVE from HealthVault
        //
        [[HVClient current].currentRecord removeItemWithKey:selectedItem.key callback:^(HVTask *task) {
 
            [self removeItemCompleted:task];
        }];
    }];
}

-(void)showActivityAndStatus:(NSString *)status
{
    [m_statusLabel showActivity];
    m_statusLabel.text = status;
}

-(void)clearStatus
{
    //[m_statusLabel clearStatus];
}

@end

@implementation HVTypeViewController (HVPrivate)

-(HVItemCollection *) createRandomForDay:(NSDate *) date isMetric:(BOOL) metric
{
    if (metric)
    {
        return [m_typeClass createRandomMetricForDay:date];
    }
    
    return [m_typeClass createRandomForDay:date];
}

-(void)addRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    HVItemCollection* items = [self createRandomForDay:start isMetric:metric];
    if ([NSArray isNilOrEmpty:items])
    {
        [HVUIAlert showInformationalMessage:@"Not Supported!"];
        return;
    }
    //
    // PUT IT INTO HEALTHVAULT
    //
    [[HVClient current].currentRecord putItems:items callback:^(HVTask *task)
     {
         //
         // Update the UI
         //
         if (![self putItemsCompleted:task forDate:start])
         {
             return;
         }
         //
         // Create another item, unless we've completed the requested data range
         //
         NSDate * nextDate = [self getNextDayAfter:start endDate:end];
         if (nextDate)
         {
             [self addRandomForDaysFrom:nextDate to:end isMetric:metric];
         }
         else
         {
             [m_statusLabel showStatus:@"Done"];
         }
     }];
}

-(BOOL)getItemsCompleted:(HVTask *)task
{
    @try
    {
        HVRETAIN(m_items, ((HVGetItemsTask *) task).itemsRetrieved);
        
        [m_statusLabel showStatus:@"%d items", m_items.count];
        
        [m_itemTable reloadData];
        
        return TRUE;
    }
    @catch (NSException *exception)
    {
        [HVUIAlert showInformationalMessage:exception.description];
        [m_statusLabel showStatus:@"Failed"];
    }
    
    return FALSE;
}

-(BOOL)putItemsCompleted:(HVTask *)task forDate:(NSDate *)date
{
    @try
    {
        [task checkSuccess];
        [m_statusLabel showStatus:@"%@ added", [date toString]];
        [self refreshView];
        
        return TRUE;
    }
    @catch (NSException *exception)
    {
        [HVUIAlert showInformationalMessage:exception.detailedDescription];
    }
    
    return FALSE;
}

-(BOOL)removeItemCompleted:(HVTask *)task
{
    @try
    {
        [task checkSuccess];
        [m_statusLabel showStatus:@"Done"];
        [self refreshView];
        
        return TRUE;
    }
    @catch (NSException *exception)
    {
        [HVUIAlert showInformationalMessage:exception.description];
        [m_statusLabel showStatus:@"Failed"];
    }
    
    return FALSE;
}

-(NSDate *)getNextDayAfter:(NSDate *)current endDate:(NSDate *)end
{
    if ([end timeIntervalSinceDate:current] > c_numSecondsInDay)  // 1 day
    {
        // Poor man's next day.. to be 100% accurate, you should use NSDateComponents
        return [NSDate dateWithTimeInterval:c_numSecondsInDay sinceDate:current];
    }
    
    return nil;
}

@end
