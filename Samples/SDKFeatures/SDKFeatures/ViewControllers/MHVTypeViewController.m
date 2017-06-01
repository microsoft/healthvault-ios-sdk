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
#import "MHVFeaturesConfiguration.h"

@interface MHVTypeViewController ()

@property (nonatomic, strong) MHVThingCollection *things;
@property (nonatomic, strong) Class typeClass;
@property (nonatomic, assign) BOOL useMetric;
@property (nonatomic, assign) NSInteger maxDaysOffsetRandomData;  // Create new data for a day with max this offset from today. (1)
@property (nonatomic, assign) BOOL createMultiple;                // Whether to create one or multiple random things

@property (nonatomic, strong) MHVThingDataTypedFeatures* moreFeatures;

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

- (IBAction)addThing:(id)sender
{
    [self addRandomData:self.useMetric];
}

- (IBAction)removeThing:(id)sender
{
    [self removeCurrentThing];
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

    self.thingTable.dataSource = self;

    //
    // When you click add, we add new things with random, but plausible data
    //
    // Data is created in the time range [TODAY, (Today - self.maxDaysOffsetRandoData)]
    // If self.createMultiple is TRUE, adds random data for EACH day in the range
    // Else only adds random data for the LAST day in the range.
    //
    // If self.maxDaysOffsetRandomData is 0, creates random data for TODAY
    //
    self.maxDaysOffsetRandomData = 0; // 90;
    self.createMultiple = FALSE;

    self.navigationItem.title = [self.typeClass XRootElement]; // Every MHVThingDataTyped implements this..
    if (!self.moreFeatures)
    {
        [self.moreActions setEnabled:FALSE];
    }
    
    [self getThingsFromHealthVault];
}

// -------------------------------------
//
// UITableViewDataSource
//
// -------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.things.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.thingTable dequeueReusableCellWithIdentifier:@"MHVThing"];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MHVThing"];
    }

    MHVThing *thing = self.things[indexPath.row];
    NSString *whenString = [thing.data.typed dateString];
    if ([NSString isNilOrEmpty:whenString])
    {
        whenString = [thing.effectiveDate toStringWithStyle:NSDateFormatterShortStyle];
    }

    cell.textLabel.text = whenString;

    NSString *details;
    if (self.useMetric)
    {
        details = [thing.data.typed detailsStringMetric];
    }
    else
    {
        details = [thing.data.typed detailsString];
    }

    cell.detailTextLabel.text = details;

    return cell;
}

- (void)refreshView
{
    [self getThingsFromHealthVault];
}

// -------------------------------------
//
// Methods
//
// -------------------------------------

- (MHVThing *)getSelectedThing
{
    if (!self.things)
    {
        return nil;
    }

    NSIndexPath *selectedRow = self.thingTable.indexPathForSelectedRow;
    if (!selectedRow ||
        selectedRow.row == NSNotFound ||
        selectedRow.row >= self.things.count)
    {
        return nil;
    }

    return self.things[selectedRow.row];
}

- (void)getThingsFromHealthVault
{
#if SHOULD_USE_LEGACY
    [self getThingsFromHealthVaultLegacy];
#else
    [self getThingsFromHealthVaultNew];
#endif
}

- (void)getThingsFromHealthVaultNew
{
    [self.statusLabel showBusy];
    
    // Get the current HealthVault service connection
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    MHVThingQuery *query = [[MHVThingQuery alloc] init];
    query.maxResults = 500;
    
    // Send request to get all things for the type class set for this view controller.
    [connection.thingClient getThingsForThingClass:self.typeClass
                                             query:query
                                          recordId:connection.personInfo.selectedRecordID
                                        completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
     {
         // Completion will be called on arbitrary thread.
         // Dispatch to main thread to refresh the table or show error
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
              if (!error)
              {
                  //No error, set things and reload the table
                  self.things = things;
                  
                  [self.thingTable reloadData];
                  
                  [self.statusLabel showStatus:[NSString stringWithFormat:@"Count: %li", things.count]];
              }
              else
              {
                  [self.statusLabel showStatus:@"Failed"];
              }
          }];
     }];
}

