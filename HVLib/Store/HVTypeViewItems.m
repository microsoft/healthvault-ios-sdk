//
//  HVTypeViewItems.m
//  HVLib
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

#import "HVCommon.h"
#import "HVTypeViewItems.h"

static NSString* const c_element_item = @"item";

@interface HVTypeViewItems (HVPrivate)

-(void) ensureOrdered;

@end


@implementation HVTypeViewItems

-(NSUInteger) count
{
    return m_items.count;
}

-(NSDate*) maxDate
{
    if (m_items.count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:0].date;      
}

-(NSDate*) minDate
{
    NSUInteger count = m_items.count;
    if (count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:count - 1].date;
}

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_sorted = FALSE;
    
    m_items = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_items);
    
    m_itemsByID = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_itemsByID);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_items release];
    [m_itemsByID release];
    [super dealloc];
}

-(HVTypeViewItem *)objectAtIndex:(NSUInteger)index
{
    [self ensureOrdered];
    return [m_items objectAtIndex:index];
}

-(HVTypeViewItem *)objectForItemID:(NSString *)itemID
{
    return [m_itemsByID objectForKey:itemID];
}

-(NSUInteger) indexOfItem:(HVTypeViewItem *)item
{
    return [self searchForItem:item withOptions:NSBinarySearchingInsertionIndex];
}

-(NSUInteger) indexOfItemID:(NSString *)itemID
{
    HVTypeViewItem* item = [self objectForItemID:itemID];
    if (!item)
    {
        return NSNotFound;
    }
    
    return [self indexOfItem:item];
}

-(NSUInteger) searchForItem:(HVTypeViewItem *)item withOptions:(NSBinarySearchingOptions)opts
{
    [self ensureOrdered];
        
    return [m_items binarySearch:item options:opts usingComparator:^(id o1, id o2) { 
        
        return [HVTypeViewItem compare:o1 to:o2];
    
    }];
}

-(NSUInteger)searchForItem:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    [self ensureOrdered];
    
    return [m_items binarySearch:object options:opts usingComparator:cmp];
}

-(BOOL) addItem:(HVTypeViewItem *)item
{
    HVCHECK_NOTNULL(item);

    [m_items addObject:item];
    m_sorted = FALSE;
    
    [m_itemsByID setObject:item forKey:item.itemID];
  
    return TRUE;

LError:
    return FALSE;
}

-(NSUInteger) insertItemInOrder:(HVTypeViewItem *)item
{
    if (!item)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self searchForItem:item withOptions:NSBinarySearchingInsertionIndex]; 
    if (index >= m_items.count)
    {
        [m_items addObject:item];
    }
    else
    {
        [m_items insertObject:item atIndex:index];
    }
    
    [m_itemsByID setObject:item forKey:item.itemID];
    
    return index;
}

-(NSUInteger) removeItem:(HVTypeViewItem *)item
{
    if (!item)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self indexOfItem:item];
    if (index != NSNotFound)
    {
        [self removeItemAtIndex:index];
    }
    
    return index;
}

-(NSUInteger) removeItemByID:(NSString *)itemID
{
    NSUInteger index = [self indexOfItemID:itemID];
    if (index != NSNotFound)
    {
        [self removeItemAtIndex:index];
    }
    
    return index;
}

-(void) removeItemAtIndex:(NSUInteger)index
{
   HVTypeViewItem* item = [m_items objectAtIndex:index];
    if (!item)
    {
        return;
    }
    
    [m_items removeObjectAtIndex:index];
    [m_itemsByID removeObjectForKey:item.itemID];
}

-(BOOL)replaceItemAt:(NSUInteger)index with:(HVTypeViewItem *)item
{
    HVCHECK_NOTNULL(item);
    
    HVTypeViewItem *existingItem = [self objectAtIndex:index];
    HVCHECK_NOTNULL(existingItem);
    
    [m_itemsByID removeObjectForKey:existingItem.itemID];
    [m_items replaceObjectAtIndex:index withObject:item];
    [m_itemsByID setObject:item forKey:item.itemID];
    
    m_sorted = FALSE;
    
    return TRUE;

LError:
    return FALSE;
}

