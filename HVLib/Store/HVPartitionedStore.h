//
//  HVPartitionedStore.h
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
//

#import <Foundation/Foundation.h>
#import "HVObjectStore.h"

@interface HVPartitionedObjectStore : NSObject
{
@private
    id<HVObjectStore> m_rootStore;
    NSMutableDictionary* m_partitions;
}

-(id) initWithRoot:(id<HVObjectStore>) root;

-(BOOL) partition:(NSString *) partitionKey keyExists:(NSString *) key;

-(id) partition:(NSString *) partitionKey getObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls;
-(BOOL) partition:(NSString *) partitionKey putObject:(id) obj withKey:(NSString *) key andName:(NSString *) name;
-(BOOL) partition:(NSString *) partitionKey deleteKey:(NSString *) key;
-(BOOL) deletePartition:(NSString *) partitionKey;
-(NSDate *) partition:(NSString *) partitionKey createDateForKey:(NSString *) key;
-(NSDate *) partition:(NSString *) partitionKey updateDateForKey:(NSString *) key;
-(NSEnumerator *) allPartitionKeys;
-(NSEnumerator *) allKeysInPartition:(NSString *) partitionKey;

-(void) clearCache;

@end
