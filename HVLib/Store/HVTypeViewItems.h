//
//  HVTypeViewItems.h
//  HVLib
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

#import <Foundation/Foundation.h>
#import "HVTypeViewItem.h"
#import "XLib.h"

//-------------------------------------
//
// An ORDERED collection of HVTypeViewItem
// The sort order is:
//  - HVTypeView.date [descending]
//  THEN HVTypeView.itemID [ascending]
//
// Matches the default sort order of HealthVault query results
//
// Also maintains a reverse index of ItemID --> the item's position.
//
//-----------------------------------
@interface HVTypeViewItems : XSerializableType
{
    BOOL m_sorted;
    NSMutableArray *m_items;
    NSMutableDictionary *m_itemsByID;
}

@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic, strong) NSDate* maxDate;
@property (readonly, nonatomic, strong) NSDate* minDate;
@property (readonly, nonatomic, strong) HVTypeViewItem* firstItem;
@property (readonly, nonatomic, strong) HVTypeViewItem* lastItem;

-(HVTypeViewItem *) objectAtIndex:(NSUInteger) index;
-(HVTypeViewItem *) objectForItemID:(NSString *) itemID;

-(NSUInteger) searchForItem:(HVTypeViewItem *)item withOptions:(NSBinarySearchingOptions) opts;
-(NSUInteger) searchForItem:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;

-(BOOL) contains:(HVTypeViewItem *) item;
-(BOOL) containsID:(NSString *) itemID;

-(NSUInteger) indexOfItem:(HVTypeViewItem *) item;
-(NSUInteger) indexOfItemID:(NSString *) itemID;

-(BOOL) addItem:(HVTypeViewItem *) item;
-(NSUInteger) insertItemInOrder:(HVTypeViewItem *) item;
-(NSUInteger) removeItem:(HVTypeViewItem *) item;
-(void) removeItemAtIndex:(NSUInteger) index;
-(NSUInteger) removeItemByID:(NSString *) itemID;
-(BOOL) replaceItemAt:(NSUInteger) index with:(HVTypeViewItem *) item;

-(NSArray *) selectRange:(NSRange) range;
-(NSArray *) selectIDsInRange:(NSRange) range;
-(NSRange) correctRange:(NSRange) range;
-(NSMutableArray*) selectItemsNotIn:(HVTypeViewItems *) items;

//
// Adds an item into the collection using information taken from HVItem
// Returns true if collection updated
//
-(BOOL) addHVItem:(HVItem *) item;
-(BOOL) addHVItems:(HVItemCollection *) items;
//
// Adds an item into the collection using information taken from HVItem
// Maintains the sort order - so a full sort is not required. 
// 
-(NSUInteger) insertHVItemInOrder:(HVItem *) item;
//
// Returns true if an update to the collection was necessary, and made.
// If item not found, or no change made, returns false If the item does not exist, will add it
//
-(BOOL) updateHVItem:(HVItem *) item;
//
// Adds an item into the collection using information taken from HVPendingItem
// Returns true if collection updated
//
-(BOOL) addPendingItem:(HVPendingItem *) item;
-(BOOL) addPendingItems:(HVPendingItemCollection *) items;
//
// Adds items into the collection using information taken from HVItemQueryResult
// Returns true if collection updated
//
-(BOOL) addQueryResult:(HVItemQueryResult *) result;

@end