-(BOOL)setDate:(NSDate *)date forItemID:(NSString *)itemID
{
    HVCHECK_NOTNULL(date);
    HVCHECK_STRING(itemID);
    
    NSUInteger index = [self indexOfItemID:itemID];
    if (index == NSNotFound)
    {
        return FALSE;
    }
    
    HVTypeViewItem *item = [self objectAtIndex:index];
    if ([item.date isEqualToDate:date])
    {
        // No change
        return FALSE;
    }
    
    HVTypeViewItem *newItem = [[HVTypeViewItem alloc] initWithItem:item];
    HVCHECK_NOTNULL(newItem);
    
    [self replaceItemAt:index with:newItem];
    [newItem release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSArray *) selectRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    return [m_items subarrayWithRange:range];
}

-(NSArray *)selectIDsInRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    NSMutableArray *selection = [[[NSMutableArray alloc] initWithCapacity:range.length] autorelease];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        HVTypeViewItem* key = [m_items objectAtIndex:i];
        [selection addObject:key];
    }
    
    return selection;
}

-(NSMutableArray *)selectItemsNotIn:(HVTypeViewItems *)keys
{
    NSMutableArray *keysNotFound = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0, count = self.count; i < count; ++i) 
    {
        HVTypeViewItem* key = [self objectAtIndex:i];
        if (![keys contains:key])
        {
            [keysNotFound addObject:key];
        }
    }
    
    return keysNotFound;
    
LError:
    return nil;
}

-(NSRange)correctRange:(NSRange)range
{
    [self ensureOrdered];
    
    int max = range.location + range.length;
    if (max > m_items.count)
    {
        range = NSMakeRange(range.location, m_items.count - range.location);
    }    
    
    return range;
}

-(BOOL) contains:(HVTypeViewItem *)item
{
    return ([self indexOfItem:item] != NSNotFound);
}

-(BOOL) containsID:(NSString *)itemID
{
    return ([self objectForItemID:itemID] != nil);
}

-(BOOL)addHVItem:(HVItem *)item
{
    HVTypeViewItem* dateKey = [[HVTypeViewItem alloc] initWithHVItem:item];
    HVCHECK_NOTNULL(dateKey);
    
    [self addItem:dateKey];
    [dateKey release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSUInteger)insertHVItemInOrder:(HVItem *)item
{
    HVTypeViewItem* dateKey = [[HVTypeViewItem alloc] initWithHVItem:item];
    HVCHECK_NOTNULL(dateKey);
    
    NSUInteger index = [self insertItemInOrder:dateKey];
    [dateKey release];
    
    return index;
    
LError:
    return NSNotFound;    
}

-(BOOL)addPendingItem:(HVPendingItem *)item
{
    HVTypeViewItem* dateKey = [[HVTypeViewItem alloc] initWithPendingItem:item];
    HVCHECK_NOTNULL(dateKey);
 
    [self addItem:dateKey];
    [dateKey release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addHVItems:(HVItemCollection *)items
{
    HVCHECK_NOTNULL(items);
    
    for (HVItem* item in items)
    {
        HVCHECK_SUCCESS([self addHVItem:item]);
    }
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addPendingItems:(HVPendingItemCollection *)items
{
    HVCHECK_NOTNULL(items);
    
    for (HVPendingItem* item in items)
    {
        HVCHECK_SUCCESS([self addPendingItem:item]);
    }
    return TRUE;
    
LError:
    return FALSE;   
}

-(BOOL)addQueryResult:(HVItemQueryResult *)result
{
    HVCHECK_NOTNULL(result);
    
    if (result.hasItems)
    {
        HVCHECK_SUCCESS([self addHVItems:result.items]);
    }
    if (result.hasPendingItems)
    {
        HVCHECK_SUCCESS([self addPendingItems:result.pendingItems]);
    }
    
    return TRUE;
LError:
    return FALSE;
}

-(BOOL) updateDateForHVItem:(HVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    return [self setDate:[item getDate] forItemID:item.itemID];
    
LError:
    return FALSE;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_items, c_element_item);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_items, c_element_item, HVTypeViewItem, NSMutableArray);
    //
    // Index array
    //
    [m_itemsByID removeAllObjects];
    for (HVTypeViewItem* item in m_items) 
    {
        [m_itemsByID setObject:item forKey:item.itemID];
    }
}

@end

@implementation HVTypeViewItems (HVPrivate)

-(void) ensureOrdered
{
    if (m_sorted)
    {
        return;
    }
    
    [m_items sortUsingComparator:^(id o1, id o2) {
        return [HVTypeViewItem compare:o1 to:o2];
    }];
    
    
    m_sorted = TRUE;
}

@end
