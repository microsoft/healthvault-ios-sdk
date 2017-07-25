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

@property (nonatomic, strong) IBOutlet MHVStatusLabel *statusLabel;
@property (nonatomic, strong) IBOutlet UITableView *thingTable;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *moreActions;

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;
@property (nonatomic, strong) NSArray<MHVThing *> *things;
@property (nonatomic, strong) Class typeClass;
@property (nonatomic, assign) BOOL useMetric;
@property (nonatomic, assign) NSInteger maxDaysOffsetRandomData;  // Create new data for a day with max this offset from today. (1)
@property (nonatomic, assign) BOOL createMultiple;                // Whether to create one or multiple random things
@property (nonatomic, assign) BOOL useCache;

@property (nonatomic, strong) MHVThingDataTypedFeatures* moreFeatures;
@property (nonatomic, strong) NSObject *lockObject;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSInteger totalThingsCount;

@end

static const NSInteger c_numSecondsInDay = 86400;
static const NSUInteger c_thingLimit = 50;

@implementation MHVTypeViewController

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    if (self)
    {
        _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
        
        _typeClass = typeClass;
        _useMetric = metric;
        _useCache = YES;
        _things = [NSArray new];
        _lockObject = [NSObject new];
        _totalThingsCount = -1;
        
        _moreFeatures = [typeClass moreFeatures];
        if (_moreFeatures)
        {
            _moreFeatures.controller = self;
            _moreFeatures.typeClass = _typeClass;
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
        [self.moreFeatures showWithViewController:self];
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
    
    [self refreshThingsInRange:NSMakeRange(0, c_thingLimit)];
}

#pragma mark - UITableViewDataSource

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
    if (!whenString || [whenString isEqualToString:@""])
    {
        NSDateFormatter *dateFormatter =[NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        whenString = [dateFormatter stringFromDate:thing.effectiveDate];
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
    
    // If Thing has a blob, include the size
    if (thing.blobs.getDefaultBlob)
    {
        details = [NSString stringWithFormat:@"%@ - Size %0.2f MB", details, thing.blobs.getDefaultBlob.length / 1048576.0];
    }
    
    cell.detailTextLabel.text = details;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat loadPosition = scrollView.contentOffset.y + scrollView.frame.size.height * 2;
    
    if (loadPosition >= scrollView.contentSize.height)
    {
        [self refreshThingsInRange:NSMakeRange(self.things.count, c_thingLimit)];
    }
}

#pragma mark - Methods


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

- (void)refreshAll
{
    @synchronized (self.lockObject)
    {
        self.things = @[];
        [self.thingTable reloadData];
        self.totalThingsCount = -1;
    }
    
    [self refreshThingsInRange:NSMakeRange(0, c_thingLimit)];
}

- (void)refreshThingsInRange:(NSRange)range;
{
    @synchronized (self.lockObject)
    {
        if (self.isLoading || self.things.count == self.totalThingsCount)
        {
            return;
        }
        
        self.isLoading = YES;
    }
    
    [self.statusLabel showBusy];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    NSDate *startDate = [NSDate date];
    
    __block MHVThingQuery *query = [[MHVThingQuery alloc] init];
    query.shouldUseCachedResults = self.useCache;
    query.limit = range.length;
    query.offset = range.location;
    
    //Include Blob metadata, so can show size for Files
    if (self.typeClass == [MHVFile class])
    {
        query.view.sections |= MHVThingSection_Blobs;
    }
    
    // Send request to get all things for the type class set for this view controller.
    [self.connection.thingClient getThingsForThingClass:self.typeClass
                                                  query:query
                                             recordId:self.connection.personInfo.selectedRecordID
                                             completion:^(MHVThingQueryResult * _Nullable result, NSError * _Nullable error)
     {
         // Completion will be called on arbitrary thread.
         // Dispatch to main thread to refresh the table or show error
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
          {
              if (!error)
              {
                  @synchronized (self.lockObject)
                  {
                      if (result.things.count > 0)
                      {
                          [self addThingsFromArray:result.things
                                   atStartingIndex:range.location];
                      }
                  }
                  
                  [self.thingTable reloadData];
                  
                  [self.statusLabel showStatus:[NSString stringWithFormat:@"Loaded %li of %li", self.things.count, result.count]];

                  NSDate *endDate = [NSDate date];
                  
                  // Show duration and data source as right button item.
                  NSString *message = [NSString stringWithFormat:@"%@%0.3f", result.isCachedResult ? @"📱" : @"☁️", [endDate timeIntervalSinceDate:startDate]];
                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:message
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(reloadData:)];
              }
              else
              {
                  self.navigationItem.rightBarButtonItem = nil;

                  [self.statusLabel showStatus:@"Failed"];
              }
              
              @synchronized (self.lockObject)
              {
                  self.totalThingsCount = result.count;
                  self.isLoading = NO;
              }
          }];
     }];
}

- (void)reloadData:(id)sender
{
    self.useCache = !self.useCache;
    
    [self refreshAll];
}

- (void)addThingsFromArray:(NSArray<MHVThing *> *)array atStartingIndex:(NSUInteger)startingIndex
{
    if (!array || array.count == 0)
    {
        return;
    }
    
    if (startingIndex > self.things.count)
    {
        startingIndex = self.things.count;
    }
    
    NSMutableArray *thingsCopy = [self.things mutableCopy];
    
    for (int i = 0; i < array.count; i++)
    {
        id obj = array[i];
        
        [thingsCopy insertObject:obj atIndex:startingIndex + i];
    }
    
    self.things = thingsCopy;
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
    __block MHVThing *selectedThing = [self getSelectedThing];
    
    if (!selectedThing)
    {
        return;
    }
    
    [MHVUIAlert showYesNoPromptWithMessage:@"Permanently delete this thing?"
                                completion:^(BOOL selectedYes)
     {
         if (selectedYes)
         {
             // Send request to remove the selected thing
             [self.connection.thingClient removeThing:selectedThing
                                             recordId:self.connection.personInfo.selectedRecordID
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
                           
                           NSUInteger index = [self.things indexOfThingID:selectedThing.thingID];
        
                           @synchronized (self.lockObject)
                           {
                               NSMutableArray *thingsCopy = [self.things mutableCopy];
                               [thingsCopy removeObject:selectedThing];
                               self.things = thingsCopy;
                           }
                           
                           [self refreshThingsInRange:NSMakeRange(index, 0)];
                       }
                   }];
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

- (NSArray<MHVThing *> *)createRandomForDay:(NSDate *)date isMetric:(BOOL)metric
{
    if (metric)
    {
        return [self.typeClass createRandomMetricForDay:date];
    }
    
    return [self.typeClass createRandomForDay:date];
}

- (void)addRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    __block NSArray<MHVThing *> *things = [self createRandomForDay:start isMetric:metric];
    
    if (things.count < 1)
    {
        [MHVUIAlert showInformationalMessage:@"Not Supported!"];
        return;
    }
    
    // Send request to create new thing objects
    [self.connection.thingClient createNewThings:things
                                        recordId:self.connection.personInfo.selectedRecordID
                                      completion:^(NSArray<MHVThingKey *> *_Nullable thingKeys, NSError * _Nullable error)
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
                      [self addRandomForDaysFrom:nextDate to:end isMetric:metric];
                  }
                  else
                  {
                      [self.statusLabel showStatus:@"Done"];
                      
                      self.totalThingsCount += things.count;
                      [self refreshThingsInRange:NSMakeRange(0, things.count)];
                  }
              }
          }];
     }];
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
