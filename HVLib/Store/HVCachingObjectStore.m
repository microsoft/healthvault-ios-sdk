//
//  HVCachingObjectStore.m
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
//
#import "HVCommon.h"
#import "HVCachingObjectStore.h"

@interface HVCachingObjectStore (HVPrivate)

-(void) cacheObject:(id) obj forKey:(id) key;

@end

@implementation HVCachingObjectStore

-(void)dealloc
{
    [m_cache release];
    [m_inner release];
    
    [super dealloc];
}

-(id)initWithObjectStore:(id<HVObjectStore>)store
{
    HVCHECK_NOTNULL(store);
    
    m_cache = [[NSCache alloc] init];
    HVCHECK_NOTNULL(m_cache);
    
    m_inner = [store retain];
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(NSEnumerator *)allKeys
{
    return [m_inner allKeys];
}

-(NSDate *) createDateForKey:(NSString *) key
{
    return [m_inner createDateForKey:key];
}

-(NSDate *) updateDateForKey:(NSString *) key
{
    return [m_inner updateDateForKey:key];
}

-(BOOL) keyExists:(NSString *) key
{
    @synchronized(self)
    {
        if ([m_cache objectForKey:key] != nil)
        {
            return TRUE;
        }
        
        return [m_inner keyExists:key];
    }
}

-(BOOL) deleteKey:(NSString *) key
{
    @synchronized(self)
    {
        [m_cache removeObjectForKey:key];
        return [m_inner deleteKey:key];
    }
}

-(id)getObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    @synchronized(self)
    {
        id obj = [m_cache objectForKey:key];
        if (!obj)
        {
            obj = [m_inner getObjectWithKey:key name:name andClass:cls];
            [self cacheObject:obj forKey:key];
        }
        
        return obj;
    }
}

-(BOOL) putObject:(id) obj withKey:(NSString *) key andName:(NSString *) name
{
    @synchronized(self)
    {
        [m_cache removeObjectForKey:key];
        if (![m_inner putObject:obj withKey:key andName:name])
        {
            return FALSE;
        }
        [self cacheObject:obj forKey:key];
 
        return TRUE;
    }
}

-(NSData *) getBlob:(NSString *) key
{
    @synchronized(self)
    {
        NSData* blob = [m_cache objectForKey:key];
        if (!blob)
        {
            blob = [m_inner getBlob:key];
            [self cacheObject:blob forKey:key];
        }
        
        return blob;
    }
}

-(BOOL) putBlob:(NSData *) blob withKey:(NSString *) key
{
    @synchronized(self)
    {
        [m_cache removeObjectForKey:key];
        if (![m_inner putBlob:blob withKey:key])
        {
            return FALSE;
        }
        
        [self cacheObject:blob forKey:key];
        return TRUE;
    }
}

-(id<HVObjectStore>) newChildStore:(NSString *) name
{
    // Child store is NOT caching. 
    return [m_inner newChildStore:name];
}

-(void)deleteChildStore:(NSString *)name
{
    // Child store is NOT caching. 
    return [m_inner deleteChildStore:name];
}

-(BOOL)childStoreExists:(NSString *)name
{
    return [m_inner childStoreExists:name];
}

-(NSEnumerator *)allChildStoreNames
{
    return [m_inner allChildStoreNames];
}

-(id)refreshAndGetObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    [self deleteKeyFromCache:key];
    return [self getObjectWithKey:key name:name andClass:cls];
}

-(NSData *)refreshAndGetBlob:(NSString *)key
{
    [self deleteKeyFromCache:key];
    return [self getBlob:key];
}

-(void)deleteKeyFromCache:(NSString *)key
{
    @synchronized(self)
    {
        [m_cache removeObjectForKey:key];
    }
}

-(void)clear
{
    [self clearCache];
}

-(void)clearCache
{
    @synchronized(self)
    {
        [m_cache removeAllObjects];
    }
}

-(void)setCacheLimitCount:(NSNumber *)count
{
    if (!count)
    {
        return;
    }
    
    @synchronized(self)
    {
        [m_cache setCountLimit:count.integerValue];
    }    
}

-(void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSLog(@"Evicting %@", obj);
}

@end

@implementation HVCachingObjectStore (HVPrivate)

-(void)cacheObject:(id)obj forKey:(id)key
{
    if (obj)
    {
        [m_cache setObject:obj forKey:key];
    }
}

@end
