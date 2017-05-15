//
//  MHVTypeViewThings.m
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

#import "MHVCommon.h"
#import "MHVTypeViewThings.h"

static NSString* const c_element_thing = @"thing";

@interface MHVTypeViewThings (MHVPrivate)

-(void) ensureOrdered;

@end


@implementation MHVTypeViewThings

-(NSUInteger) count
{
    return m_things.count;
}

-(NSDate*) maxDate
{
    if (m_things.count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:0].date;      
}

-(NSDate*) minDate
{
    NSUInteger count = m_things.count;
    if (count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:count - 1].date;
}

-(MHVTypeViewThing *)firstThing
{
    if (m_things.count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:0];    
}

-(MHVTypeViewThing *)lastThing
{
    NSUInteger count = m_things.count;
    if (count == 0)
    {
        return nil;
    }
    
    return [self objectAtIndex:count - 1];    
}

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_sorted = FALSE;
    
    m_things = [[NSMutableArray alloc] init];
    MHVCHECK_NOTNULL(m_things);
    
    m_thingsByID = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_thingsByID);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTypeViewThing *)objectAtIndex:(NSUInteger)index
{
    [self ensureOrdered];
    return [m_things objectAtIndex:index];
}

-(MHVTypeViewThing *)objectForThingID:(NSString *)thingID
{
    return [m_thingsByID objectForKey:thingID];
}

-(NSUInteger) indexOfThing:(MHVTypeViewThing *)thing
{
   // return [self searchForThing:thing withOptions:(NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual)];
    return [self searchForThing:thing withOptions:0];
}

-(NSUInteger) indexOfThingID:(NSString *)thingID
{
    MHVTypeViewThing* thing = [self objectForThingID:thingID];
    if (!thing)
    {
        return NSNotFound;
    }
    
    NSUInteger index =  [self indexOfThing:thing];
    if (index >= m_things.count)
    {
        index = NSNotFound;
    }
    
    return index;
}

-(NSUInteger) searchForThing:(MHVTypeViewThing *)thing withOptions:(NSBinarySearchingOptions)opts
{
    [self ensureOrdered];
        
    return [m_things indexOfObject:thing inSortedRange:NSMakeRange(0, m_things.count) options:opts usingComparator:^(id o1, id o2)
    {
        return [MHVTypeViewThing compare:o1 to:o2];
    }];
}

-(NSUInteger)searchForThing:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    [self ensureOrdered];
    
    return [m_things indexOfObject:object inSortedRange:NSMakeRange(0, m_things.count) options:opts usingComparator:cmp];
}

-(BOOL) addObject:(MHVTypeViewThing *)thing
{
    MHVCHECK_NOTNULL(thing);

    [m_things addObject:thing];
    m_sorted = FALSE;
    
    [m_thingsByID setObject:thing forKey:thing.thingID];
  
    return TRUE;

LError:
    return FALSE;
}

-(NSUInteger) insertThingInOrder:(MHVTypeViewThing *)thing
{
    if (!thing)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self searchForThing:thing withOptions:NSBinarySearchingInsertionIndex]; 
    if (index >= m_things.count)
    {
        [m_things addObject:thing];
    }
    else
    {
        [m_things insertObject:thing atIndex:index];
    }
    
    [m_thingsByID setObject:thing forKey:thing.thingID];
    
    return index;
}

-(NSUInteger) removeThing:(MHVTypeViewThing *)thing
{
    if (!thing)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self indexOfThing:thing];
    if (index != NSNotFound)
    {
        [self removeThingAtIndex:index];
    }
    
    return index;
}

-(NSUInteger) removeThingByID:(NSString *)thingID
{
    NSUInteger index = [self indexOfThingID:thingID];
    if (index != NSNotFound)
    {
        [self removeThingAtIndex:index];
    }
    
    return index;
}

-(void) removeThingAtIndex:(NSUInteger)index
{
    MHVTypeViewThing* thing = [m_things objectAtIndex:index];
    if (!thing)
    {
        return;
    }
    
    [m_things removeObjectAtIndex:index];
    [m_thingsByID removeObjectForKey:thing.thingID];
}

-(BOOL)replaceThingAt:(NSUInteger)index with:(MHVTypeViewThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    MHVTypeViewThing *existingThing = [self objectAtIndex:index];
    MHVCHECK_NOTNULL(existingThing);
    
    [m_thingsByID removeObjectForKey:existingThing.thingID];
    [m_things replaceObjectAtIndex:index withObject:thing];
    [m_thingsByID setObject:thing forKey:thing.thingID];
    
    m_sorted = FALSE;
    
    return TRUE;

LError:
    return FALSE;
}

-(MHVThingKeyCollection *)keysInRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    return [[MHVThingKeyCollection alloc] initWithArray:[m_things subarrayWithRange:range]];
}

