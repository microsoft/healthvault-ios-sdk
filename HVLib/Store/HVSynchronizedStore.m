//
//  HVSynchronizedStore.m
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
#import "HVTypeViewItem.h"
#import "HVTypeView.h"
#import "HVSynchronizedStore.h"
#import "HVLocalItemStore.h"
#import "HVSynchronizationManager.h"
#import "HVClient.h"

@interface HVSynchronizedStore (HVPrivate) 

-(void) setLocalStore:(id<HVItemStore>) store;

//
// If a local item with the right version is not found and nullForNotFound is FALSE, does not create an NSNull entry...
//
-(HVItemCollection *) getLocalItemsWithKeys:(NSArray *)keys nullForNotFound:(BOOL) includeNull;

-(void) completedGetItemsTask:(HVTask *) task;
-(void) completedDownloadKeys:(NSArray *) keys inView:(HVTypeView *) view task:(HVTask *) task;
-(HVItemQuery *) newQueryFromKeys:(NSArray *) keys;

-(BOOL) updateItemsInLocalStore:(HVItemCollection *)items;
-(BOOL) replaceLocalItemWithDownloaded:(HVItem *) item;

-(void) notifyView:(HVTypeView *) view ofItems:(HVItemCollection *) items requestedKeys:(NSArray *) requestedKeys;
-(void) notifyView:(HVTypeView *)view ofError:(id) error retrievingKeys:(NSArray *) keys;

@end

@implementation HVSynchronizedStore

@synthesize defaultSections = m_sections;
@synthesize localStore = m_localStore;
@synthesize syncMgr = m_syncMgr;

-(id)init
{
    return [self initOverStore:nil];
}

-(id)initOverStore:(id)store
{
    HVCHECK_NOTNULL(store);
    
    HVLocalItemStore* localStore = [[HVLocalItemStore alloc] initWithObjectStore:store];
    HVCHECK_NOTNULL(localStore);
    
    self = [self initOverItemStore:localStore];
    [localStore release];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initOverItemStore:(id<HVItemStore>)store
{
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
        
    self.localStore = store;
    m_sections = HVItemSection_Standard;
     
    return self;

LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_localStore release];    
    [super dealloc];
}

-(void)clearCache
{
    [m_localStore clearCache];
}

-(HVItem *)getlocalItemWithID:(NSString *)itemID
{
    return [m_localStore getItem:itemID];
}

-(HVItem *)getLocalItemWithKey:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    HVItem* item  = [self getlocalItemWithID:key.itemID];
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

-(HVItemCollection *)getLocalItemsWithKeys:(NSArray *)keys
{
    return [self getLocalItemsWithKeys:keys nullForNotFound:TRUE];
}

-(BOOL)putLocalItem:(HVItem *)item
{
    return [m_localStore putItem:item];
}

-(void) removeLocalItemWithKey:(HVItemKey *)key
{
    return [m_localStore removeItem:key.itemID];
}

-(HVTask *)downloadItemsWithKeys:(NSArray *)keys inView:(HVTypeView *)view
{
    return [self downloadItemsWithKeys:keys typeID:nil inView:view];
}

-(HVTask *)downloadItemsWithKeys:(NSArray *)keys typeID:(NSString *)typeID inView:(HVTypeView *)view
{
    HVCHECK_NOTNULL(keys);
    
    HVItemQuery* query = [[self newQueryFromKeys:keys] autorelease];
    HVCHECK_NOTNULL(query);
    
    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }
    
    return [self getItemsInRecord:view.record forQuery:query callback:^(HVTask *task) {
        
        [self completedDownloadKeys:keys inView:view task:task];
        
    }];
    
LError:
    return nil;
}

-(HVTask *)getItemsInRecord:(HVRecordReference *)record withKeys:(NSArray *)keys callback:(HVTaskCompletion)callback
{
    HVItemQuery* query = [[self newQueryFromKeys:keys] autorelease];
    return [self getItemsInRecord:record forQuery:query callback:callback];
}

-(HVTask *)getItemsInRecord:(HVRecordReference *)record forQuery:(HVItemQuery *)query callback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(query);
    
    HVTask* getItemsTask = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(getItemsTask);
    getItemsTask.taskName = @"getItemsInRecord";
    //
    // We'll run the download task as a child of the parent getItemsTask
    //
    HVDownloadItemsTask *downloadTask = [self newDownloadItemsInRecord:record forQuery:query callback:^(HVTask *task) {
        //
        // Make sure the download succeeded
        //
        [task checkSuccess];
        NSArray* downloadedKeys = ((HVDownloadItemsTask *) task).downloadedKeys;
        //
        // When the download sub-task completes, collect up all local items and return them to the caller...
        //
        task.parent.result = [self getLocalItemsWithKeys:downloadedKeys nullForNotFound:FALSE];
        
    }];
    HVCHECK_NOTNULL(downloadTask);
    
    [getItemsTask setNextTask:downloadTask];
    [downloadTask release];
    
    [getItemsTask start];  // this can throw
    
    return getItemsTask;

LError:
    return nil;
}

// Deprecated
-(BOOL)putItem:(HVItem *)item
{
    return [self putLocalItem:item];
}

