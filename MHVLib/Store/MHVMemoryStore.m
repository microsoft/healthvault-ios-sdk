//
//  MHVMemoryStore.m
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
#import "MHVMemoryStore.h"

@implementation MHVMemoryStore

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_store = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_store);
    
    m_metadata = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_metadata);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSEnumerator *)allKeys
{
    return [m_store keyEnumerator];
}

-(BOOL)keyExists:(NSString *)key
{
    return ([m_store objectForKey:key] != nil);
}

-(NSDate *)createDateForKey:(NSString *)key
{
    // Not exactly accurate, but this is a test store..
    return [m_metadata objectForKey:key];
}

-(NSDate *)updateDateForKey:(NSString *)key
{
    return [m_metadata objectForKey:key];
}

-(id)getObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    id obj = [m_store objectForKey:key];
    if (obj && [obj isKindOfClass:cls])
    {
        return obj;
    }
    
    return nil;
}

-(NSData *)getBlob:(NSString *)key
{
    id obj = [m_store objectForKey:key];
    if (obj && [obj isKindOfClass:[NSData class]])
    {
        return obj;
    }
    
    return nil;   
}

-(BOOL)putBlob:(NSData *)blob withKey:(NSString *)key
{
    MHVCHECK_NOTNULL(key);
    
    [m_store setObject:blob forKey:key];
    [self touchObjectWithKey:key];
    
    return TRUE;

LError:
    return FALSE;
}

-(BOOL)putObject:(id)obj withKey:(NSString *)key andName:(NSString *)name
{
    MHVCHECK_NOTNULL(key);
    
    [m_store setObject:obj forKey:key];
    [self touchObjectWithKey:key];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)deleteKey:(NSString *)key
{
    [m_store removeObjectForKey:key];
    return TRUE;
}

-(void)touchObjectWithKey:(NSString *)key
{
    [m_metadata setObject:[NSDate date] forKey:key];
    
}

-(id<MHVObjectStore>)newChildStore:(NSString *)name
{
    return [[MHVMemoryStore alloc] init];
}

-(void)deleteChildStore:(NSString *)name
{
    // Not supported
    NSLog(@"Not supported");
}

-(BOOL)childStoreExists:(NSString *)name
{
    // Not supported
    NSLog(@"Not supported");
    return FALSE;
}

-(NSEnumerator *)allChildStoreNames
{
    // Not supported yet
    return nil;
}

-(id)refreshAndGetObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    return [self refreshAndGetObjectWithKey:key name:name andClass:cls];
}

-(NSData *)refreshAndGetBlob:(NSString *)key
{
    return [self getBlob:key];
}

@end
