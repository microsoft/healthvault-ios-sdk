//
// MHVTypeViewController.m
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

#import "MHVTypeViewController.h"

@interface MHVTypeViewController ()

@property (nonatomic, strong) MHVItemCollection *items;

@property (nonatomic, strong) IBOutlet MHVStatusLabel *statusLabel;
@property (nonatomic, strong) IBOutlet UITableView *itemTable;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *moreActions;

@property (nonatomic, strong) Class typeClass;
@property (nonatomic, strong) MHVItemDataTypedFeatures *moreFeatures;

@property (nonatomic, assign) BOOL useMetric;
@property (nonatomic, assign) NSInteger maxDaysOffsetRandomData; // Create new data for a day with max this offset from today. (1)
@property (nonatomic, assign) BOOL createMultiple;               // Whether to create one or multiple random items when the user clicks Add. (False)

@end

static const NSInteger c_numSecondsInDay = 86400;

@implementation MHVTypeViewController

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    if (self)
    {
        _typeClass = typeClass;
        _useMetric = metric;
        _moreFeatures = [typeClass moreFeatures];
        if (_moreFeatures)
        {
            _moreFeatures.controller = self;
        }
    }
    return self;
}

- (IBAction)addItem:(id)sender
{
    [self addRandomData:self.useMetric];
}

- (IBAction)removeItem:(id)sender
{
    [self removeCurrentItem];
}

- (IBAction)moreClicked:(id)sender
{
    if (self.moreFeatures)
    {
        [self.moreFeatures showFrom:self.moreActions];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.typeClass)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
        return;
    }

    self.itemTable.dataSource = self;

    //
    // When you click add, we add new items with random, but plausible data
    //
    // Data is created in the time range [TODAY, (Today - maxDaysOffsetRandoData)]
    // If createMultiple is TRUE, adds random data for EACH day in the range
    // Else only adds random data for the LAST day in the range.
    //
    // If maxDaysOffsetRandomData is 0, creates random data for TODAY
    //
    self.maxDaysOffsetRandomData = 0; // 90;
    self.createMultiple = FALSE;

    self.navigationItem.title = [self.typeClass XRootElement]; // Every MHVItemDataTyped implements this..
    if (!self.moreFeatures)
    {
        [self.moreActions setEnabled:FALSE];
    }

    [self getItemsFromHealthVault];
}

// -------------------------------------
//
// UITableViewDataSource
//
// -------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.itemTable dequeueReusableCellWithIdentifier:@"MHVItem"];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MHVItem"];
    }
    
    MHVItem* item = self.items[indexPath.row];
    NSString* whenString = [item.data.typed dateString];
    if ([NSString isNilOrEmpty:whenString])
    {
        whenString = [item.effectiveDate toStringWithStyle:NSDateFormatterShortStyle];
    }

    cell.textLabel.text = whenString;

    NSString *details;
    if (self.useMetric)
    {
        details = [item.data.typed detailsStringMetric];
    }
    else
    {
        details = [item.data.typed detailsString];
    }

    cell.detailTextLabel.text = details;

    return cell;
}

- (void)refreshView
{
    [self getItemsFromHealthVault];
}

// -------------------------------------
//
// Methods
//
// -------------------------------------

- (MHVItem *)getSelectedItem
{
    if (!self.items)
    {
        return nil;
    }

    NSIndexPath *selectedRow = self.itemTable.indexPathForSelectedRow;
    if (!selectedRow ||
        selectedRow.row == NSNotFound ||
        selectedRow.row >= self.items.count)
    {
        return nil;
    }
    
    return self.items[selectedRow.row];
}

- (void)getItemsFromHealthVault
{
    [self.statusLabel showBusy];

    [[MHVClient current].currentRecord getItemsForClass:self.typeClass callback:^(MHVTask *task) {
        [self getItemsCompleted:task];
    }];
}

- (void)addRandomData:(BOOL)isMetric
{
    NSDate *end = [NSDate date];
    NSTimeInterval interval = -(c_numSecondsInDay * self.maxDaysOffsetRandomData);
    NSDate *date = [end dateByAddingTimeInterval:interval];

    if (!self.createMultiple)
    {
        end = date;
    }

    [self addRandomForDaysFrom:date to:end isMetric:isMetric];
}

- (void)removeCurrentItem
{
    MHVItem *selectedItem = [self getSelectedItem];

    if (!selectedItem)
    {
        return;
    }

    [MHVUIAlert showYesNoPromptWithMessage:@"Permanently delete this item?"
     completion:^(BOOL selectedYes)
    {
        if (selectedYes)
        {
            //
            // REMOVE from HealthVault
            //
            [[MHVClient current].currentRecord removeItemWithKey:selectedItem.key callback:^(MHVTask *task) {
                [self removeItemCompleted:task];
            }];
        }
    }];
}

- (void)showActivityAndStatus:(NSString *)status
{
    [self.statusLabel showActivity];
    self.statusLabel.text = status;
}

- (void)clearStatus
{
    [self.statusLabel clearStatus];
}

#pragma mark - Internal methods

- (MHVItemCollection *)createRandomForDay:(NSDate *)date isMetric:(BOOL)metric
{
    if (metric)
    {
        return [self.typeClass createRandomMetricForDay:date];
    }

    return [self.typeClass createRandomForDay:date];
}

- (void)addRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    MHVItemCollection *items = [self createRandomForDay:start isMetric:metric];

    if (items.count < 1)
    {
        [MHVUIAlert showInformationalMessage:@"Not Supported!"];
        return;
    }

    //
    // PUT IT INTO HEALTHVAULT
    //
    [[MHVClient current].currentRecord putItems:items callback:^(MHVTask *task)
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
        NSDate *nextDate = [self getNextDayAfter:start endDate:end];
        if (nextDate)
        {
            [self addRandomForDaysFrom:nextDate to:end isMetric:metric];
        }
        else
        {
            [self.statusLabel showStatus:@"Done"];
        }
    }];
}

- (BOOL)getItemsCompleted:(MHVTask *)task
{
    @try
    {
        self.items = ((MHVGetItemsTask *)task).itemsRetrieved;

        [self.statusLabel showStatus:[NSString stringWithFormat:@"%li items", (long)self.items.count]];

        [self.itemTable reloadData];

        return TRUE;
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.description];
        [self.statusLabel showStatus:@"Failed"];
    }

    return FALSE;
}

- (BOOL)putItemsCompleted:(MHVTask *)task forDate:(NSDate *)date
{
    @try
    {
        [task checkSuccess];
        [self.statusLabel showStatus:@"%@ added", [date toString]];
        [self refreshView];

        return TRUE;
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.detailedDescription];
    }

    return FALSE;
}

- (BOOL)removeItemCompleted:(MHVTask *)task
{
    @try
    {
        [task checkSuccess];
        [self.statusLabel showStatus:@"Done"];
        [self refreshView];

        return TRUE;
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.description];
        [self.statusLabel showStatus:@"Failed"];
    }

    return FALSE;
}

- (NSDate *)getNextDayAfter:(NSDate *)current endDate:(NSDate *)end
{
    if ([end timeIntervalSinceDate:current] > c_numSecondsInDay)  // 1 day
    {
        // Poor man's next day.. to be 100% accurate, you should use NSDateComponents
        return [NSDate dateWithTimeInterval:c_numSecondsInDay sinceDate:current];
    }

    return nil;
}

@end
