//
//  MHVItemChangeTable.h
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
#import "MHVItemChange.h"
#import "MHVPartitionedStore.h"

@class MHVItemChangeQueue;

@interface MHVItemChangeTable : NSObject
{
@private
    MHVPartitionedObjectStore* m_store;
}

-(id) initWithObjectStore:(id<MHVObjectStore>) store;

-(BOOL) hasChangesForTypeID:(NSString *) typeID itemID:(NSString *) itemID;
-(BOOL) hasChangesForTypeID:(NSString *) typeID;
-(BOOL) hasChanges;

// Returns the change ID, if one was assigned
-(NSString *) trackChange:(enum HVItemChangeType) changeType forTypeID:(NSString *) typeID andKey:(MHVItemKey *) key;

// An array of HVItemChangeQueueEntry in order
-(MHVItemChangeQueue *) getQueue;
-(MHVItemChangeQueue *) getQueueForTypeID:(NSString *)typeID;
-(NSMutableArray *) getAll;

-(NSMutableArray *) getAllTypesWithChanges;
-(MHVItemChange *) getForTypeID:(NSString *) typeID itemID:(NSString *) itemID;
-(BOOL) put:(MHVItemChange *) change;
-(BOOL) removeForTypeID:(NSString *) typeID itemID:(NSString *) itemID;

-(void) removeAll;
-(BOOL) removeAllForTypeID:(NSString *) typeID;

@end

//-------------------------------------------
//
// MHVItemChangeQueue
//
//-------------------------------------------
@interface MHVItemChangeQueue : NSEnumerator
{
@private
    MHVItemChangeTable* m_changeTable;
    NSMutableArray* m_types;
    NSString* m_currentType;
    NSMutableArray* m_currentQueue;
}

-(id)initWithChangeTable:(MHVItemChangeTable *)changeTable andChangedTypes:(NSMutableArray *) types;

-(MHVItemChange *) nextChange;

@end
