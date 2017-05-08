//
//  MHVTypeViewItems.m
//  MHVLib
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

#import "MHVCommon.h"
#import "MHVTypeViewItems.h"

static NSString* const c_element_item = @"item";

@interface MHVTypeViewItems (MHVPrivate)

-(void) ensureOrdered;

@end


@implementation MHVTypeViewItems

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

-(MHVTypeViewItem *)firstItem
{
    if (m_items.count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:0];    
}

-(MHVTypeViewItem *)lastItem
{
    NSUInteger count = m_items.count;
    if (count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:count - 1];    
}

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_sorted = FALSE;
    
    m_items = [[NSMutableArray alloc] init];
    MHVCHECK_NOTNULL(m_items);
    
    m_itemsByID = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_itemsByID);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTypeViewItem *)objectAtIndex:(NSUInteger)index
{
    [self ensureOrdered];
    return [m_items objectAtIndex:index];
}

-(MHVTypeViewItem *)objectForItemID:(NSString *)itemID
{
    return [m_itemsByID objectForKey:itemID];
}

-(NSUInteger) indexOfItem:(MHVTypeViewItem *)item
{
   // return [self searchForItem:item withOptions:(NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual)];
    return [self searchForItem:item withOptions:0];
}

-(NSUInteger) indexOfItemID:(NSString *)itemID
{
    MHVTypeViewItem* item = [self objectForItemID:itemID];
    if (!item)
    {
        return NSNotFound;
    }
    
    NSUInteger index =  [self indexOfItem:item];
    if (index >= m_items.count)
    {
        index = NSNotFound;
    }
    
    return index;
}

-(NSUInteger) searchForItem:(MHVTypeViewItem *)item withOptions:(NSBinarySearchingOptions)opts
{
    [self ensureOrdered];
        
    return [m_items indexOfObject:item inSortedRange:NSMakeRange(0, m_items.count) options:opts usingComparator:^(id o1, id o2)
    {
        return [MHVTypeViewItem compare:o1 to:o2];
    }];
}

-(NSUInteger)searchForItem:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    [self ensureOrdered];
    
    return [m_items indexOfObject:object inSortedRange:NSMakeRange(0, m_items.count) options:opts usingComparator:cmp];
}

-(BOOL) addItem:(MHVTypeViewItem *)item
{
    MHVCHECK_NOTNULL(item);

    [m_items addObject:item];
    m_sorted = FALSE;
    
    [m_itemsByID setObject:item forKey:item.itemID];
  
    return TRUE;

LError:
    return FALSE;
}

-(NSUInteger) insertItemInOrder:(MHVTypeViewItem *)item
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

-(NSUInteger) removeItem:(MHVTypeViewItem *)item
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
    MHVTypeViewItem* item = [m_items objectAtIndex:index];
    if (!item)
    {
        return;
    }
    
    [m_items removeObjectAtIndex:index];
    [m_itemsByID removeObjectForKey:item.itemID];
}

-(BOOL)replaceItemAt:(NSUInteger)index with:(MHVTypeViewItem *)item
{
    MHVCHECK_NOTNULL(item);
    
    MHVTypeViewItem *existingItem = [self objectAtIndex:index];
    MHVCHECK_NOTNULL(existingItem);
    
    [m_itemsByID removeObjectForKey:existingItem.itemID];
    [m_items replaceObjectAtIndex:index withObject:item];
    [m_itemsByID setObject:item forKey:item.itemID];
    
    m_sorted = FALSE;
    
    return TRUE;

LError:
    return FALSE;
}

-(MHVItemKeyCollection *)keysInRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    return [[MHVItemKeyCollection alloc] initWithArray:[m_items subarrayWithRange:range]];
}

-(NSArray *)selectIDsInRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    NSMutableArray *selection = [[NSMutableArray alloc] initWithCapacity:range.length];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVTypeViewItem* key = [m_items objectAtIndex:i];
        [selection addObject:key];
    }
    
    return selection;
}

