//
//  HVStringCollection.m
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

#import "HVCommon.h"
#import "HVCollection.h"

@implementation HVCollection

@synthesize type = m_type;

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_inner = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_inner);
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    HVCHECK_SELF;
    
    m_inner = [[NSMutableArray alloc] initWithCapacity:numItems];
    HVCHECK_NOTNULL(m_inner);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_inner release];
    [m_type release];
    [super dealloc];
}

-(NSUInteger) count
{
    return [m_inner count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [m_inner objectAtIndex:index];
}

-(void) addObject:(id)anObject
{
    [self validateNewObject:anObject];
    [m_inner addObject:anObject];
}

-(void) insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self validateNewObject:anObject];
    [m_inner insertObject:anObject atIndex:index];
}

-(void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self validateNewObject:anObject];
    [m_inner replaceObjectAtIndex:index withObject:anObject];
}

-(void) removeObjectAtIndex:(NSUInteger)index
{
    [m_inner removeObjectAtIndex:index];
}

-(void) removeLastObject
{
    [m_inner removeLastObject];
}

-(void) validateNewObject:(id)obj
{
    if (obj == nil)
    {
        [NSException throwInvalidArg];
    }
    if (m_type)
    {
        if (!IsNsNull(obj) && ![obj isKindOfClass:m_type])
        {
            [NSException throwInvalidArgWithReason:[NSString stringWithFormat:@"%@ expected", [m_type description]]];
        }
    }
}

-(NSString *)toString
{
    if (self.count == 0)
    {
        return c_emptyString;
    }
    
    NSMutableString* text = [[[NSMutableString alloc] init] autorelease];
    
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        id obj = [self objectAtIndex:i];
        NSString* descr = [obj description];
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


-(NSString *)description
{
    return [self toString];
}

@end

@implementation HVStringCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [NSString class];
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(BOOL) containsString:(NSString *)value
{
    return ([self indexOfString:value] != NSNotFound);
}

-(NSUInteger) indexOfString:(NSString *)value
{
    return [self indexOfString:value startingAt:0];
}

-(NSUInteger) indexOfString:(NSString *)value startingAt:(NSUInteger)index
{
    HVCHECK_NOTNULL(value);
    
    for (NSUInteger i = index, count = m_inner.count; i < count; ++i)
    {
        if ([[m_inner objectAtIndex:i] isEqualToString:value])
        {
            return i;
        }
    }
    
LError:
    return NSNotFound;    
}

-(BOOL) removeString:(NSString *)value
{
    HVCHECK_NOTNULL(value);
    
    NSUInteger index = [self indexOfString:value];
    if (index == NSNotFound)
    {
        goto LError;
    }
    
    [self removeObjectAtIndex:index];
    return TRUE;
    
LError:
    return FALSE;
}

-(HVStringCollection *)selectStringsFoundInSet:(NSArray *)testSet
{
    HVStringCollection* matches = nil;
    for (int i = 0, count = testSet.count; i < count; ++i)
    {
        NSString* testString = [testSet objectAtIndex:i];
        if ([self containsString:testString]) 
        {
            if (!matches)
            {
                matches = [[[HVStringCollection alloc] init] autorelease];
            }
            [matches addObject:testString];
        }
    }
    
    return matches;
}

-(HVStringCollection *)selectStringsNotFoundInSet:(NSArray *)testSet
{
    HVStringCollection* matches = nil;
    for (int i = 0, count = testSet.count; i < count; ++i)
    {
        NSString* testString = [testSet objectAtIndex:i];
        if (![self containsString:testString]) 
        {
            if (!matches)
            {
                matches = [[[HVStringCollection alloc] init] autorelease];
            }
            [matches addObject:testString];
        }
    }
    
    return matches;    
}

@end