-(HVDownloadItemsTask *)downloadItemsInRecord:(HVRecordReference *)record forKeys:(NSArray *)keys callback:(HVTaskCompletion)callback
{
    HVDownloadItemsTask* task = [[self newDownloadItemsInRecord:record forKeys:keys callback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;    
}

-(HVDownloadItemsTask *)downloadItemsInRecord:(HVRecordReference *) record query :(HVItemQuery *)query callback:(HVTaskCompletion)callback
{
    HVDownloadItemsTask* task = [[self newDownloadItemsInRecord:record forQuery:query callback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;
}

-(HVDownloadItemsTask *)newDownloadItemsInRecord:(HVRecordReference *)record forKeys:(NSArray *)keys callback:(HVTaskCompletion)callback
{
    HVItemQuery* query = [[self newQueryFromKeys:keys] autorelease];
    HVCHECK_NOTNULL(query);
    
    return [self newDownloadItemsInRecord:record forQuery:query callback:callback];
    
LError:
    return nil;
}

-(HVDownloadItemsTask *)newDownloadItemsInRecord:(HVRecordReference *)record forQuery:(HVItemQuery *)query callback:(HVTaskCompletion)callback
{
    HVDownloadItemsTask* downloadTask = nil;
    
    HVCHECK_NOTNULL(record); 
    HVCHECK_NOTNULL(query);
        
    downloadTask = [[HVDownloadItemsTask alloc] initWithCallback:callback]; // do not auto release
    HVCHECK_NOTNULL(downloadTask);
    downloadTask.taskName = @"downloadItems";
 
    HVGetItemsTask* getItemsTask = [[[HVClient current] methodFactory] newGetItemsForRecord:record query:query andCallback:^(HVTask *task) {
        [self completedGetItemsTask:task];
    }];
    HVCHECK_NOTNULL(getItemsTask);
    getItemsTask.taskName = @"getItemsTask";
    
    [downloadTask setNextTask:getItemsTask];
    [getItemsTask release];
    
    return downloadTask;
    
LError:
    [downloadTask release];
    return nil;
}

@end


@implementation HVSynchronizedStore (HVPrivate)

-(HVItemCollection *)getLocalItemsWithKeys:(NSArray *)keys nullForNotFound:(BOOL)includeNull
{    
    HVItemCollection *results = [[[HVItemCollection alloc] init] autorelease];
    HVCHECK_NOTNULL(results);
    
    if (keys)
    {
        for (HVItemKey* key in keys)
        {
            HVItem* item = [self getLocalItemWithKey:key];
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
-(HVItemQuery *)newQueryFromKeys:(NSArray *)keys
{
    HVItemQuery* query = [[HVItemQuery alloc] init];
    HVCHECK_NOTNULL(query);
    
    query.view.sections = m_sections;
    for (HVItemKey* key in keys) 
    {
        [query.itemIDs addObject:key.itemID];
    }
    
    return query;
    
LError:
    return nil;
}

-(void)setLocalStore:(id<HVItemStore>)store
{
    HVRETAIN(m_localStore, store);
}

-(void)completedGetItemsTask:(HVTask *)task
{
    HVGetItemsTask* getItems = (HVGetItemsTask *) task;
    //
    // Exceptions will fall through and propagate to caller
    //
    HVItemQueryResult* result = getItems.queryResults.firstResult;
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
        [HVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_PutLocalStore)];
    }
    //
    // Record keys that were successfully downloaded
    //
    [((HVDownloadItemsTask *) task.parent) recordItemsAsDownloaded:result.items];
    
    if (!result.hasPendingItems)
    {
        return;
    }
    //
    // Trigger a load of pending items
    //
    HVItemQuery *pendingQuery = [[HVItemQuery alloc] initWithPendingItems:result.pendingItems];
    if (!pendingQuery)
    {
        return;
    }
    pendingQuery.view = getItems.firstQuery.view;
    HVGetItemsTask* getPendingTask = [[HVClient current].methodFactory newGetItemsForRecord:getItems.record query:pendingQuery andCallback:^(HVTask *task) {
        
        [self completedGetItemsTask:task];
        
    }];
    getPendingTask.record = getItems.record;
    
    [task.parent setNextTask:getPendingTask];
    
    [pendingQuery release];
    [getPendingTask release];
}

-(void)completedDownloadKeys:(NSArray *)keys inView:(HVTypeView *)view task:(HVTask *)task
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

-(BOOL)updateItemsInLocalStore:(HVItemCollection *)items
{
    HVCHECK_NOTNULL(items);
    
    for (NSInteger i = 0, count = items.count; i < count; ++i)
    {
        HVItem* item = [items objectAtIndex:i];
        HVCHECK_SUCCESS([self replaceLocalItemWithDownloaded:item]);
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalItemWithDownloaded:(HVItem *)item
{
    if (m_syncMgr)
    {
        @try
        {
            return [m_syncMgr replaceLocalWithDownloaded:item];
        }
        @catch (id ex)
        {
        }
        return FALSE;
    }
    
    return [m_localStore putItem:item];
}

-(void)notifyView:(HVTypeView *)view ofItems:(HVItemCollection *)items requestedKeys:(NSArray *)requestedKeys
{
    [view itemsRetrieved:items forKeys:requestedKeys];
}

-(void)notifyView:(HVTypeView *)view ofError:(id)error retrievingKeys:(NSArray *)keys
{
    [view keysNotRetrieved:keys withError:error];
}

@end

