//
//  MHVThingChangeTable.h
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
//

#import <Foundation/Foundation.h>
#import "MHVThingChange.h"
#import "MHVPartitionedStore.h"

@class MHVThingChangeQueue;

@interface MHVThingChangeTable : NSObject
{
@private
    MHVPartitionedObjectStore* m_store;
}

-(id) initWithObjectStore:(id<MHVObjectStore>) store;

-(BOOL) hasChangesForTypeID:(NSString *) typeID thingID:(NSString *) thingID;
-(BOOL) hasChangesForTypeID:(NSString *) typeID;
-(BOOL) hasChanges;

// Returns the change ID, if one was assigned
-(NSString *) trackChange:(enum MHVThingChangeType) changeType forTypeID:(NSString *) typeID andKey:(MHVThingKey *) key;

// An array of MHVThingChangeQueueEntry in order
-(MHVThingChangeQueue *) getQueue;
-(MHVThingChangeQueue *) getQueueForTypeID:(NSString *)typeID;
-(NSMutableArray *) getAll;

-(NSMutableArray *) getAllTypesWithChanges;
-(MHVThingChange *) getForTypeID:(NSString *) typeID thingID:(NSString *) thingID;
-(BOOL) put:(MHVThingChange *) change;
-(BOOL) removeForTypeID:(NSString *) typeID thingID:(NSString *) thingID;

-(void) removeAll;
-(BOOL) removeAllForTypeID:(NSString *) typeID;

@end

//-------------------------------------------
//
// MHVThingChangeQueue
//
//-------------------------------------------
@interface MHVThingChangeQueue : NSEnumerator
{
@private
    MHVThingChangeTable* m_changeTable;
    NSMutableArray* m_types;
    NSString* m_currentType;
    NSMutableArray* m_currentQueue;
}

-(id)initWithChangeTable:(MHVThingChangeTable *)changeTable andChangedTypes:(NSMutableArray *) types;

-(MHVThingChange *) nextChange;

@end
