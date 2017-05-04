//
//  MHVLocalVault.m
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
#import "MHVLocalVault.h"
#import "XLib.h"
#import "MHVCachingObjectStore.h"
#import "MHVClient.h"
#import "MHVItemChangeManager.h"


@interface MHVLocalVaultOfflineChangesCommitter : MHVTaskSequence
{
@private
    NSMutableArray* m_records;
    MHVLocalVault* m_localVault;
}

-(id) initWithLocalVault:(MHVLocalVault *)vault andRecordReferences:(NSArray *) recordRefs;

@end

@interface MHVLocalVault (MHVPrivate)

-(void) setRoot:(MHVDirectory *) root;
-(BOOL) ensureRecordStores;
-(BOOL) ensureVocabStores;

-(void) close;

@end

@implementation MHVLocalVault

@synthesize root = m_root;
@synthesize vocabs = m_vocabs;

-(id)init
{
    return [self initWithRoot:nil];
}

-(id)initWithRoot:(MHVDirectory *)root
{
    return [self initWithRoot:root andCache:FALSE];
}

-(id)initWithRoot:(MHVDirectory *)root andCache:(BOOL)cache
{
    MHVCHECK_NOTNULL(root);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_cache = cache;
    self.root = root;
    
    MHVCHECK_SUCCESS([self ensureRecordStores]);
    MHVCHECK_SUCCESS([self ensureVocabStores]);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void)dealloc
{
    [self close];
    
    
}

-(MHVLocalRecordStore *)getRecordStore:(MHVRecordReference *)record
{
    MHVCHECK_NOTNULL(record);
    
    @synchronized(m_recordStores)
    {
        MHVLocalRecordStore* recordStore = [m_recordStores objectForKey:record.ID];
        if (!recordStore)
        {
            recordStore = [[MHVLocalRecordStore alloc] initForRecord:record overRoot:m_root withCache:m_cache];
            [m_recordStores setObject:recordStore forKey:record.ID];
        }
        
        return recordStore;
    }

LError:
    return nil;
}

-(BOOL)deleteRecordStore:(MHVRecordReference *)record
{
    MHVCHECK_NOTNULL(record);

    NSString* recordID = record.ID;
    @synchronized(m_recordStores)
    {
        MHVLocalRecordStore* recordStore = [m_recordStores objectForKey:recordID];
        if (recordStore)
        {
            if (recordStore.dataMgr.changeManager.isBusy)
            {
                return FALSE;
            }
            
            [m_recordStores removeObjectForKey:recordID];
            [m_root deleteChildStore:recordID];
        }
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)resetDataStoreForRecords:(NSArray *)records
{
    @synchronized(m_recordStores)
    { 
        for (MHVRecordReference* record in records)
        {
            MHVLocalRecordStore* recordStore = [self getRecordStore:record];
            if (recordStore)
            {
                [recordStore resetData];
            }
        }
    }
}

-(void)didReceiveMemoryWarning
{
    [self clearCache];
}

-(void)clearCache
{
    NSArray* stores;
    @synchronized(m_recordStores)
    {
        stores = [m_recordStores allValues];
    }
    
    if (stores)
    {
        for (MHVLocalRecordStore* recordStore in stores)
        {
            [recordStore clearCache];
        }
    }
    
    if (m_vocabs && [m_vocabs.store respondsToSelector:@selector(clearCache)])
    {
        [m_vocabs.store performSelector:@selector(clearCache)];
    }
}

-(MHVTask *)commitOfflineChangesWithCallback:(MHVTaskCompletion)callback
{
    return [self commitOfflineChangesForRecords:[MHVClient current].records withCallback:callback];
}

-(MHVTask *)commitOfflineChangesForRecords:(NSArray *)records withCallback:(MHVTaskCompletion)callback
{
    MHVLocalVaultOfflineChangesCommitter* committer = [[MHVLocalVaultOfflineChangesCommitter alloc] initWithLocalVault:self andRecordReferences:records];
    MHVCHECK_NOTNULL(committer);
    
    return [MHVTaskSequence run:committer callback:callback];
    
LError:
    return nil;
}

@end

@implementation MHVLocalVault (MHVPrivate)
-(void)setRoot:(MHVDirectory *)root
{
    m_root = root;
}

-(BOOL)ensureRecordStores
{
    if (m_recordStores)
    {
        return TRUE;
    }
 
    m_recordStores = [[NSMutableDictionary alloc] initWithCapacity:2];
    MHVCHECK_NOTNULL(m_recordStores);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)ensureVocabStores
{
    if (m_vocabs)
    {
        return TRUE;
    }
    
    id<MHVObjectStore> vocabObjectStore = [m_root newChildStore:@"vocabs"];
    MHVCHECK_NOTNULL(vocabObjectStore);
    
    if (m_cache)
    {
        id<MHVObjectStore> cachingDataStore = [[MHVCachingObjectStore alloc] initWithObjectStore:vocabObjectStore];
        MHVCHECK_NOTNULL(cachingDataStore);
        
        vocabObjectStore = cachingDataStore;
    }
    
    m_vocabs = [[MHVLocalVocabStore alloc] initWithObjectStore:vocabObjectStore];
    MHVCHECK_NOTNULL(m_vocabs);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)close
{
    if (!m_recordStores)
    {
        return;
    }
    
    NSEnumerator* stores = m_recordStores.objectEnumerator;
    MHVLocalRecordStore* store = nil;
    while ((store = stores.nextObject) != nil)
    {
        [store close];
    }
}

@end

@implementation MHVLocalVaultOfflineChangesCommitter

-(id) init
{
    return [self initWithLocalVault:[MHVClient current].localVault andRecordReferences:[MHVClient current].records];
}

-(id)initWithLocalVault:(MHVLocalVault *)vault andRecordReferences:(NSArray *)recordRefs
{
    MHVCHECK_NOTNULL(vault);
    MHVCHECK_NOTNULL(recordRefs);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_records = [[NSMutableArray alloc] initWithCapacity:recordRefs.count];
    for (MHVRecordReference* recordRef in recordRefs)
    {
        [m_records addObject:recordRef];
    }
    
    m_localVault = vault;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTask *)nextTask
{
    while (TRUE)
    {
        MHVRecordReference* nextRecord = [m_records dequeueObject];
        if (!nextRecord)
        {
            break;
        }
        
        MHVLocalRecordStore* recordStore = [m_localVault getRecordStore:nextRecord];
        if (recordStore)
        {
            MHVTask* task = [recordStore.dataMgr.changeManager newCommitChangesTaskWithCallback:^(MHVTask *task) {
                
                [task checkSuccess];
                
            }];
            
            if (task)
            {
                return task;
            }
            //
            // Nil indicates changes manager is busy
            //
        }
    }
    
    return nil;
}

@end
