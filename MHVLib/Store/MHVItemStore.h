//
//  MHVItemStore.h
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
#import "MHVItem.h"
#import "MHVTypeViewItems.h"

@protocol MHVItemStore <NSObject>

-(NSEnumerator *) allKeys;

-(BOOL) existsItem:(NSString *) itemID;
-(MHVItem *) getItem:(NSString *) itemID;
-(BOOL) putItem:(MHVItem *) item;
-(void) removeItem:(NSString *) itemID;
//
// If item is cached, refreshes it from the primary store first
//
-(MHVItem *) refreshAndGetItem:(NSString *) itemID;
//
// Clear any in-memory caches to free up memory
//
-(void) clearCache;
-(void) deleteKeyFromCache:(NSString *) itemID;
// If the cache supports a max count limit, sets it...
-(void) setCacheLimitCount:(NSInteger) cacheSize;

@end
