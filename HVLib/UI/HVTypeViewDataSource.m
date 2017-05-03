//
//  HVTypeViewDataSource.m
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

#import "HVCommon.h"
#import "HVTypeViewDataSource.h"

@interface HVItemTableViewDataSource (HVPrivate)

-(NSMutableArray *)indexPathArrayForRow:(NSUInteger)row;

@end

@implementation HVItemTableViewDataSource

-(UITableView *)table
{
    return m_table;
}

-(void)setTable:(UITableView *)table
{
    if (m_table)
    {
        m_table.dataSource = nil;
    }
    
    if (table)
    {
        table.dataSource = self;
    }
    
    m_table = table; // Weak ref
}

@synthesize cellStyle = m_cellStyle;
@synthesize rowAnimation = m_rowAnimation;

-(id)init
{
    return [self initForTable:nil andView:nil];
}

-(id)initForTable:(UITableView *)table andView:(id<HVTypeView>)view
{
    HVCHECK_NOTNULL(table);
    HVCHECK_NOTNULL(view);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_view = [view retain];
    self.table = table;
    
    m_rowAnimation = UITableViewRowAnimationAutomatic;
    m_cellStyle = UITableViewCellStyleValue1;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_view release];
    // m_table is a weak ref
    
    [super dealloc];
}

-(void)reloadAllItems
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
        NSUInteger index = [m_view indexOfItemID:item.itemID];
        if (index != NSNotFound)
        {
            [tableRowsToReload addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
    if (![NSArray isNilOrEmpty:tableRowsToReload])
    {
        [m_table reloadRowsAtIndexPaths:tableRowsToReload withRowAnimation:m_rowAnimation];
    }
    
    [tableRowsToReload release];
}

-(void)reloadItem:(HVItem *)item
{
    if (!item || !m_table)
    {
        return;
    }
    
    NSUInteger index = [m_view indexOfItemID:item.itemID];
    if (index != NSNotFound)
    {
        [m_table reloadRowsAtIndexPaths:[self indexPathArrayForRow:index] withRowAnimation:m_rowAnimation];
    }
}

-(void)insertTableRowAtIndex:(NSUInteger)row
{
    if (m_table)
    {
        [m_table insertRowsAtIndexPaths:[self indexPathArrayForRow:row] withRowAnimation:m_rowAnimation];
    }
}

-(void)updateTableForNewItem:(HVItem *)item
{
    if (!item || !m_table)
    {
        return;
    }
    
    NSUInteger index = [m_view indexOfItemID:item.itemID];
    if (index != NSNotFound)
    {
        [self insertTableRowAtIndex:index];
    }
}

-(void)removeTableRowAtIndex:(NSUInteger)row
{
    if (m_table)
    {
        [m_table deleteRowsAtIndexPaths:[self indexPathArrayForRow:row] withRowAnimation:m_rowAnimation];
    }
}

//------------------------------
//
// UITableViewDelegate
//
//------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_view.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HVItem* item = nil;
    NSUInteger row = indexPath.row;
    if (row < m_view.count)
    {
        item = [m_view getItemAtIndex:row];
    }
    //
    // item is NULL when the item isn't available in the local store yet.
    // HVTypeView will download the item in the background.
    // It will fire the delegate (HVTypeViewDelegate) when the item is available
    //
    if (item)
    {
        return [self tableView:tableView cellForRow:row withItem:item];
    }

    return [self tableView:tableView cellForPendingRow:row];
}

//
// OVERRIDABLE
//
-(UITableViewCell *)tableView:(UITableView *)table cellForRow:(NSUInteger)row withItem:(HVItem *)item
{
    UITableViewCell* cell = [self createNewCellForTable:table];
    
    cell.textLabel.text = [self effectiveDateStringForItem:item];
    cell.detailTextLabel.text = [self descriptionStringForItem:item];
    
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)table cellForPendingRow:(NSUInteger)row
{
    UITableViewCell* cell = [self createNewCellForTable:table];
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = @"...";
    
    return cell;
}

-(UITableViewCell *)createNewCellForTable:(UITableView *)table
{
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:m_cellStyle reuseIdentifier:@"Cell"] autorelease];
    }
    return cell;
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

@implementation HVItemTableViewDataSource (HVPrivate)

-(NSMutableArray *)indexPathArrayForRow:(NSUInteger)row
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    HVCHECK_NOTNULL(array);
    
    NSIndexPath* pathForRow = [NSIndexPath indexPathForRow:row inSection:0];
    HVCHECK_NOTNULL(pathForRow);
    
    [array addObject:pathForRow];
    return array;
    
LError:
    return nil;
}

@end

@implementation HVTypeViewDataSource

@synthesize typeView = m_typeView;

-(id)init
{
    return [self initForTable:nil withRecord:nil andTypeID:nil];
}

-(id)initForTable:(UITableView *)table withRecord:(HVRecordReference *)record andTypeID:(NSString *)typeID
{
    HVTypeView* typeView = [HVTypeView getViewForTypeID:typeID inRecord:record];
    HVCHECK_NOTNULL(typeView);
    
    return [self initForTable:table withTypeView:typeView];

LError:
    HVALLOC_FAIL;
}

-(id)initForTable:(UITableView *)table withTypeView:(HVTypeView *)typeView
{
    HVCHECK_NOTNULL(table);
    HVCHECK_NOTNULL(typeView);
    
    self = [super initForTable:table andView:typeView];
    HVCHECK_SELF;
    
    m_typeView = [typeView retain];
    m_typeView.delegate = self;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    m_typeView.delegate = nil;
    [m_typeView release];
    
    [super dealloc];
}

-(void)saveTypeView
{
    [m_typeView save];
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
        [self saveTypeView];
        [self reloadAllItems];
    }
    else
    {
        [self reloadItems:items];
    }
}

-(void)keysNotAvailable:(NSArray *)keys inView:(HVTypeView *)view
{
    [self saveTypeView];
    [self reloadAllItems];
}

-(void)synchronizationCompletedInView:(HVTypeView *)view
{
    [self saveTypeView];
    [self reloadAllItems];
}

-(void)synchronizationFailedInView:(HVTypeView *)view withError:(id)ex
{
}

@end


