//
//  MHVLockTable.m
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
//

#import "MHVCommon.h"
#import "MHVLockTable.h"

static const long c_lockNotAcquired = 0;

@interface MHVLock : NSObject
{
@private
    long m_lockID;
#ifdef DEBUG
    NSDate* m_timestamp;
#endif
}

@property (readonly, nonatomic) long lockID;
#ifdef DEBUG
@property (readonly, nonatomic, strong) NSDate* timestamp;
#endif

-(id) initWithID:(long) lockID;
-(BOOL) isLock:(long) lockID;

@end

@implementation MHVLock

@synthesize lockID = m_lockID;
#ifdef DEBUG
@synthesize timestamp = m_timestamp;
#endif
-(id) init
{
    return [self initWithID:c_lockNotAcquired];
}

-(id)initWithID:(long)lockID
{
    MHVCHECK_TRUE(lockID > c_lockNotAcquired);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_lockID = lockID;
#ifdef DEBUG
    m_timestamp = [NSDate date];
#endif
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL) isLock:(long)lockID
{
    return (lockID == m_lockID);
}

-(NSString *)description
{
    NSMutableString* string = [[NSMutableString alloc] init];
    [string appendFormat:@"LockID=%ld", m_lockID];
#ifdef DEBUG
    [string appendFormat:@", Timestamp=%@", m_timestamp];
#endif
    return string;
}

@end

@interface MHVAutoLock (MHVPrivate)

-(id) initWithLockTable:(MHVLockTable *) lockTable key:(NSString *) key andLockID:(long) lockID;

@end

@implementation MHVAutoLock

@synthesize lockID = m_lockID;
@synthesize key  = m_key;

- (id)init
{
    return [self initializeWithDefaultValues];
}

- (id)initializeWithDefaultValues
{
    return [self initWithLockTable:nil key:nil andLockID:0];    
}

-(void)dealloc
{
    [self releaseLock];
    
}

-(void)releaseLock
{
    if (m_lockID > c_lockNotAcquired)
    {
        [m_lockTable releaseLock:m_lockID forKey:m_key];
        m_lockID = c_lockNotAcquired;
    }
}

-(BOOL)validateLock
{
    return [m_lockTable validateLock:self];
}

@end

@implementation MHVAutoLock (MHVPrivate)

-(id)initWithLockTable:(MHVLockTable *)lockTable key:(NSString *)key andLockID:(long)lockID
{
    MHVCHECK_NOTNULL(lockTable);
    MHVCHECK_NOTNULL(key);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_lockID = lockID;
    m_key = key;
    m_lockTable = lockTable;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

@end

@interface MHVLockTable (MHVPrivate)

-(BOOL) validateLock:(MHVLock *) lock isLock:(long) lockID;
-(MHVLock *) lockForKey:(NSString *)key;
-(void) setLock:(MHVLock *) lock forKey:(NSString *) key;
-(long) nextLockID;

@end


@implementation MHVLockTable

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_locks = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_locks);
    
    m_nextLockId = c_lockNotAcquired;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSArray *)allLockedKeys
{
    @synchronized(m_locks)
    {
        return [m_locks allKeys];
    }
}

-(BOOL)isKeyLocked:(NSString *)key
{
    @synchronized(m_locks)
    {
        return ([self lockForKey:key] != nil);
    }
}

-(BOOL)validateLock:(long)lockID forKey:(NSString *)key
{
    if (![MHVLockTable isValidLockId:lockID])
    {
        return FALSE;
    }
    
    @synchronized(m_locks)
    {
        return [self validateLock:[self lockForKey:key] isLock:lockID];
    }
}

-(long)acquireLockForKey:(NSString *)key
{
    @synchronized(m_locks)
    {
        if ([NSString isNilOrEmpty:key])
        {
            return c_lockNotAcquired;
        }
        
        if ([self lockForKey:key] == nil)
        {
            long lockId = [self nextLockID];
            MHVLock* lock = [[MHVLock alloc] initWithID:lockId];
            if (!lock)
            {
                return c_lockNotAcquired;
            }
            
            [self setLock:lock forKey:key];
            
            return lockId;
        }
    }
    return c_lockNotAcquired;
}

-(BOOL) releaseLock:(long)lockID forKey:(NSString *)key
{
    @synchronized(m_locks)
    {
        MHVLock* existingLock = [self lockForKey:key];
        MHVCHECK_SUCCESS([self validateLock:existingLock isLock:lockID]);
        
        [m_locks removeObjectForKey:key];
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(MHVAutoLock *)newAutoLockForKey:(NSString *)key
{
    long lockID = [self acquireLockForKey:key];
    if (lockID <= c_lockNotAcquired)
    {
        return nil;
    }
    
    MHVAutoLock* lock = [[MHVAutoLock alloc] initWithLockTable:self key:key andLockID:lockID];
    if (!lock)
    {
        [self releaseLock:lockID forKey:key];
    }
    
    return lock;
}

-(BOOL)validateLock:(MHVAutoLock *)lock
{
    MHVCHECK_NOTNULL(lock);
    
    return [self validateLock:lock.lockID forKey:lock.key];
    
LError:
    return FALSE;
}

-(NSString *)descriptionOfLockForKey:(NSString *)key
{
    @synchronized(m_locks)
    {
        MHVLock* existingLock = [self lockForKey:key];
        if (existingLock)
        {
            return existingLock.description;
        }
        return nil;
    }
}

+(BOOL)isValidLockId:(long)lockID
{
    return (lockID > c_lockNotAcquired);
}
@end

@implementation MHVLockTable (MHVPrivate)

-(BOOL)validateLock:(MHVLock *)lock isLock:(long)lockID
{
    return (lock != nil && [lock isLock:lockID]);
}

-(MHVLock *)lockForKey:(NSString *)key
{
    return [m_locks objectForKey:key];
}

-(void)setLock:(MHVLock *)lock forKey:(NSString *)key
{
    [m_locks setObject:lock forKey:key];
}

-(long)nextLockID
{
    if (m_nextLockId == (LONG_MAX - 1))
    {
        m_nextLockId = c_lockNotAcquired;
    }
    
    ++m_nextLockId;
    return m_nextLockId;
}

@end

