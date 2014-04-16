//
//  HVArrayExtensions.h
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
//

#import <Foundation/Foundation.h>
#import "HVBlock.h"

@interface NSArray (HVArrayExtensions)

-(NSRange) range;

-(NSUInteger) binarySearch:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;
-(NSUInteger) indexOfMatchingObject:(HVFilter) filter;

+(BOOL) isNilOrEmpty:(NSArray *) array;

@end

@interface NSMutableArray (HVArrayExtensions)

+(NSMutableArray *) ensure:(NSMutableArray **) pArray;
+(NSMutableArray *) fromEnumerator:(NSEnumerator *) enumerator;

-(BOOL) isEmpty;

-(void) addFromEnumerator:(NSEnumerator *) enumerator;

//---------------------
//
// STACK EXTENSIONS
//
//---------------------
-(void) pushObject:(id) object;
-(id) peek;
-(id) popObject;

//---------------------
//
// Queue EXTENSIONS
// Using a simple array is NOT the best way to build a queue, but will do in a pinch.
//
//---------------------
-(void) enqueueObject:(id) object;
-(void) enqueueObject:(id)object maxQueueSize:(NSUInteger) size;

-(id) dequeueObject;

@end
