//
//  HVArrayExtensions.m
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

#import "HVArrayExtensions.h"
#import "HVRandom.h"

@implementation NSArray (HVArrayExtensions)

-(NSRange) range
{
    return NSMakeRange(0, self.count);
}

-(NSUInteger) binarySearch:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    return [self indexOfObject:object inSortedRange:NSMakeRange(0, self.count) options:opts usingComparator:cmp];
}

+(BOOL) isNilOrEmpty:(NSArray *) array;
{
    return (array == nil || array.count == 0);
}

-(NSUInteger)indexOfMatchingObject:(HVFilter)filter
{
    if (filter)
    {
        for (NSUInteger i = 0, count = self.count; i < count; ++i)
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

@end

@implementation NSMutableArray (HVArrayExtensions)

+(NSMutableArray *) ensure:(NSMutableArray **)pArray
{
    if (!*pArray)
    {
        *pArray = [[NSMutableArray alloc] init];
    }
    
    return *pArray;
}

+(NSMutableArray *)fromEnumerator:(NSEnumerator *)enumerator
{
    NSMutableArray* array = [NSMutableArray array];
    [array addFromEnumerator:enumerator];
    return array;
}

-(void)addFromEnumerator:(NSEnumerator *)enumerator
{
    id obj;
    while ((obj = enumerator.nextObject) != nil)
    {
        [self addObject:obj];
    }
}

-(BOOL)isEmpty
{
    return (self.count == 0);
}

-(void)pushObject:(id)object
{
    [self addObject:object];
}

-(id)peek
{
    if (self.isEmpty)
    {
        return nil;
    }
    
    return [self lastObject];
}

-(id)popObject
{
    id popped = [self peek];
    if (popped)
    {
        popped = [[popped retain] autorelease];
        [self removeLastObject];
    }
    
    return popped;
}

-(void)enqueueObject:(id)object
{
    if (self.isEmpty)
    {
        [self addObject:object];
    }
    else 
    {
        [self insertObject:object atIndex:0];
    }
}

-(void)enqueueObject:(id)object maxQueueSize:(NSUInteger)size
{
    if (self.count >= size)
    {
        [self popObject];
    }
    
    [self enqueueObject:object];
}

-(id)dequeueObject
{
    return [self popObject];
}

@end
