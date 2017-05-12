//
// MHVCollection.m
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

#import "MHVCommon.h"
#import "MHVCollection.h"

@interface MHVCollection ()

@property (nonatomic, strong) NSMutableArray *inner;

@end

@implementation MHVCollection

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _inner = [NSMutableArray new];
    }

    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    
    if (self)
    {
        _inner = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    
    return self;
}

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    
    if (self)
    {
        _inner = [[NSMutableArray alloc] initWithArray:array];
    }
    
    return self;
}

+ (BOOL)isNilOrEmpty:(MHVCollection *)collection
{
    return (!collection|| collection.count == 0);
}

- (NSUInteger)count
{
    return [self.inner count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.inner objectAtIndex:index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self.inner objectAtIndexedSubscript:idx];
}

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)idx
{
    if([self validateNewObject:anObject])
    {
        [self.inner setObject:anObject atIndexedSubscript:idx];
    }
}

- (id)lastObject
{
    return [self.inner lastObject];
}

- (void)addObject:(id)anObject
{
    if([self validateNewObject:anObject])
    {
        [self.inner addObject:anObject];
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if([self validateNewObject:anObject])
    {
        [self.inner insertObject:anObject atIndex:index];
    };
}

- (void)addObjectsFromArray:(NSArray *)array
{
    if (!array)
    {
        MHVASSERT_PARAMETER(array);
        return;
    }
    
    for (id obj in array)
    {
        if (![self validateNewObject:obj])
        {
            return;
        }
    }
    
    [self.inner addObjectsFromArray:array];
}

- (void)addObjectsFromCollection:(MHVCollection *)collection
{
    if (!collection)
    {
        MHVASSERT_PARAMETER(collection);
        return;
    }
    
    for (id obj in collection)
    {
        if (![self validateNewObject:obj])
        {
            return;
        }
    }
    
    [self.inner addObjectsFromArray:collection.toArray];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if([self validateNewObject:anObject])
    {
        [self.inner replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.inner removeObjectAtIndex:index];
}

- (void)removeLastObject
{
    [self.inner removeLastObject];
}

- (void)removeAllObjects
{
    [self.inner removeAllObjects];
}

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr
{
    [self.inner sortUsingComparator:cmptr];
}

- (NSUInteger)binarySearch:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    return [self.inner indexOfObject:object inSortedRange:NSMakeRange(0, self.count) options:opts usingComparator:cmp];
}

- (NSUInteger)indexOfMatchingObject:(MHVFilter)filter
{
    if (filter)
    {
        for (NSUInteger i = 0; i < self.count; ++i)
        {
            id obj = [self objectAtIndex:i];
            
            if (filter(obj))
            {
                return i;
            }
        }
    }
    
    return NSNotFound;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.inner countByEnumeratingWithState:state objects:buffer count:len];
}

- (BOOL)validateNewObject:(id)obj
{
    if (!obj)
    {
        MHVASSERT_PARAMETER(obj);
        return NO;
    }

    if (self.type)
    {
        if (obj != [NSNull null] && ![obj isKindOfClass:self.type])
        {
            NSString *message = [NSString stringWithFormat:@"%@ expected", [self.type description]];
            MHVASSERT_MESSAGE(message);
            return NO;
        }
    }
    
    return YES;
}

- (NSArray *)toArray
{
    return [self.inner copy];
}

- (NSString *)toString
{
    if (self.count == 0)
    {
        return @"";
    }

    NSMutableString *text = [[NSMutableString alloc] init];

    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        id obj = [self objectAtIndex:i];
        NSString *descr = [obj description];
        if ([NSString isNilOrEmpty:descr])
        {
            continue;
        }

        if (i > 0)
        {
            [text appendNewLine];
        }

        [text appendString:descr];
    }

    return text;
}

- (NSString *)description
{
    return [self toString];
}

- (id)mutableCopy
{
    MHVCollection *copy = [[[self class] alloc] init];

    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [copy addObject:[self objectAtIndex:i]];
    }

    return copy;
}

@end

@implementation MHVStringCollection

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = [NSString class];
    }

    return self;
}

- (BOOL)containsString:(NSString *)string
{
    return [self indexOfString:string] != NSNotFound;
}

- (NSUInteger)indexOfString:(NSString *)string
{
    return [self indexOfString:string startingAt:0];
}

- (NSUInteger)indexOfString:(NSString *)string startingAt:(NSUInteger)index
{
    if (!string)
    {
        return NSNotFound;
    }

    for (NSUInteger i = index, count = self.count; i < count; ++i)
    {
        if ([[self objectAtIndex:i] isEqualToString:string])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (BOOL)removeString:(NSString *)string
{
    if (!string)
    {
        return NO;
    }

    NSUInteger index = [self indexOfString:string];
    if (index == NSNotFound)
    {
        return NO;
    }

    [self removeObjectAtIndex:index];
    
    return YES;
}

- (MHVStringCollection *)selectStringsFoundInSet:(NSArray *)testSet
{
    MHVStringCollection *matches = nil;

    for (int i = 0, count = (int)testSet.count; i < count; ++i)
    {
        NSString *testString = [testSet objectAtIndex:i];
        if ([self containsString:testString])
        {
            if (!matches)
            {
                matches = [[MHVStringCollection alloc] init];
            }

            [matches addObject:testString];
        }
    }

    return matches;
}

- (MHVStringCollection *)selectStringsNotFoundInSet:(NSArray *)testSet
{
    MHVStringCollection *matches = nil;

    for (int i = 0, count = (int)testSet.count; i < count; ++i)
    {
        NSString *testString = [testSet objectAtIndex:i];
        if (![self containsString:testString])
        {
            if (!matches)
            {
                matches = [[MHVStringCollection alloc] init];
            }

            [matches addObject:testString];
        }
    }

    return matches;
}

@end
