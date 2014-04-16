//
//  HVLockTable.h
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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

@class HVLockTable;

//
// This lock will automatically release itself when the object is deallocated
//
@interface HVAutoLock : NSObject
{
@private
    long m_lockID;
    HVLockTable* m_lockTable;
    NSString* m_key;
}

@property (readonly, nonatomic) long lockID;
@property (readonly, nonatomic) NSString* key;

-(BOOL) validateLock;
-(void) releaseLock;

@end

@interface HVLockTable : NSObject
{
@private
    NSMutableDictionary* m_locks;
    long m_nextLockId;
}

-(NSArray *) allLockedKeys;
-(BOOL) isKeyLocked:(NSString *) key;

-(BOOL) validateLock:(long) lockID forKey:(NSString *) key;
-(long) acquireLockForKey:(NSString *) key;
-(BOOL) releaseLock:(long) lockID forKey:(NSString *) key;

// Returns nil if lock was not acquired
-(HVAutoLock *) newAutoLockForKey:(NSString *) key;
-(BOOL) validateLock:(HVAutoLock *) lock;

-(NSString *) descriptionOfLockForKey:(NSString *) key;
+(BOOL) isValidLockId:(long) lockID;

@end