- (void)getThingsFromHealthVaultLegacy
{
    [self.statusLabel showBusy];
    
    [[MHVClient current].currentRecord getThingsForClass:self.typeClass callback:^(MHVTask *task)
    {        
        [self getThingsLegacyCompleted:task];
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

- (void)removeCurrentThing
{
    MHVThing *selectedThing = [self getSelectedThing];

    if (!selectedThing)
    {
        return;
    }

    [MHVUIAlert showYesNoPromptWithMessage:@"Permanently delete this thing?"
                                completion:^(BOOL selectedYes)
     {
         if (selectedYes)
         {
#if SHOULD_USE_LEGACY
             [self removeThingLegacy:selectedThing];
#else
             [self removeThingNew:selectedThing];
#endif
         }
     }];
}

- (void)removeThingLegacy:(MHVThing *)thing
{
    [[MHVClient current].currentRecord removeThingWithKey:thing.key callback:^(MHVTask *task)
    {
        [self removeThingLegacyCompleted:task];
    }];
}

- (void)removeThingNew:(MHVThing *)thing
{
    // Get the current HealthVault service connection
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    // Send request to remove the selected thing
    [connection.thingClient removeThing:thing
                               recordId:connection.personInfo.selectedRecordID
                             completion:^(NSError * _Nullable error)
     {
         // Completion will be called on arbitrary thread.
         // Dispatch to main thread to refresh the table or show error
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
              if (error)
              {
                  [MHVUIAlert showInformationalMessage:error.description];
                  [self.statusLabel showStatus:@"Failed"];
              }
              else
              {
                  [self.statusLabel showStatus:@"Done"];
                  [self refreshView];
              }
          }];
     }];
}

- (void)showActivityAndStatus:(NSString *)status
{
    [self.statusLabel showActivity];
    self.statusLabel.text = status;
}

- (void)clearStatus
{
    // [self.statusLabel clearStatus];
}

- (MHVThingCollection *)createRandomForDay:(NSDate *)date isMetric:(BOOL)metric
{
    if (metric)
    {
        return [self.typeClass createRandomMetricForDay:date];
    }

    return [self.typeClass createRandomForDay:date];
}

- (void)addRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
#if SHOULD_USE_LEGACY
    [self addLegacyRandomForDaysFrom:start to:end isMetric:metric];
#else
    [self addNewRandomForDaysFrom:start to:end isMetric:metric];
#endif

}

- (void)addLegacyRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    MHVThingCollection *things = [self createRandomForDay:start isMetric:metric];

    if (things.count < 1)
    {
        [MHVUIAlert showInformationalMessage:@"Not Supported!"];
        return;
    }

    //
    // PUT IT INTO HEALTHVAULT
    //
    [[MHVClient current].currentRecord putThings:things callback:^(MHVTask *task)
    {
        //
        // Update the UI
        //
        if (![self putThingsLegacyCompleted:task forDate:start])
        {
            return;
        }

        //
        // Create another thing, unless we've completed the requested data range
        //
        NSDate *nextDate = [self getNextDayAfter:start endDate:end];
        if (nextDate)
        {
            [self addLegacyRandomForDaysFrom:nextDate to:end isMetric:metric];
        }
        else
        {
            [self.statusLabel showStatus:@"Done"];
        }
    }];
}

- (void)addNewRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    MHVThingCollection *things = [self createRandomForDay:start isMetric:metric];
    
    if (things.count < 1)
    {
        [MHVUIAlert showInformationalMessage:@"Not Supported!"];
        return;
    }
    
    // Get the current HealthVault service connection
    id<MHVSodaConnectionProtocol> connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    // Send request to create new thing objects
    [connection.thingClient createNewThings:things
                                   recordId:connection.personInfo.selectedRecordID
                                 completion:^(NSError * _Nullable error)
     {
         // Completion will be called on arbitrary thread.
         // Dispatch to main thread to refresh the table or show error
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
              if (error)
              {
                  [MHVUIAlert showInformationalMessage:error.description];
                  [self.statusLabel showStatus:@"Failed"];
              }
              else
              {
                  NSDate *nextDate = [self getNextDayAfter:start endDate:end];
                  if (nextDate)
                  {
                      [self addNewRandomForDaysFrom:nextDate to:end isMetric:metric];
                  }
                  else
                  {
                      [self.statusLabel showStatus:@"Done"];
                      [self refreshView];
                  }
              }
          }];
     }];
}

- (BOOL)getThingsLegacyCompleted:(MHVTask *)task
{
    @try
    {
        self.things = ((MHVGetThingsTask *)task).thingsRetrieved;

        [self.statusLabel showStatus:[NSString stringWithFormat:@"%li things", (long)self.things.count]];

        [self.thingTable reloadData];

        return TRUE;
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.description];
        [self.statusLabel showStatus:@"Failed"];
    }

    return FALSE;
}

- (BOOL)putThingsLegacyCompleted:(MHVTask *)task forDate:(NSDate *)date
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

- (BOOL)removeThingLegacyCompleted:(MHVTask *)task
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
