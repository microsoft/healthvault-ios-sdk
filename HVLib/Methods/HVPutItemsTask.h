//
//  HVPutItemsTask.h
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
#import "HVMethodCallTask.h"
#import "HVItem.h"

//
// Request: HVItemCollection
// Response: HVItemKeyCollection - keys assigned to the items you put
// 
@interface HVPutItemsTask : HVMethodCallTask
{
    HVItemCollection* m_items;
}

@property (readwrite, nonatomic, retain) HVItemCollection* items;
@property (readonly, nonatomic) BOOL hasItems;

@property (readonly, nonatomic) HVItemKeyCollection* putResults;
@property (readonly, nonatomic) HVItemKey* firstKey;

-(id) initWithItem:(HVItem *) item andCallback:(HVTaskCompletion) callback;
-(id) initWithItems:(HVItemCollection *) items andCallback:(HVTaskCompletion) callback;

+(HVPutItemsTask *) newForRecord:(HVRecordReference *) record item:(HVItem *) item andCallback:(HVTaskCompletion)callback;
+(HVPutItemsTask *) newForRecord:(HVRecordReference *) record items:(HVItemCollection *)items andCallback:(HVTaskCompletion)callback;

@end
