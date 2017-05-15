//
//  MHVLocalThingStore.m
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
#import "MHVLocalThingStore.h"

static NSString* const c_root = @"thing";

@interface MHVLocalThingStore (MHVPrivate)

-(void) setObjectStore:(id<MHVObjectStore>) store;

@end

@implementation MHVLocalThingStore

@synthesize objectStore = m_objectStore;

-(id) init
{
    return [self initWithObjectStore:nil];
}

-(id)initWithObjectStore:(id<MHVObjectStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.objectStore = store;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSEnumerator *)allKeys
{
    @synchronized(m_objectStore)
    {
        return [m_objectStore allKeys];
    }
}

-(BOOL)existsThing:(NSString *)thingID
{
    @synchronized(m_objectStore)
    {
        return [m_objectStore keyExists:thingID];
    }
}

-(MHVThing *)getThing:(NSString *)thingID
{
    @synchronized(m_objectStore)
    {
        return [m_objectStore getObjectWithKey:thingID name:c_root andClass:[MHVThing class]];       
    }
}

-(BOOL)putThing:(MHVThing *)thing
{
    @synchronized(m_objectStore)
    {
        return [m_objectStore putObject:thing withKey:thing.thingID andName:c_root];
    }
}

-(void)removeThing:(NSString *)thingID
{
    @synchronized(m_objectStore)
    {
        [m_objectStore deleteKey:thingID];
    }
}

-(MHVThing *)refreshAndGetThing:(NSString *)thingID
{
    @synchronized(m_objectStore)
    {
        return [m_objectStore refreshAndGetObjectWithKey:thingID name:c_root andClass:[MHVThing class]]; 
    }
}

-(void)clearCache
{
    @synchronized(m_objectStore)
    {
        if ([m_objectStore respondsToSelector:@selector(clearCache)])
        {
            [m_objectStore performSelector:@selector(clearCache)];
        }
    }
}

-(void)deleteKeyFromCache:(NSString *)thingID
{
    @synchronized(m_objectStore)
    {
        if ([m_objectStore respondsToSelector:@selector(deleteKeyFromCache:)])
        {
            [m_objectStore performSelector:@selector(deleteKeyFromCache:) withObject:thingID];
        }
    }    
}

-(void)setCacheLimitCount:(NSInteger)cacheSize
{
    @synchronized(m_objectStore)
    {
        if ([m_objectStore respondsToSelector:@selector(setCacheLimitCount:)])
        {
            [m_objectStore performSelector:@selector(setCacheLimitCount:) withObject:[NSNumber numberWithInteger:cacheSize]];
        }
    }    
}

@end

@implementation MHVLocalThingStore (MHVPrivate)

-(void)setObjectStore:(id<MHVObjectStore>)store
{
    m_objectStore = store;
}

@end
