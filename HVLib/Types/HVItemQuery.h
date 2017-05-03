//
//  HVItemQuery.h
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
#import "HVType.h"
#import "HVInt.h"
#import "HVItemKey.h"
#import "HVItemFilter.h"
#import "HVItemView.h"


@interface HVItemQuery : HVType
{
@private
    NSString* m_name;
    HVStringCollection* m_itemIDs;
    HVItemKeyCollection* m_keys;
    HVStringCollection* m_clientIDs;
    HVItemFilterCollection* m_filters;
    HVItemView* m_view;
    HVInt* m_max;
    HVInt* m_maxFull;    
}

@property (readwrite, nonatomic, retain) NSString* name;
//
// itemIDs, keys, and clientIDs are a CHOICE.
// You can specify items for one only one of them in a single query
// 
@property (readonly, nonatomic) HVStringCollection* itemIDs;
@property (readonly, nonatomic) HVItemKeyCollection* keys;
@property (readonly, nonatomic) HVStringCollection* clientIDs;
//
// constrain results (where clauses
//
@property (readonly, nonatomic) HVItemFilterCollection* filters;
//
// What format to pull data down in
//
@property (readwrite, nonatomic, retain) HVItemView* view;

@property (readwrite, nonatomic) int maxResults;
@property (readwrite, nonatomic) int maxFullResults;

-(id) initWithTypeID:(NSString *) typeID;
-(id) initWithFilter:(HVItemFilter *) filter;
-(id) initWithItemKey:(HVItemKey *) key;
-(id) initWithItemKeys:(NSArray *) keys;
-(id) initWithItemIDs:(NSArray *) ids;
-(id) initWithItemID:(NSString *) itemID;
-(id) initWithPendingItems:(NSArray *) pendingItems;
-(id) initWithItemKey:(HVItemKey *) key andType:(NSString *) typeID;
-(id) initWithItemID:(NSString *) itemID andType:(NSString *) typeID;;
-(id) initWithClientID:(NSString *) clientID andType:(NSString *) typeID;

@end

@interface HVItemQueryCollection : HVCollection 

-(void) addItem:(HVItemQuery *) query;
-(HVItemQuery *) itemAtIndex:(NSUInteger) index;

@end
