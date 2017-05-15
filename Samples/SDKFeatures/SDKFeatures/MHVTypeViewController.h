//
//  MHVTypeViewController.h
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

#import <UIKit/UIKit.h>
#import "MHVLib.h"
#import "MHVThingDataTypedFactory.h"
#import "MHVStatusLabel.h"
#import "MHVThingDataTypedFeatures.h"
#import "MHVUIAlert.h"

@interface MHVTypeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    Class m_typeClass;
    MHVThingCollection* m_things;
    MHVThingDataTypedFeatures* m_moreFeatures;
    
    MHVStatusLabel* m_statusLabel;
    UITableView* m_thingTable;
    UIBarButtonItem* m_moreActions;
    
    BOOL m_useMetric;
    NSInteger m_maxDaysOffsetRandomData;  // Create new data for a day with max this offset from today. (1)
    BOOL m_createMultiple;                // Whether to create one or multiple random things when the user clicks Add. (False)
}

@property (readonly, nonatomic, strong) MHVThingCollection* things;

@property (readwrite, nonatomic, strong) IBOutlet MHVStatusLabel* statusLabel;
@property (readwrite, nonatomic, strong) IBOutlet UITableView *thingTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moreActions;

-(id) initWithTypeClass:(Class) typeClass useMetric:(BOOL) metric;

- (IBAction)addThing:(id)sender;
- (IBAction)removeThing:(id)sender;
- (IBAction)moreClicked:(id)sender;

//
// Returns the thing in the table that is currently selected
//
-(MHVThing *) getSelectedThing;

//
// Add random data for ONE DAY for the type currently selected by the user
// For types like DietaryIntake, this may create more than one thing
// The data has a date within m_maxDaysOffsetRandomData from the current date
//
-(void) addRandomData:(BOOL) isMetric;
-(void) removeCurrentThing;

-(void) refreshView;
-(void) getThingsFromHealthVault;
-(void) showActivityAndStatus:(NSString *) status;
-(void) clearStatus;

@end
