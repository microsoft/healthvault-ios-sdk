//
//  HVLockTable.m
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
//

#import "HVCommon.h"
#import "HVLockTable.h"

static const long c_lockNotAcquired = 0;

@interface HVLock : NSObject
{
@private
    long m_lockID;
#ifdef DEBUG
    NSDate* m_timestamp;
#endif
}

@property (readonly, nonatomic) long lockID;
#ifdef DEBUG
@property (readonly, nonatomic) NSDate* timestamp;
#endif

-(id) initWithID:(long) lockID;
-(BOOL) isLock:(long) lockID;

@end

@implementation HVLock

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
    HVCHECK_TRUE(lockID > c_lockNotAcquired);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_lockID = lockID;
#ifdef DEBUG
    m_timestamp = [[NSDate date] retain];
#endif
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
#ifdef DEBUG
    [m_timestamp release];
#endif
    [super dealloc];
}

-(BOOL) isLock:(long)lockID
{
    return (lockID == m_lockID);
}

-(NSString *)description
{
    NSMutableString* string = [[[NSMutableString alloc] init] autorelease];
    [string appendFormat:@"LockID=%ld", m_lockID];
#ifdef DEBUG
    [string appendFormat:@", Timestamp=%@", m_timestamp];
#endif
    return string;
}

@end

@interface HVAutoLock (HVPrivate)

-(id) initWithLockTable:(HVLockTable *) lockTable key:(NSString *) key andLockID:(long) lockID;

@end

@implementation HVAutoLock

@synthesize lockID = m_lockID;
@synthesize key  = m_key;

-(id)init
{
    return [self initWithLockTable:nil key:nil andLockID:0];
}

-(void)dealloc
{
    [self releaseLock];
    [m_key release];
    [m_lockTable release];
    
    [super dealloc];
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

@implementation HVAutoLock (HVPrivate)

-(id)initWithLockTable:(HVLockTable *)lockTable key:(NSString *)key andLockID:(long)lockID
{
    HVCHECK_NOTNULL(lockTable);
    HVCHECK_NOTNULL(key);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_lockID = lockID;
    HVRETAIN(m_key, key);
    HVRETAIN(m_lockTable, lockTable);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end

@interface HVLockTable (HVPrivate)

-(BOOL) validateLock:(HVLock *) lock isLock:(long) lockID;
-(HVLock *) lockForKey:(NSString *)key;
-(void) setLock:(HVLock *) lock forKey:(NSString *) key;
-(long) nextLockID;

@end


@implementation HVLockTable

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_locks = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_locks);
    
    m_nextLockId = c_lockNotAcquired;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_locks release];
    [super dealloc];
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
    if (![HVLockTable isValidLockId:lockID])
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
        HVCHECK_STRING(key);
        
        if ([self lockForKey:key] == nil)
        {
            long lockId = [self nextLockID];
            HVLock* lock = [[HVLock alloc] initWithID:lockId];
            HVCHECK_NOTNULL(lock);
            
            [self setLock:lock forKey:key];
            [lock release];
            
            return lockId;
        }
        
    LError:
        return c_lockNotAcquired;
    }
}

-(BOOL) releaseLock:(long)lockID forKey:(NSString *)key
{
    @synchronized(m_locks)
    {
        HVLock* existingLock = [self lockForKey:key];
        HVCHECK_SUCCESS([self validateLock:existingLock isLock:lockID]);
        
        [m_locks removeObjectForKey:key];
        return TRUE;
        
    LError:
        return FALSE;
    }
}

-(HVAutoLock *)newAutoLockForKey:(NSString *)key
{
    long lockID = [self acquireLockForKey:key];
    if (lockID <= c_lockNotAcquired)
    {
        return nil;
    }
    
    HVAutoLock* lock = [[HVAutoLock alloc] initWithLockTable:self key:key andLockID:lockID];
    HVCHECK_NOTNULL(lock);
    
    return lock;
    
LError:
    [self releaseLock:lockID forKey:key];
    return nil;
}

-(BOOL)validateLock:(HVAutoLock *)lock
{
    HVCHECK_NOTNULL(lock);
    
    return [self validateLock:lock.lockID forKey:lock.key];
    
LError:
    return FALSE;
}

-(NSString *)descriptionOfLockForKey:(NSString *)key
{
    @synchronized(m_locks)
    {
        HVLock* existingLock = [self lockForKey:key];
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

@implementation HVLockTable (HVPrivate)

-(BOOL)validateLock:(HVLock *)lock isLock:(long)lockID
{
    return (lock != nil && [lock isLock:lockID]);
}

-(HVLock *)lockForKey:(NSString *)key
{
    return [m_locks objectForKey:key];
}

-(void)setLock:(HVLock *)lock forKey:(NSString *)key
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

