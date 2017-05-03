//
//  MHVPutItemsTask.h
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
#import "MHVMethodCallTask.h"
#import "MHVItem.h"

//
// Request: MHVItemCollection
// Response: MHVItemKeyCollection - keys assigned to the items you put
// 
@interface MHVPutItemsTask : MHVMethodCallTask
{
    MHVItemCollection* m_items;
}

@property (readwrite, nonatomic, strong) MHVItemCollection* items;
@property (readonly, nonatomic) BOOL hasItems;

@property (readonly, nonatomic, strong) MHVItemKeyCollection* putResults;
@property (readonly, nonatomic, strong) MHVItemKey* firstKey;

-(id) initWithItem:(MHVItem *) item andCallback:(HVTaskCompletion) callback;
-(id) initWithItems:(MHVItemCollection *) items andCallback:(HVTaskCompletion) callback;

+(MHVPutItemsTask *) newForRecord:(MHVRecordReference *) record item:(MHVItem *) item andCallback:(HVTaskCompletion)callback;
+(MHVPutItemsTask *) newForRecord:(MHVRecordReference *) record items:(MHVItemCollection *)items andCallback:(HVTaskCompletion)callback;

@end
