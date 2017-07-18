//
// MHVArrayExtensions.m
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

#import "MHVArrayExtensions.h"
#import "MHVValidator.h"

@implementation NSArray (MHVArrayExtensions)

+ (BOOL)isNilOrEmpty:(NSArray *)array;
{
    return array == nil || array.count == 0;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)array atStartingIndex:(NSUInteger)startingIndex
{
    if (!array)
    {
        return self;
    }
    
    if (startingIndex > self.count)
    {
        startingIndex = self.count;
    }
    
    NSMutableArray *copy = [self mutableCopy];
    
    for (int i = 0; i < array.count; i++)
    {
        id obj = array[i];

        [copy insertObject:obj atIndex:startingIndex + i];
    }
    
    return copy;
}

- (BOOL)hasElementsOfType:(Class)type
{
    for (id obj in self)
    {
        if (![self validateObject:obj isType:type])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateObject:(id)obj isType:(Class)type
{
    if (!obj)
    {
        MHVASSERT_PARAMETER(obj);
        return NO;
    }
    
    if (type)
    {
        if (obj != [NSNull null] && ![obj isKindOfClass:type])
        {
            NSString *message = [NSString stringWithFormat:@"%@ expected", NSStringFromClass(type)];
            MHVASSERT_MESSAGE(message);
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation NSMutableArray (MHVArrayExtensions)

- (void)addFromEnumerator:(NSEnumerator *)enumerator
{
    id obj;

    while ((obj = enumerator.nextObject) != nil)
    {
        [self addObject:obj];
    }
}

@end
