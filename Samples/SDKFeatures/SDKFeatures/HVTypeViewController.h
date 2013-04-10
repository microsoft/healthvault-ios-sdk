//
//  HVTypeViewController.h
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

#import <UIKit/UIKit.h>
#import "HVLib.h"
#import "HVItemDataTypedFactory.h"

@interface HVTypeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    Class m_typeClass;
    HVItemCollection* m_items;
    
    UILabel* m_statusLabel;
    UITableView* m_itemTable;
    
    BOOL m_useMetric;
    NSInteger m_maxDaysOffsetRandomData;  // Create new data for a day with max this offset from today. (1)
    BOOL m_createMultiple;                // Whether to create one or multiple random items when the user clicks Add. (False)
}

@property (readwrite, nonatomic, retain) IBOutlet UILabel* statusLabel;
@property (readwrite, nonatomic, retain) IBOutlet UITableView *itemTable;

-(id) initWithTypeClass:(Class) typeClass useMetric:(BOOL) metric;

- (IBAction)addItem:(id)sender;
- (IBAction)removeItem:(id)sender;

-(HVItem *) getSelectedItem;

//
// Add random data for ONE DAY for the type currently selected by the user
// For types like DietaryIntake, this may create more than one item
// The data has a date within m_maxDaysOffsetRandomData from the current date
//
-(void) addRandomData:(BOOL) isMetric;
-(void) removeCurrentItem;

-(void) refreshView;
-(void) getItemsFromHealthVault;

@end
