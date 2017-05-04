//
//  MHVMasterViewController.h
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

#import <UIKit/UIKit.h>
//
// Include HealthVault Library
//
#import "MHVLib.h"

@interface MHVMasterViewController : UIViewController <UITableViewDataSource>
{
    //
    // Collection of items you retrieved from HealthVault
    //
    MHVItemCollection* m_items;  
}
//
// Table we will display HV items in
//
@property (retain, nonatomic) IBOutlet UITableView *itemsTable;

//
// Application startup
//
-(void) startApp;
-(void) startupSuccess;
-(void) startupFailed;
//
// Asynchronously get items from the user's HealthVault record
//
-(void) getWeightsFromHealthVault;
-(void) getWeightsForLastNDays:(int) numDays;
//
// Asynchronously write items to the User's HealthVault record
//
-(void) putWeightInHealthVault:(MHVItem *) weight;
//
// Asynchronously remove items from the User's HealthVault record
//
-(void) removeWeightFromHealthVault:(MHVItemKey *) itemKey;
//
// Create a new weight measurement
//
-(MHVItem *) newWeight;
-(void) changeWeight:(MHVItem *) item;
//
// Displaying Weights in TableView
//
-(void) refreshView;
-(void) displayWeight:(MHVWeight *) weight inCell:(UITableViewCell *) cell;
-(UITableViewCell *) getCellFor:(UITableView *) table;
//
// Toolbar button handlers
//
- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)addButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)updateButtonClicked:(id)sender;
- (IBAction)disconnectClicked:(id)sender;

@end
