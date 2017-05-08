//
//  MHVSynchronizedStore.m
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
#import "MHVTypeViewItem.h"
#import "MHVTypeView.h"
#import "MHVSynchronizedStore.h"
#import "MHVLocalItemStore.h"
#import "MHVSynchronizationManager.h"
#import "MHVClient.h"

@interface MHVSynchronizedStore (MHVPrivate) 

-(void) setLocalStore:(id<MHVItemStore>) store;

//
// If a local item with the right version is not found and nullForNotFound is FALSE, does not create an NSNull entry...
//
-(MHVItemCollection *) getLocalItemsWithKeys:(MHVItemKeyCollection *)keys nullForNotFound:(BOOL) includeNull;

-(void) completedGetItemsTask:(MHVTask *) task;
-(void) completedDownloadKeys:(MHVItemKeyCollection *) keys inView:(MHVTypeView *) view task:(MHVTask *) task;
-(MHVItemQuery *) newQueryFromKeys:(MHVItemKeyCollection *) keys;

-(BOOL) updateItemsInLocalStore:(MHVItemCollection *)items;
-(BOOL) replaceLocalItemWithDownloaded:(MHVItem *) item;

-(void) notifyView:(MHVTypeView *) view ofItems:(MHVItemCollection *) items requestedKeys:(MHVItemKeyCollection *) requestedKeys;
-(void) notifyView:(MHVTypeView *)view ofError:(id) error retrievingKeys:(MHVItemKeyCollection *) keys;

@end

@implementation MHVSynchronizedStore

@synthesize defaultSections = m_sections;
@synthesize localStore = m_localStore;

-(id)init
{
    return [self initOverStore:nil];
}

-(id)initOverStore:(id)store
{
    MHVCHECK_NOTNULL(store);
    
    MHVLocalItemStore* localStore = [[MHVLocalItemStore alloc] initWithObjectStore:store];
    MHVCHECK_NOTNULL(localStore);
    
    self = [self initOverItemStore:localStore];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initOverItemStore:(id<MHVItemStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
        
    self.localStore = store;
    m_sections = MHVItemSection_Standard;
     
    return self;

LError:
    MHVALLOC_FAIL;
}


-(void)clearCache
{
    [m_localStore clearCache];
}

-(MHVItem *)getlocalItemWithID:(NSString *)itemID
{
    return [m_localStore getItem:itemID];
}

-(MHVItem *)getLocalItemWithKey:(MHVItemKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    MHVItem* item  = [self getlocalItemWithID:key.itemID];
    if (!item)
    {
        return nil;
    }
    
    if (!key.hasVersion)
    {
        // Did not want a version specific item.. so return the item we have
        return item;
    }
    
    if ([item isVersion:key.version]) // Check version stamp
    {
        return item;
    }
    
LError:
    return nil;
}

-(MHVItemCollection *)getLocalItemsWithKeys:(MHVItemKeyCollection *)keys
{
    return [self getLocalItemsWithKeys:keys nullForNotFound:TRUE];
}

-(BOOL)putLocalItem:(MHVItem *)item
{
    return [m_localStore putItem:item];
}

-(void) removeLocalItemWithKey:(MHVItemKey *)key
{
    return [m_localStore removeItem:key.itemID];
}

-(MHVTask *)downloadItemsWithKeys:(MHVItemKeyCollection *)keys inView:(MHVTypeView *)view
{
    return [self downloadItemsWithKeys:keys typeID:nil inView:view];
}

-(MHVTask *)downloadItemsWithKeys:(MHVItemKeyCollection *)keys typeID:(NSString *)typeID inView:(MHVTypeView *)view
{
    MHVCHECK_NOTNULL(keys);
    
    MHVItemQuery* query = [self newQueryFromKeys:keys];
    MHVCHECK_NOTNULL(query);
    
    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }
    
    return [self getItemsInRecord:view.record forQuery:query callback:^(MHVTask *task) {
        
        [self completedDownloadKeys:keys inView:view task:task];
        
    }];
    
LError:
    return nil;
}

-(MHVTask *)getItemsInRecord:(MHVRecordReference *)record withKeys:(MHVItemKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVItemQuery* query = [self newQueryFromKeys:keys];
    return [self getItemsInRecord:record forQuery:query callback:callback];
}

-(MHVTask *)getItemsInRecord:(MHVRecordReference *)record forQuery:(MHVItemQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(query);
    
    MHVTask* getItemsTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(getItemsTask);
    getItemsTask.taskName = @"getItemsInRecord";
    //
    // We'll run the download task as a child of the parent getItemsTask
    //
    MHVDownloadItemsTask *downloadTask = [self newDownloadItemsInRecord:record forQuery:query callback:^(MHVTask *task) {
        //
        // Make sure the download succeeded
        //
        [task checkSuccess];
        MHVItemKeyCollection *downloadedKeys = ((MHVDownloadItemsTask *) task).downloadedKeys;
        //
        // When the download sub-task completes, collect up all local items and return them to the caller...
        //
        task.parent.result = [self getLocalItemsWithKeys:downloadedKeys nullForNotFound:FALSE];
        
    }];
    MHVCHECK_NOTNULL(downloadTask);
    
    [getItemsTask setNextTask:downloadTask];
    
    [getItemsTask start];  // this can throw
    
    return getItemsTask;

LError:
    return nil;
}

// Deprecated
-(BOOL)putItem:(MHVItem *)item
{
    return [self putLocalItem:item];
}

