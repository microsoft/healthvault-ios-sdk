//
// NSArray+Utils.m
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

#import "NSArray+Utils.h"
#import "MHVValidator.h"

@implementation NSArray (Utils)

- (NSArray*)arrayOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	NSIndexSet *indexSet = [self indexesOfObjectsPassingTest:predicate];
	return [self objectsAtIndexes:indexSet];
}

- (NSArray *)convertAll:(id (^)(id obj))converter
{
    MHVASSERT_PARAMETER(converter);
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for (id object in self)
    {
        [array addObject:converter(object)];
    }
    
    return array;
}

- (NSArray *)map:(id (^)(id obj, NSUInteger idx, BOOL *stop))mapper
{
    NSMutableArray *mappedArray = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mappedArray addObject:mapper(obj, idx, stop)];
    }];

    return mappedArray;
}

- (double)averageOfValues
{
    //Avoid /0 below
    if (self.count == 0)
    {
        return 0;
    }
    
    float sum = 0;
    for (NSNumber *number in self)
    {
        MHVASSERT_TRUE([number isKindOfClass:[NSNumber class]], @"Only NSNumbers are supported for averageOfValues!");
        
        sum += [number doubleValue];
    }
    
    return (sum / (double)self.count);
}

- (NSArray *)arrayWithUniqueValues
{
    return [[[NSSet new] setByAddingObjectsFromArray:self] allObjects];
}

- (NSArray *)arrayAlphabeticallySortedAscending:(BOOL)ascending
{
    NSSortDescriptor *alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending];
    return [self sortedArrayUsingDescriptors:@[alphabeticalSort]];
}

- (NSArray *)arrayWithSortedValuesUsingSortDescriptor:(NSSortDescriptor *)sd
{
    return [self sortedArrayUsingDescriptors:@[sd]];
}

- (NSArray *)arrayWithUniqueAlphabeticallySortedValues:(BOOL)ascending
{
    NSSortDescriptor *alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending];
    NSSet *uniqueValues = [[NSSet new] setByAddingObjectsFromArray:self];
    return [uniqueValues sortedArrayUsingDescriptors:@[alphabeticalSort]];
}

- (NSArray *)arrayByRemovingObject:(id)object
{
    NSMutableArray *array = [self mutableCopy];
    [array removeObject:object];
    return array;
}

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString
{
    return [self indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop)
            {
                return [[obj lowercaseString] isEqualToString:[aString lowercaseString]];
            }];
}

- (BOOL)areAllObjectsOfClass:(Class)theClass
{
    for (id object in self)
    {
        if (![object isKindOfClass:theClass])
        {
            return NO;
        }
    }
    return YES;
}

@end
