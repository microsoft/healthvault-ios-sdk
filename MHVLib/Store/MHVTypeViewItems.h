//
//  MHVTypeViewItems.h
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

#import <Foundation/Foundation.h>
#import "MHVTypeViewItem.h"
#import "XLib.h"

//-------------------------------------
//
// An ORDERED collection of MHVTypeViewItem
// The sort order is:
//  - MHVTypeView.date [descending]
//  THEN MHVTypeView.itemID [ascending]
//
// Matches the default sort order of HealthVault query results
//
// Also maintains a reverse index of ItemID --> the item's position.
//
//-----------------------------------
@interface MHVTypeViewItems : XSerializableType
{
    BOOL m_sorted;
    NSMutableArray *m_items;
    NSMutableDictionary *m_itemsByID;
}

@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic, strong) NSDate* maxDate;
@property (readonly, nonatomic, strong) NSDate* minDate;
@property (readonly, nonatomic, strong) MHVTypeViewItem* firstItem;
@property (readonly, nonatomic, strong) MHVTypeViewItem* lastItem;

-(MHVTypeViewItem *) objectAtIndex:(NSUInteger) index;
-(MHVTypeViewItem *) objectForItemID:(NSString *) itemID;

-(NSUInteger) searchForItem:(MHVTypeViewItem *)item withOptions:(NSBinarySearchingOptions) opts;
-(NSUInteger) searchForItem:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;

-(BOOL) contains:(MHVTypeViewItem *) item;
-(BOOL) containsID:(NSString *) itemID;

-(NSUInteger) indexOfItem:(MHVTypeViewItem *) item;
-(NSUInteger) indexOfItemID:(NSString *) itemID;

-(BOOL) addItem:(MHVTypeViewItem *) item;
-(NSUInteger) insertItemInOrder:(MHVTypeViewItem *) item;
-(NSUInteger) removeItem:(MHVTypeViewItem *) item;
-(void) removeItemAtIndex:(NSUInteger) index;
-(NSUInteger) removeItemByID:(NSString *) itemID;
-(BOOL) replaceItemAt:(NSUInteger) index with:(MHVTypeViewItem *) item;

-(MHVItemKeyCollection *)keysInRange:(NSRange)range;
-(NSArray *) selectIDsInRange:(NSRange) range;
-(NSRange) correctRange:(NSRange) range;
-(NSMutableArray*) selectItemsNotIn:(MHVTypeViewItems *) items;

//
// Adds an item into the collection using information taken from MHVItem
// Returns true if collection updated
//
-(BOOL) addMHVItem:(MHVItem *) item;
-(BOOL) addHVItems:(MHVItemCollection *) items;
//
// Adds an item into the collection using information taken from MHVItem
// Maintains the sort order - so a full sort is not required. 
// 
-(NSUInteger) insertHVItemInOrder:(MHVItem *) item;
//
// Returns true if an update to the collection was necessary, and made.
// If item not found, or no change made, returns false If the item does not exist, will add it
//
-(BOOL) updateMHVItem:(MHVItem *) item;
//
// Adds an item into the collection using information taken from MHVPendingItem
// Returns true if collection updated
//
-(BOOL) addPendingItem:(MHVPendingItem *) item;
-(BOOL) addPendingItems:(MHVPendingItemCollection *) items;
//
// Adds items into the collection using information taken from MHVItemQueryResult
// Returns true if collection updated
//
-(BOOL) addQueryResult:(MHVItemQueryResult *) result;

@end
