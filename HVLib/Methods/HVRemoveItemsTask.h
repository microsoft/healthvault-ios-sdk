//
//  HVRemoveItemsTask.h
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
#import "HVItemKey.h"

//
// Request: HVItemKeyCollection - keys to remove
// Response: Nothing
//
@interface HVRemoveItemsTask : HVMethodCallTask
{
    HVItemKeyCollection* m_keys;
}

@property (readwrite, nonatomic, retain) HVItemKeyCollection* keys;
@property (readonly, nonatomic) BOOL hasKeys;

-(id) initWithKey:(HVItemKey *) key andCallback:(HVTaskCompletion) callback;
-(id) initWithKeys:(HVItemKeyCollection *) keys andCallback:(HVTaskCompletion) callback;

+(HVRemoveItemsTask *)newForRecord:(HVRecordReference *)record key:(HVItemKey *)key callback:(HVTaskCompletion)callback;
+(HVRemoveItemsTask *)newForRecord:(HVRecordReference *) record keys:(HVItemKeyCollection *)keys andCallback:(HVTaskCompletion)callback;

@end
