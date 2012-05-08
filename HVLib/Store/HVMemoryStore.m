//
//  HVMemoryStore.m
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
#import "HVMemoryStore.h"

@implementation HVMemoryStore

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_store = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_store);
    
    m_metadata = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_metadata);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_store release];
    [m_metadata release];
    
    [super dealloc];
}

-(NSEnumerator *)allKeys
{
    return [m_store keyEnumerator];
}

-(BOOL)keyExists:(NSString *)key
{
    return ([m_store objectForKey:key] != nil);
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
    HVCHECK_NOTNULL(key);
    
    [m_store setObject:blob forKey:key];
    [self touchObjectWithKey:key];
    
    return TRUE;

LError:
    return FALSE;
}

-(BOOL)putObject:(id)obj withKey:(NSString *)key andName:(NSString *)name
{
    HVCHECK_NOTNULL(key);
    
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
-(id<HVObjectStore>)newChildStore:(NSString *)name
{
    return [[HVMemoryStore alloc] init];
}

@end