-(NSMutableArray *)selectItemsNotIn:(MHVTypeViewItems *)keys
{
    NSMutableArray *keysNotFound = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0, count = self.count; i < count; ++i) 
    {
        MHVTypeViewItem* key = [self objectAtIndex:i];
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
    
    int max = (int)range.location + (int)range.length;
    if (max > m_items.count)
    {
        range = NSMakeRange(range.location, m_items.count - range.location);
    }    
    
    return range;
}

-(BOOL) contains:(MHVTypeViewItem *)item
{
    return ([self indexOfItem:item] != NSNotFound);
}

-(BOOL) containsID:(NSString *)itemID
{
    return ([self objectForItemID:itemID] != nil);
}

-(BOOL)addMHVItem:(MHVItem *)item
{
    MHVTypeViewItem* dateKey = [[MHVTypeViewItem alloc] initWithMHVItem:item];
    MHVCHECK_NOTNULL(dateKey);
    
    [self addItem:dateKey];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSUInteger)insertHVItemInOrder:(MHVItem *)item
{
    MHVTypeViewItem* dateKey = [[MHVTypeViewItem alloc] initWithMHVItem:item];
    if (!dateKey)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self insertItemInOrder:dateKey];
    
    return index;
}

-(BOOL)addPendingItem:(MHVPendingItem *)item
{
    MHVTypeViewItem* dateKey = [[MHVTypeViewItem alloc] initWithPendingItem:item];
    MHVCHECK_NOTNULL(dateKey);
 
    [self addItem:dateKey];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addHVItems:(MHVItemCollection *)items
{
    MHVCHECK_NOTNULL(items);
    
    for (MHVItem* item in items)
    {
        MHVCHECK_SUCCESS([self addMHVItem:item]);
    }
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addPendingItems:(MHVPendingItemCollection *)items
{
    MHVCHECK_NOTNULL(items);
    
    for (MHVPendingItem* item in items)
    {
        MHVCHECK_SUCCESS([self addPendingItem:item]);
    }
    return TRUE;
    
LError:
    return FALSE;   
}

-(BOOL)addQueryResult:(MHVItemQueryResult *)result
{
    MHVCHECK_NOTNULL(result);
    
    if (result.hasItems)
    {
        MHVCHECK_SUCCESS([self addHVItems:result.items]);
    }
    if (result.hasPendingItems)
    {
        MHVCHECK_SUCCESS([self addPendingItems:result.pendingItems]);
    }
    
    return TRUE;

LError:
    return FALSE;
}

-(BOOL)updateMHVItem:(MHVItem *)item
{
    MHVCHECK_NOTNULL(item);
    
    NSUInteger itemIndex = [self indexOfItemID:item.itemID];
    if (itemIndex == NSNotFound)
    {
        return [self addMHVItem:item];
    }
        
    MHVTypeViewItem* typeViewItem = [self objectAtIndex:itemIndex];
    //
    // Update version stamps if needed
    //
    if ([typeViewItem isVersion:item.key.version])
    {
        return FALSE; // NO change. Same key.
    }
    
    MHVTypeViewItem *newItem = [[MHVTypeViewItem alloc] initWithMHVItem:item];
    MHVCHECK_NOTNULL(newItem);
    
    [self replaceItemAt:itemIndex with:newItem];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_item elements:m_items];
}

-(void) deserialize:(XReader *)reader
{
    m_items = [reader readElementArray:c_element_item asClass:[MHVTypeViewItem class] andArrayClass:[NSMutableArray class]];
    //
    // Index array
    //
    [m_itemsByID removeAllObjects];
    for (MHVTypeViewItem* item in m_items) 
    {
        [m_itemsByID setObject:item forKey:item.itemID];
    }
}

@end

@implementation MHVTypeViewItems (MHVPrivate)

-(void) ensureOrdered
{
    if (m_sorted)
    {
        return;
    }
    
    [m_items sortUsingComparator:^(id o1, id o2) {
        return [MHVTypeViewItem compare:o1 to:o2];
    }];
    
    
    m_sorted = TRUE;
}

@end
