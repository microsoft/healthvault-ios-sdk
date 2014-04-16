//
//  HVUITypeViewDataSource.m
//  HVUISampleLib
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
//
#import "HVUITypeViewDataSource.h"

@interface HVUITypeViewDataSource ()

//
// HVTypeViews can be persisted. This saves the updated view to disk
//
-(void) saveTypeView;
//
// Reload the table view
//
-(void) reloadTable;
//
// Locates the table rows in the items for
-(void) reloadItems:(HVItemCollection *)items;

@end

@implementation HVUITypeViewDataSource

-(UITableView *)table
{
    return m_table;
}

-(void)setTable:(UITableView *)table
{
    if (m_table)
    {
        m_table.dataSource = nil;
        m_typeView.delegate = nil;
    }
    
    if (table)
    {
        table.dataSource = self;
        m_typeView.delegate = self;
    }
    
    m_table = table;
}

@synthesize typeView = m_typeView;

-(id)initWithRecord:(HVRecordReference *)record andTypeID:(NSString *)typeID
{
    HVTypeView* typeView = [HVTypeView getViewForTypeID:typeID inRecord:record];
    return [self initWithTypeView:typeView];
}

-(id)initWithTypeView:(HVTypeView *)typeView
{
    self = [super init];
    if (self)
    {
        m_typeView = typeView;
    }
    
    return self;
    
}

-(void)saveTypeView
{
    [m_typeView save];
}

-(void)reloadTable
{
    if (m_table)
    {
        [m_table reloadData];
    }
}

-(void) reloadItems:(HVItemCollection *)items
{
    if ([NSArray isNilOrEmpty:items] || !m_table)
    {
        return;
    }
    
    NSMutableArray* tableRowsToReload = [[NSMutableArray alloc] init];
    for (HVItem* item in items)
    {
        NSUInteger index = [m_typeView indexOfItemID:item.itemID];
        if (index != NSNotFound)
        {
            [tableRowsToReload addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
    if (![NSArray isNilOrEmpty:tableRowsToReload])
    {
        [m_table reloadRowsAtIndexPaths:tableRowsToReload withRowAnimation:UITableViewRowAnimationLeft];
    }
}

//------------------------------
//
// UITableViewDelegate
//
//------------------------------
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d items [Synced: %@]", m_typeView.count, [m_typeView.lastUpdateDate toStringWithFormat:@"MM-dd-yyyy HH:mm:ss"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_typeView.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self createNewCellForTable:tableView];
    
    HVItem* item = nil;
    NSUInteger row = indexPath.row;
    if (row < m_typeView.count)
    {
        item = [m_typeView getItemAtIndex:row];
    }
    //
    // item is NULL when the item isn't available in the local store yet.
    // HVTypeView will download the item in the background.
    // It will fire the delegate (HVTypeViewDelegate) when the item is available
    //
    if (item)
    {
        [self displayItem:item inCell:cell];
    }
    else
    {
        [self displayItemAsPendingInCell:cell];
    }
    
    return cell;
}

//------------------------------
//
// HVTypeViewDelegate
//
//------------------------------
-(void)itemsAvailable:(HVItemCollection *)items inView:(HVTypeView *)view viewChanged:(BOOL)viewChanged
{
    if (viewChanged)
    {
        //
        // Persist changes
        //
        [self save];
        //
        // Collection is now different. Reload the table...
        //
        [self reload];
    }
    else
    {
        //
        // Reload specific items in line
        //
        [self reloadItems:items];
    }
}

-(void)keysNotAvailable:(NSArray *)keys inView:(HVTypeView *)view
{
    //
    // The view has changed. Persis it.
    //
    [self save];
    //
    // Refresh the table...
    //
    [self reload];
}

-(void)synchronizationCompletedInView:(HVTypeView *)view
{
    //
    // Persist the updated view
    //
    [self save];
    //
    // Refresh view
    //
    [self reload];
}

-(void)synchronizationFailedInView:(HVTypeView *)view withError:(id)ex
{
    [HVUIAlert showInformationalMessage:@"Synchronization failed"];
}


//------------------------------
//
// Overridable
//
//------------------------------
-(UITableViewCell *)createNewCellForTable:(UITableView *)table
{
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"];
    }
    return cell;
}

-(void)displayItem:(HVItem *)item inCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [self effectiveDateStringForItem:item];
    cell.detailTextLabel.text = [self descriptionStringForItem:item];
}

-(void)displayItemAsPendingInCell:(UITableViewCell *)cell
{
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = @"Downloading...";
}

-(NSString *)effectiveDateStringForItem:(HVItem *)item
{
    return [item.effectiveDate toStringWithStyle:NSDateFormatterShortStyle];
}

-(NSString *)descriptionStringForItem:(HVItem *)item
{
    return item.data.typed.description;
}

@end
