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

@end