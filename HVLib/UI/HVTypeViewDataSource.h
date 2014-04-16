//
//  HVTypeViewDataSource.h
//  HVLib
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

#import <UIKit/UIKit.h>
#import "HVTypeView.h"

@interface HVItemTableViewDataSource : NSObject<UITableViewDataSource>
{
@private
    id<HVTypeView> m_view;
    UITableView* m_table;  // Weak ref
    UITableViewCellStyle m_cellStyle;
    UITableViewRowAnimation m_rowAnimation;
}

@property (readwrite, nonatomic, assign) UITableView* table; // Nil this out when you are done with it
@property (readwrite, nonatomic) UITableViewCellStyle cellStyle;
@property (readwrite, nonatomic) UITableViewRowAnimation rowAnimation;

-(id) initForTable:(UITableView *) table andView:(id<HVTypeView>) view;

-(void)reloadAllItems;
-(void) reloadItems:(HVItemCollection *)items;
-(void) reloadItem:(HVItem *) item;
//
// Convenience methods that let you manipulate the table
//
-(void) insertTableRowAtIndex:(NSUInteger) row;
-(void) updateTableForNewItem:(HVItem *) item;
-(void) removeTableRowAtIndex:(NSUInteger) row;

//---------------------
//
// Override these methods to customize display
//
//----------------------
-(UITableViewCell *) tableView:(UITableView *) table cellForRow:(NSUInteger) row withItem:(HVItem *) item;
-(UITableViewCell *) tableView:(UITableView *)table cellForPendingRow:(NSUInteger)row;

//
// Override these if you want to use default table view cells
//
-(UITableViewCell *)createNewCellForTable:(UITableView *)table;
-(NSString *)effectiveDateStringForItem:(HVItem *)item;
-(NSString *)descriptionStringForItem:(HVItem *)item;

@end

//
// Data source to display and manage an HVTypeView via a UITableView
// 
@interface HVTypeViewDataSource : HVItemTableViewDataSource<HVTypeViewDelegate>
{
@private
    HVTypeView* m_typeView;
}

@property (readonly, nonatomic) HVTypeView* typeView;

-(id) initForTable:(UITableView *) table withRecord:(HVRecordReference *) record andTypeID:(NSString *) typeID;
-(id) initForTable:(UITableView *) table withTypeView:(HVTypeView *) typeView;

//-----------
//
// Methods
//
//------------
-(void) saveTypeView;

@end