-(MHVDownloadItemsTask *)downloadItemsInRecord:(MHVRecordReference *)record forKeys:(MHVItemKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVDownloadItemsTask* task = [self newDownloadItemsInRecord:record forKeys:keys callback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;    
}

-(MHVDownloadItemsTask *)downloadItemsInRecord:(MHVRecordReference *) record query :(MHVItemQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVDownloadItemsTask* task = [self newDownloadItemsInRecord:record forQuery:query callback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;
}

-(MHVDownloadItemsTask *)newDownloadItemsInRecord:(MHVRecordReference *)record forKeys:(MHVItemKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVItemQuery* query = [self newQueryFromKeys:keys];
    MHVCHECK_NOTNULL(query);
    
    return [self newDownloadItemsInRecord:record forQuery:query callback:callback];
    
LError:
    return nil;
}

-(MHVDownloadItemsTask *)newDownloadItemsInRecord:(MHVRecordReference *)record forQuery:(MHVItemQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVDownloadItemsTask* downloadTask = nil;
    
    MHVCHECK_NOTNULL(record); 
    MHVCHECK_NOTNULL(query);
        
    downloadTask = [[MHVDownloadItemsTask alloc] initWithCallback:callback]; // do not auto release
    MHVCHECK_NOTNULL(downloadTask);
    downloadTask.taskName = @"downloadItems";
 
    MHVGetItemsTask* getItemsTask = [[[MHVClient current] methodFactory] newGetItemsForRecord:record query:query andCallback:^(MHVTask *task) {
        [self completedGetItemsTask:task];
    }];
    MHVCHECK_NOTNULL(getItemsTask);
    getItemsTask.taskName = @"getItemsTask";
    
    [downloadTask setNextTask:getItemsTask];
    
    return downloadTask;
}

@end


@implementation MHVSynchronizedStore (MHVPrivate)

-(MHVItemCollection *)getLocalItemsWithKeys:(MHVItemKeyCollection *)keys nullForNotFound:(BOOL)includeNull
{    
    MHVItemCollection *results = [[MHVItemCollection alloc] init];
    MHVCHECK_NOTNULL(results);
    
    if (keys)
    {
        for (MHVItemKey* key in keys)
        {
            MHVItem* item = [self getLocalItemWithKey:key];
            if (item)
            {
                [results addObject:item];
            }
            else if (includeNull)
            {
                [results addObject:[NSNull null]];
            }
        }
    }
    
    return results;
    
LError:
    return nil;
}

//
// We actually query for items by their IDs only
// This allows to retrieve the latest version of a particular item always, which is what we want
//
-(MHVItemQuery *)newQueryFromKeys:(MHVItemKeyCollection *)keys
{
    MHVItemQuery* query = [[MHVItemQuery alloc] init];
    MHVCHECK_NOTNULL(query);
    
    query.view.sections = m_sections;
    for (MHVItemKey* key in keys) 
    {
        [query.itemIDs addObject:key.itemID];
    }
    
    return query;
    
LError:
    return nil;
}

-(void)setLocalStore:(id<MHVItemStore>)store
{
    m_localStore = store;
}

-(void)completedGetItemsTask:(MHVTask *)task
{
    MHVGetItemsTask* getItems = (MHVGetItemsTask *) task;
    //
    // Exceptions will fall through and propagate to caller
    //
    MHVItemQueryResult* result = getItems.queryResults.firstResult;
    if (!result.hasItems)
    {
        // Nothing returned
        return;
    }
    //
    // Write items we got back from the server to the local store
    //
    if (![self updateItemsInLocalStore:result.items])
    {
        [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_PutLocalStore)];
    }
    //
    // Record keys that were successfully downloaded
    //
    [((MHVDownloadItemsTask *) task.parent) recordItemsAsDownloaded:result.items];
    
    if (!result.hasPendingItems)
    {
        return;
    }
    //
    // Trigger a load of pending items
    //
    MHVItemQuery *pendingQuery = [[MHVItemQuery alloc] initWithPendingItems:result.pendingItems];
    if (!pendingQuery)
    {
        return;
    }
    pendingQuery.view = getItems.firstQuery.view;
    MHVGetItemsTask* getPendingTask = [[MHVClient current].methodFactory newGetItemsForRecord:getItems.record query:pendingQuery andCallback:^(MHVTask *task) {
        
        [self completedGetItemsTask:task];
        
    }];
    getPendingTask.record = getItems.record;
    
    [task.parent setNextTask:getPendingTask];
    
}

-(void)completedDownloadKeys:(MHVItemKeyCollection *)keys inView:(MHVTypeView *)view task:(MHVTask *)task
{
    if (task.hasError)
    {
        [self notifyView:view ofError:task.exception retrievingKeys:keys];
    }
    else
    {
        [self notifyView:view ofItems:task.result requestedKeys:keys];
    }
}

-(BOOL)updateItemsInLocalStore:(MHVItemCollection *)items
{
    MHVCHECK_NOTNULL(items);
    
    for (NSInteger i = 0, count = items.count; i < count; ++i)
    {
        MHVItem* item = [items objectAtIndex:i];
        MHVCHECK_SUCCESS([self replaceLocalItemWithDownloaded:item]);
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalItemWithDownloaded:(MHVItem *)item
{
    if (self.syncMgr)
    {
        @try
        {
            return [self.syncMgr replaceLocalWithDownloaded:item];
        }
        @catch (id ex)
        {
        }
        return FALSE;
    }
    
    return [m_localStore putItem:item];
}

-(void)notifyView:(MHVTypeView *)view ofItems:(MHVItemCollection *)items requestedKeys:(MHVItemKeyCollection *)requestedKeys
{
    [view itemsRetrieved:items forKeys:requestedKeys];
}

-(void)notifyView:(MHVTypeView *)view ofError:(id)error retrievingKeys:(MHVItemKeyCollection *)keys
{
    [view keysNotRetrieved:keys withError:error];
}

@end

