//
//  MHVLocalRecordStore.m
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
#import "MHVLocalRecordStore.h"
#import "MHVTypeView.h"
#import "MHVSynchronizedStore.h"
#import "MHVCachingObjectStore.h"
#import "MHVStoredQuery.h"
#import "MHVThingChangeManager.h"

static NSString* const c_view = @"view";
static NSString* const c_personalImage = @"personalImage";
static NSString* const c_storedQuery = @"storedQuery";

@interface MHVLocalRecordStore (MHVPrivate)

-(BOOL) ensureMetadataStore;
-(BOOL) ensureDataStore;
-(void) closeDataStore;

-(NSString *) makeViewKey:(NSString *) name;
-(NSString *) makeStoredQueryKey:(NSString *) name;

@end

@implementation MHVLocalRecordStore

@synthesize root = m_root;
@synthesize record = m_record;
@synthesize metadata = m_metadata;
-(MHVSynchronizedStore *)data
{
    return m_dataMgr.data;
}
@synthesize dataMgr = m_dataMgr;

-(id)initForRecord:(MHVRecordReference *)record overRoot:(id<MHVObjectStore>)root
{
    return [self initForRecord:record overRoot:root withCache:FALSE];
}

-(id)initForRecord:(MHVRecordReference *)record overRoot:(id<MHVObjectStore>)root withCache:(BOOL)cache
{
    MHVCHECK_NOTNULL(record);
    MHVCHECK_NOTNULL(root);
    
    m_cache = cache;
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_root = [root newChildStore:record.ID];
    MHVCHECK_NOTNULL(m_root);
    
    m_record = record;
    
    MHVCHECK_SUCCESS([self ensureMetadataStore]);    
    MHVCHECK_SUCCESS([self ensureDataStore]);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTypeView *)getView:(NSString *)name
{
    MHVTypeView* view = [m_metadata getObjectWithKey:[self makeViewKey:name] name:c_view andClass:[MHVTypeView class]];
    if (view)
    {
        view.store = self;
    }
    return view;
}

-(BOOL)putView:(MHVTypeView *)view name:(NSString *)name
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

-(MHVStoredQuery *)getStoredQuery:(NSString *)name
{
    MHVStoredQuery* storedQuery = [m_metadata getObjectWithKey:[self makeStoredQueryKey:name] 
                                                                name:c_storedQuery 
                                                                andClass:[MHVStoredQuery class]];
 
    return storedQuery;    
}

-(BOOL)putStoredQuery:(MHVStoredQuery *)query withName:(NSString *)name
{
    return [m_metadata putObject:query withKey:[self makeStoredQueryKey:name] andName:c_storedQuery];
}

-(void)deleteStoredQuery:(NSString *)name
{
    [m_metadata deleteKey:[self makeStoredQueryKey:name]];    
}

-(MHVSynchronizedType *)getSynchronizedTypeForTypeID:(NSString *)typeID
{
    return [m_dataMgr getTypeForTypeID:typeID];
}

+(NSString *)metadataStoreKey
{
    return @"Metadata";
}

-(BOOL)resetMetadata
{
    if (m_dataMgr.changeManager.isBusy)
    {
        return FALSE;
    }

    m_metadata = nil;
    [m_root deleteChildStore:[MHVLocalRecordStore metadataStoreKey]];
    
    return [self ensureMetadataStore];
}

-(BOOL)resetData
{
    if (m_dataMgr.changeManager.isBusy)
    {
        //
        // Cannot delete store if pending changes are being committed
        //
        return FALSE;
    }
    
    [m_dataMgr reset];
    [self closeDataStore];
    
    return [self ensureDataStore];
}

-(MHVTask *)commitOfflineChangesWithCallback:(MHVTaskCompletion)callback
{
    return [m_dataMgr.changeManager commitChangesWithCallback:callback];
}

-(void)close
{
    [self closeDataStore];
}

-(void)clearCache
{
    [m_dataMgr clearCache];
}

@end

@implementation MHVLocalRecordStore (MHVPrivate)

-(BOOL)ensureMetadataStore
{
    if (m_metadata)
    {
        return TRUE;
    }
    
    m_metadata = [m_root newChildStore:[MHVLocalRecordStore metadataStoreKey]];
    MHVCHECK_NOTNULL(m_metadata);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL) ensureDataStore
{
    if (m_dataMgr)
    {
        return TRUE;
    }
    
    m_dataMgr = [[MHVSynchronizationManager alloc] initForRecordStore:self withCache:m_cache];
    MHVCHECK_NOTNULL(m_dataMgr);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)closeDataStore
{
    if (m_dataMgr)
    {
        [m_dataMgr close];
    }
    m_dataMgr = nil;
}

-(NSString *)makeViewKey:(NSString *)name
{
    return [name stringByAppendingString:c_view];
}

-(NSString *)makeStoredQueryKey:(NSString *)name
{
    return [name stringByAppendingString:c_storedQuery];    
}

@end
