//
//  HVItemDateAndKey.h
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
#import "HVTypes.h"

@interface HVTypeViewItem : HVItemKey
{
    NSDate* m_date;
    BOOL m_isLoadPending;
}

@property (readonly, nonatomic, retain) NSDate* date;
@property (readwrite, nonatomic) BOOL isLoadPending;

-(id) initWithDate:(NSDate *) date andID:(NSString*) itemID;
-(id) initWithItem:(HVTypeViewItem *) item;
-(id) initWithHVItem:(HVItem *) item;
-(id) initWithPendingItem:(HVPendingItem *) pendingItem;

-(NSComparisonResult) compareToItem:(HVTypeViewItem *) other;  //sorts Descending
-(NSComparisonResult) compareItemID:(HVTypeViewItem *) other;

+(NSComparisonResult) compare:(id) x to:(id) y;
+(NSComparisonResult) compareItem:(HVTypeViewItem *) x to:(HVTypeViewItem *) y;
+(NSComparisonResult) compareID:(id) x to:(id) y;

@end
