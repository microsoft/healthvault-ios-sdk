//
//  MHVObjectStore.h
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

@protocol MHVObjectStore <NSObject>

-(NSEnumerator *) allKeys;

-(NSDate *) createDateForKey:(NSString *) key;
-(NSDate *) updateDateForKey:(NSString *) key;

-(BOOL) keyExists:(NSString *) key;
-(BOOL) deleteKey:(NSString *) key;

-(id) getObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls;
-(BOOL) putObject:(id) obj withKey:(NSString *) key andName:(NSString *) name;

-(NSData *) getBlob:(NSString *) key;
-(BOOL) putBlob:(NSData *) blob withKey:(NSString *) key;

-(id<MHVObjectStore>) newChildStore:(NSString *) name;
-(void) deleteChildStore:(NSString *) name;
-(BOOL) childStoreExists:(NSString *) name;
-(NSEnumerator *) allChildStoreNames;

//
// Tells the store not to serve up objects from any caches, but to refetch from the backing store
//
-(id) refreshAndGetObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls; 
-(NSData *) refreshAndGetBlob:(NSString *) key;

@optional
-(void) clearCache;

@end
