//
//  HVObjectStore.h
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

@protocol HVObjectStore <NSObject>

-(NSEnumerator *) allKeys;

-(NSDate *) updateDateForKey:(NSString *) key;

-(BOOL) keyExists:(NSString *) key;
-(BOOL) deleteKey:(NSString *) key;

-(id) getObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls;
-(BOOL) putObject:(id) obj withKey:(NSString *) key andName:(NSString *) name;

-(NSData *) getBlob:(NSString *) key;
-(BOOL) putBlob:(NSData *) blob withKey:(NSString *) key;

-(id<HVObjectStore>) newChildStore:(NSString *) name;
-(void) deleteChildStore:(NSString *) name;

-(id) refreshAndGetObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls; 
-(NSData *) refreshAndGetBlob:(NSString *) key;

@end