-(NSArray *)selectIDsInRange:(NSRange)range
{
    [self ensureOrdered];
    [self correctRange:range];
    
    NSMutableArray *selection = [[NSMutableArray alloc] initWithCapacity:range.length];
    for (NSUInteger i = range.location, max = i + range.length; i < max; ++i)
    {
        MHVTypeViewThing* key = [m_things objectAtIndex:i];
        [selection addObject:key];
    }
    
    return selection;
}

-(NSMutableArray *)selectThingsNotIn:(MHVTypeViewThings *)keys
{
    NSMutableArray *keysNotFound = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0, count = self.count; i < count; ++i) 
    {
        MHVTypeViewThing* key = [self objectAtIndex:i];
        if (![keys contains:key])
        {
            [keysNotFound addObject:key];
        }
    }
    
    return keysNotFound;
    
LError:
    return nil;
}

-(NSRange)correctRange:(NSRange)range
{
    [self ensureOrdered];
    
    int max = (int)range.location + (int)range.length;
    if (max > m_things.count)
    {
        range = NSMakeRange(range.location, m_things.count - range.location);
    }    
    
    return range;
}

-(BOOL) contains:(MHVTypeViewThing *)thing
{
    return ([self indexOfThing:thing] != NSNotFound);
}

-(BOOL) containsID:(NSString *)thingID
{
    return ([self objectForThingID:thingID] != nil);
}

-(BOOL)addMHVThing:(MHVThing *)thing
{
    MHVTypeViewThing* dateKey = [[MHVTypeViewThing alloc] initWithMHVThing:thing];
    MHVCHECK_NOTNULL(dateKey);
    
    [self addObject:dateKey];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSUInteger)insertHVThingInOrder:(MHVThing *)thing
{
    MHVTypeViewThing* dateKey = [[MHVTypeViewThing alloc] initWithMHVThing:thing];
    if (!dateKey)
    {
        return NSNotFound;
    }
    
    NSUInteger index = [self insertThingInOrder:dateKey];
    
    return index;
}

-(BOOL)addPendingThing:(MHVPendingThing *)thing
{
    MHVTypeViewThing* dateKey = [[MHVTypeViewThing alloc] initWithPendingThing:thing];
    MHVCHECK_NOTNULL(dateKey);
 
    [self addObject:dateKey];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addHVThings:(MHVThingCollection *)things
{
    MHVCHECK_NOTNULL(things);
    
    for (MHVThing* thing in things)
    {
        MHVCHECK_SUCCESS([self addMHVThing:thing]);
    }
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addPendingThings:(MHVPendingThingCollection *)things
{
    MHVCHECK_NOTNULL(things);
    
    for (MHVPendingThing* thing in things)
    {
        MHVCHECK_SUCCESS([self addPendingThing:thing]);
    }
    return TRUE;
    
LError:
    return FALSE;   
}

-(BOOL)addQueryResult:(MHVThingQueryResult *)result
{
    MHVCHECK_NOTNULL(result);
    
    if (result.hasThings)
    {
        MHVCHECK_SUCCESS([self addHVThings:result.things]);
    }
    if (result.hasPendingThings)
    {
        MHVCHECK_SUCCESS([self addPendingThings:result.pendingThings]);
    }
    
    return TRUE;

LError:
    return FALSE;
}

-(BOOL)updateMHVThing:(MHVThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    NSUInteger thingIndex = [self indexOfThingID:thing.thingID];
    if (thingIndex == NSNotFound)
    {
        return [self addMHVThing:thing];
    }
        
    MHVTypeViewThing* typeViewThing = [self objectAtIndex:thingIndex];
    //
    // Update version stamps if needed
    //
    if ([typeViewThing isVersion:thing.key.version])
    {
        return FALSE; // NO change. Same key.
    }
    
    MHVTypeViewThing *newThing = [[MHVTypeViewThing alloc] initWithMHVThing:thing];
    MHVCHECK_NOTNULL(newThing);
    
    [self replaceThingAt:thingIndex with:newThing];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_thing elements:m_things];
}

-(void) deserialize:(XReader *)reader
{
    m_things = [reader readElementArray:c_element_thing asClass:[MHVTypeViewThing class] andArrayClass:[NSMutableArray class]];
    //
    // Index array
    //
    [m_thingsByID removeAllObjects];
    for (MHVTypeViewThing* thing in m_things) 
    {
        [m_thingsByID setObject:thing forKey:thing.thingID];
    }
}

@end

@implementation MHVTypeViewThings (MHVPrivate)

-(void) ensureOrdered
{
    if (m_sorted)
    {
        return;
    }
    
    [m_things sortUsingComparator:^(id o1, id o2) {
        return [MHVTypeViewThing compare:o1 to:o2];
    }];
    
    
    m_sorted = TRUE;
}

@end
