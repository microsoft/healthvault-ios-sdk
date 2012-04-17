//
//  HVItem.h
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
#import "HVItemKey.h"
#import "HVItemType.h"
#import "HVItemState.h"
#import "HVAudit.h"
#import "HVItemData.h"

@interface HVItem : HVType
{
@private
    HVItemKey* m_key;
    HVItemType* m_type;
    enum HVItemState m_state;
    int m_flags;
    NSDate* m_effectiveDate;
    HVAudit* m_created;
    HVAudit* m_updated;    
    HVItemData* m_data;
}

@property (readwrite, nonatomic, retain) HVItemKey* key;
@property (readonly, nonatomic) BOOL hasKey;

@property (readwrite, nonatomic, retain) HVItemType* type;

@property (readwrite, nonatomic) enum HVItemState state;
@property (readwrite, nonatomic) int flags;

@property (readwrite, nonatomic, retain) NSDate* effectiveDate;

@property (readwrite, nonatomic, retain) HVAudit* created;
@property (readwrite, nonatomic, retain) HVAudit* updated;

@property (readwrite, nonatomic, retain) HVItemData* data;
@property (readonly, nonatomic) BOOL hasData;

@property (readonly, nonatomic) BOOL hasTypedData;
@property (readonly, nonatomic) NSString* itemID;

@property (readonly, nonatomic) BOOL hasCommonData;
@property (readwrite, nonatomic, retain) NSString* note;

-(id) initWithType:(NSString *) typeID;
-(id) initWithTypedData:(HVItemDataTyped *) data;
-(id) initWithTypedDataClassName:(NSString *) name;
-(id) initWithTypedDataClass:(Class) cls;

-(BOOL) setKeyToNew;
-(BOOL) ensureKey;

-(NSDate *) getDate;

-(BOOL) isVersion:(NSString *) version;

@end

@interface HVItemCollection : HVCollection <XSerializable>

-(id) initwithItem:(HVItem *) item;

-(HVItem *) itemAtIndex:(NSUInteger) index;

-(BOOL) containsItemID:(NSString *) itemID;
-(NSUInteger) indexOfItemID:(NSString *) itemID;

-(NSMutableDictionary *) createIndexByID;
-(NSMutableDictionary *) getItemsIndexedByID;

+(HVStringCollection *) idsFromItems:(NSArray *) items;

-(HVClientResult *) validate;

@end
