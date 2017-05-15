//
//  MHVTypeViewController.m
//  SDKFeatures
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

@interface MHVTypeViewController (MHVPrivate)

-(MHVThingCollection *) createRandomForDay:(NSDate *) date isMetric:(BOOL) metric;

//
// Creates multiple random things.. one each for each day in the give range
//
-(void) addRandomForDaysFrom:(NSDate *) start to:(NSDate *) end isMetric:(BOOL) metric;


//
// Completion methods
//
-(BOOL) getThingsCompleted:(MHVTask *) task;
-(BOOL) putThingsCompleted:(MHVTask *) task forDate:(NSDate *) date;
-(BOOL) removeThingCompleted:(MHVTask *) task;

-(NSDate *) getNextDayAfter:(NSDate *) current endDate:(NSDate *) end;

@end

static const NSInteger c_numSecondsInDay = 86400;

@implementation MHVTypeViewController

@synthesize things = m_things;
@synthesize thingTable = m_thingTable;
@synthesize statusLabel = m_statusLabel;
@synthesize moreActions = m_moreActions;

-(id)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_typeClass = typeClass;
    m_useMetric = metric;
    m_moreFeatures = [typeClass moreFeatures];
    if (m_moreFeatures)
    {
        m_moreFeatures.controller = self;
    }
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void)dealloc
{
    m_thingTable.dataSource = nil;
    
    
}


- (IBAction)addThing:(id)sender
{
    [self addRandomData:m_useMetric];
}

- (IBAction)removeThing:(id)sender
{
    [self removeCurrentThing];
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

    m_thingTable.dataSource = self;
    
    //
    // When you click add, we add new things with random, but plausible data
    //
    // Data is created in the time range [TODAY, (Today - m_maxDaysOffsetRandoData)]
    // If m_createMultiple is TRUE, adds random data for EACH day in the range
    // Else only adds random data for the LAST day in the range.
    //
    // If m_maxDaysOffsetRandomData is 0, creates random data for TODAY
    //
    m_maxDaysOffsetRandomData = 0; // 90;
    m_createMultiple = FALSE;  
    
    self.navigationItem.title = [m_typeClass XRootElement]; // Every MHVThingDataTyped implements this..
    if (!m_moreFeatures)
    {
        [m_moreActions setEnabled:FALSE];
    }
    
    [self getThingsFromHealthVault];
}

//-------------------------------------
//
// UITableViewDataSource
//
//-------------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_things.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [m_thingTable dequeueReusableCellWithIdentifier:@"MHVThing"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MHVThing"];
    }
    
    MHVThing* thing = m_things[indexPath.row];
    NSString* whenString = [thing.data.typed dateString];
    if ([NSString isNilOrEmpty:whenString])
    {
        whenString = [thing.effectiveDate toStringWithStyle:NSDateFormatterShortStyle];
    }
    cell.textLabel.text = whenString;
    
    NSString* details;
    if (m_useMetric)
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

-(void)refreshView
{
    [self getThingsFromHealthVault];
}

//-------------------------------------
//
// Methods
//
//-------------------------------------

-(MHVThing *)getSelectedThing
{
    if (!m_things)
    {
        return nil;
    }
    
    NSIndexPath* selectedRow = m_thingTable.indexPathForSelectedRow;
    if (!selectedRow ||
        selectedRow.row == NSNotFound ||
        selectedRow.row >= m_things.count)
    {
        return nil;
    }
    
    return m_things[selectedRow.row];
}

-(void)getThingsFromHealthVault
{
    [m_statusLabel showBusy];
    
    [[MHVClient current].currentRecord getThingsForClass:m_typeClass callback:^(MHVTask *task) {
        
        [self getThingsCompleted:task];
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

-(void)removeCurrentThing
{
    MHVThing* selectedThing = [self getSelectedThing];
    if (!selectedThing)
    {
        return;
    }
    
    [MHVUIAlert showYesNoPromptWithMessage:@"Permanently delete this thing?"
                                completion:^(BOOL selectedYes)
    {
        if (selectedYes)
        {
            //
            // REMOVE from HealthVault
            //
            [[MHVClient current].currentRecord removeThingWithKey:selectedThing.key callback:^(MHVTask *task) {
                
                [self removeThingCompleted:task];
            }];
        }
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

@implementation MHVTypeViewController (MHVPrivate)

-(MHVThingCollection *) createRandomForDay:(NSDate *) date isMetric:(BOOL) metric
{
    if (metric)
    {
        return [m_typeClass createRandomMetricForDay:date];
    }
    
    return [m_typeClass createRandomForDay:date];
}

-(void)addRandomForDaysFrom:(NSDate *)start to:(NSDate *)end isMetric:(BOOL)metric
{
    MHVThingCollection* things = [self createRandomForDay:start isMetric:metric];
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
         if (![self putThingsCompleted:task forDate:start])
         {
             return;
         }
         //
         // Create another thing, unless we've completed the requested data range
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

-(BOOL)getThingsCompleted:(MHVTask *)task
{
    @try
    {
        m_things = ((MHVGetThingsTask *) task).thingsRetrieved;
        
        [m_statusLabel showStatus:[NSString stringWithFormat:@"%li things", (long)m_things.count]];
        
        [m_thingTable reloadData];
        
        return TRUE;
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.description];
        [m_statusLabel showStatus:@"Failed"];
    }
    
    return FALSE;
}

-(BOOL)putThingsCompleted:(MHVTask *)task forDate:(NSDate *)date
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
        [MHVUIAlert showInformationalMessage:exception.detailedDescription];
    }
    
    return FALSE;
}

-(BOOL)removeThingCompleted:(MHVTask *)task
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
        [MHVUIAlert showInformationalMessage:exception.description];
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
