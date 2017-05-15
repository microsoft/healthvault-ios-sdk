//
// MHVCollection.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVBlock.h"

//
// Collections allow objects of a particular type only
// They enforce the type
//
@interface MHVCollection<__covariant ObjectType> : NSObject<NSFastEnumeration>

@property (readwrite, nonatomic, strong) Class  type;

- (instancetype)initWithCapacity:(NSUInteger)numThings;
- (instancetype)initWithArray:(NSArray *)array;

+ (BOOL)isNilOrEmpty:(MHVCollection *)collection;
- (NSUInteger)count;
- (ObjectType)objectAtIndex:(NSUInteger)index;
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;
- (ObjectType)firstObject;
- (ObjectType)lastObject;
- (void)addObject:(ObjectType)anObject;
- (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx;
- (void)addObjectsFromArray:(NSArray<ObjectType> *)array;
- (void)addObjectsFromCollection:(MHVCollection<ObjectType> *)collection;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObject:(ObjectType)object;
- (void)removeFirstObject;
- (void)removeLastObject;
- (void)removeAllObjects;

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr;
- (NSUInteger)binarySearch:(ObjectType)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;
- (NSUInteger)indexOfMatchingObject:(MHVFilter)filter;

- (NSArray *)toArray;

// -----------------
//
// Text
//
// -----------------
- (NSString *)toString;

@end

@interface MHVStringCollection : MHVCollection<NSString *>

- (BOOL)containsString:(NSString *)value;
- (NSUInteger)indexOfString:(NSString *)value;
- (NSUInteger)indexOfString:(NSString *)value startingAt:(NSUInteger)index;
- (BOOL)removeString:(NSString *)value;

//
// NOTE: these do a linear N^2 scan
//
- (MHVStringCollection *)selectStringsFoundInSet:(NSArray *)testSet;
- (MHVStringCollection *)selectStringsNotFoundInSet:(NSArray *)testSet;

@end
