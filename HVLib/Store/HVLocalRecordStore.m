//
//  HVLocalRecordStore.m
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
#import "HVLocalRecordStore.h"
#import "HVTypeView.h"
#import "HVSynchronizedStore.h"
#import "HVCachingObjectStore.h"
#import "HVStoredQuery.h"

static NSString* const c_view = @"view";
static NSString* const c_personalImage = @"personalImage";
static NSString* const c_storedQuery = @"storedQuery";

@interface HVLocalRecordStore (HVPrivate)

-(NSString *) makeViewKey:(NSString *) name;
-(NSString *) makeStoredQueryKey:(NSString *) name;

@end

@implementation HVLocalRecordStore

@synthesize root = m_root;
@synthesize record = m_record;
@synthesize metadata = m_metadata;
@synthesize data = m_data;

-(id)initForRecord:(HVRecordReference *)record overRoot:(id<HVObjectStore>)root
{
    return [self initForRecord:record overRoot:root withCache:FALSE];
}

-(id)initForRecord:(HVRecordReference *)record overRoot:(id<HVObjectStore>)root withCache:(BOOL)cache
{
    HVCHECK_NOTNULL(record);
    HVCHECK_NOTNULL(root);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_root = [root newChildStore:record.ID];
    HVCHECK_NOTNULL(m_root);
    
    m_metadata = [m_root newChildStore:[HVLocalRecordStore metadataStoreKey]];
    HVCHECK_NOTNULL(m_metadata);
    
    id<HVObjectStore> dataStore = [m_root newChildStore:[HVLocalRecordStore dataStoreKey]];
    HVCHECK_NOTNULL(dataStore);
    
    if (cache)
    {
        id<HVObjectStore> cachingDataStore = [[HVCachingObjectStore alloc] initWithObjectStore:dataStore];
        [dataStore release];
        HVCHECK_NOTNULL(cachingDataStore);
        
        dataStore = cachingDataStore;
    }
    
    m_data = [[HVSynchronizedStore alloc] initOverStore:dataStore];
    [dataStore release];
    
    HVCHECK_NOTNULL(m_data);
    
    HVRETAIN(m_record, record);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_record release];
    [m_root release];
    [m_metadata release];
    [m_data release];
    [super dealloc];
}

-(HVTypeView *)getView:(NSString *)name
{
    HVTypeView* view = [m_metadata getObjectWithKey:[self makeViewKey:name] name:c_view andClass:[HVTypeView class]];
    if (view)
    {
        view.store = self;
    }
    return view;
}

-(BOOL)putView:(HVTypeView *)view name:(NSString *)name
{
    return [m_metadata putObject:view withKey:[self makeViewKey:name] andName:c_view];
}

-(void)deleteView:(NSString *)name
{
    [m_metadata deleteKey:[self makeViewKey:name]];
}

-(NSData *)getPersonalImage
{
    return [m_metadata getBlob:c_personalImage];
}

-(BOOL) putPersonalImage:(NSData *)imageData
{
    return [m_metadata putBlob:imageData withKey:c_personalImage];
}

-(void)deletePersonalImage
{
    [m_metadata deleteKey:c_personalImage];
}

-(HVStoredQuery *)getStoredQuery:(NSString *)name
{
    HVStoredQuery* storedQuery = [m_metadata getObjectWithKey:[self makeStoredQueryKey:name] 
                                                                name:c_storedQuery 
                                                                andClass:[HVStoredQuery class]];
 
    return storedQuery;    
}

-(BOOL)putStoredQuery:(HVStoredQuery *)query withName:(NSString *)name
{
    return [m_metadata putObject:query withKey:[self makeStoredQueryKey:name] andName:c_storedQuery];
}

-(void)deleteStoredQuery:(NSString *)name
{
    [m_metadata deleteKey:[self makeStoredQueryKey:name]];    
}

+(NSString *)metadataStoreKey
{
    return @"Metadata";
}

+(NSString *)dataStoreKey
{
    return @"Data";
}

@end

@implementation HVLocalRecordStore (HVPrivate)

-(NSString *)makeViewKey:(NSString *)name
{
    return [name stringByAppendingString:c_view];
}

-(NSString *)makeStoredQueryKey:(NSString *)name
{
    return [name stringByAppendingString:c_storedQuery];    
}

@end
