//
//  MHVTypeViewThings.h
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

#import <Foundation/Foundation.h>
#import "MHVTypeViewThing.h"
#import "XLib.h"

//-------------------------------------
//
// An ORDERED collection of MHVTypeViewThing
// The sort order is:
//  - MHVTypeView.date [descending]
//  THEN MHVTypeView.thingID [ascending]
//
// Matches the default sort order of HealthVault query results
//
// Also maintains a reverse index of ThingID --> the thing's position.
//
//-----------------------------------
@interface MHVTypeViewThings : XSerializableType
{
    BOOL m_sorted;
    NSMutableArray *m_things;
    NSMutableDictionary *m_thingsByID;
}

@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic, strong) NSDate* maxDate;
@property (readonly, nonatomic, strong) NSDate* minDate;
@property (readonly, nonatomic, strong) MHVTypeViewThing* firstThing;
@property (readonly, nonatomic, strong) MHVTypeViewThing* lastThing;

-(MHVTypeViewThing *) objectAtIndex:(NSUInteger) index;
-(MHVTypeViewThing *) objectForThingID:(NSString *) thingID;

-(NSUInteger) searchForThing:(MHVTypeViewThing *)thing withOptions:(NSBinarySearchingOptions) opts;
-(NSUInteger) searchForThing:(id)object options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;

-(BOOL) contains:(MHVTypeViewThing *) thing;
-(BOOL) containsID:(NSString *) thingID;

-(NSUInteger) indexOfThing:(MHVTypeViewThing *) thing;
-(NSUInteger) indexOfThingID:(NSString *) thingID;

-(BOOL) addObject:(MHVTypeViewThing *) thing;
-(NSUInteger) insertThingInOrder:(MHVTypeViewThing *) thing;
-(NSUInteger) removeThing:(MHVTypeViewThing *) thing;
-(void) removeThingAtIndex:(NSUInteger) index;
-(NSUInteger) removeThingByID:(NSString *) thingID;
-(BOOL) replaceThingAt:(NSUInteger) index with:(MHVTypeViewThing *) thing;

-(MHVThingKeyCollection *)keysInRange:(NSRange)range;
-(NSArray *) selectIDsInRange:(NSRange) range;
-(NSRange) correctRange:(NSRange) range;
-(NSMutableArray*) selectThingsNotIn:(MHVTypeViewThings *) things;

//
// Adds an thing into the collection using information taken from MHVThing
// Returns true if collection updated
//
-(BOOL) addMHVThing:(MHVThing *) thing;
-(BOOL) addHVThings:(MHVThingCollection *) things;
//
// Adds an thing into the collection using information taken from MHVThing
// Maintains the sort order - so a full sort is not required. 
// 
-(NSUInteger) insertHVThingInOrder:(MHVThing *) thing;
//
// Returns true if an update to the collection was necessary, and made.
// If thing not found, or no change made, returns false If the thing does not exist, will add it
//
-(BOOL) updateMHVThing:(MHVThing *) thing;
//
// Adds an thing into the collection using information taken from MHVPendingThing
// Returns true if collection updated
//
-(BOOL) addPendingThing:(MHVPendingThing *) thing;
-(BOOL) addPendingThings:(MHVPendingThingCollection *) things;
//
// Adds things into the collection using information taken from MHVThingQueryResult
// Returns true if collection updated
//
-(BOOL) addQueryResult:(MHVThingQueryResult *) result;

@end
