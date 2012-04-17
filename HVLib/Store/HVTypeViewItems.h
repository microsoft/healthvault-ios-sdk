//
//  HVTypeViewItems.h
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

#import <Foundation/Foundation.h>
#import "HVTypeViewItem.h"
#import "XLib.h"

@interface HVTypeViewItems : XSerializableType
{
    BOOL m_sorted;
    NSMutableArray *m_items;
    NSMutableDictionary *m_itemsByID;
}

@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic) NSDate* maxDate;
@property (readonly, nonatomic) NSDate* minDate;

-(id) init;

-(HVTypeViewItem *) objectAtIndex:(NSUInteger) index;
-(HVTypeViewItem *) objectForItemID:(NSString *) itemID;

-(NSUInteger) searchForItem:(HVTypeViewItem *)item withOptions:(NSBinarySearchingOptions) opts; 

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
// Returns false if no change made
-(BOOL) setDate:(NSDate *) date forItemID:(NSString *) itemID;

-(NSArray *) selectRange:(NSRange) range;
-(NSArray *) selectIDsInRange:(NSRange) range;
-(NSRange) correctRange:(NSRange) range;
-(NSMutableArray*) selectItemsNotIn:(HVTypeViewItems *) items;

//
// 
//
-(BOOL) addHVItem:(HVItem *) item;
-(NSUInteger) insertHVItemInOrder:(HVItem *) item;
-(BOOL) addPendingItem:(HVPendingItem *) item;
-(BOOL) addHVItems:(HVItemCollection *) items;
-(BOOL) addPendingItems:(HVPendingItemCollection *) items;
-(BOOL) addQueryResult:(HVItemQueryResult *) result;

//
// Returns true if update made. If item not found, or no change made, returns false
//
-(BOOL) updateDateForHVItem:(HVItem *) item;



@end
