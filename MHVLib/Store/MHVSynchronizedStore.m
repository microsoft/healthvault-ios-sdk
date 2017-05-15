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
#import "MHVTypeViewThing.h"
#import "MHVTypeView.h"
#import "MHVSynchronizedStore.h"
#import "MHVLocalThingStore.h"
#import "MHVSynchronizationManager.h"
#import "MHVClient.h"

@interface MHVSynchronizedStore (MHVPrivate) 

-(void) setLocalStore:(id<MHVThingStore>) store;

//
// If a local thing with the right version is not found and nullForNotFound is FALSE, does not create an NSNull entry...
//
-(MHVThingCollection *) getLocalThingsWithKeys:(MHVThingKeyCollection *)keys nullForNotFound:(BOOL) includeNull;

-(void) completedGetThingsTask:(MHVTask *) task;
-(void) completedDownloadKeys:(MHVThingKeyCollection *) keys inView:(MHVTypeView *) view task:(MHVTask *) task;
-(MHVThingQuery *) newQueryFromKeys:(MHVThingKeyCollection *) keys;

-(BOOL) updateThingsInLocalStore:(MHVThingCollection *)things;
-(BOOL) replaceLocalThingWithDownloaded:(MHVThing *) thing;

-(void) notifyView:(MHVTypeView *) view ofThings:(MHVThingCollection *) things requestedKeys:(MHVThingKeyCollection *) requestedKeys;
-(void) notifyView:(MHVTypeView *)view ofError:(id) error retrievingKeys:(MHVThingKeyCollection *) keys;

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
    
    MHVLocalThingStore* localStore = [[MHVLocalThingStore alloc] initWithObjectStore:store];
    MHVCHECK_NOTNULL(localStore);
    
    self = [self initOverThingStore:localStore];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initOverThingStore:(id<MHVThingStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
        
    self.localStore = store;
    m_sections = MHVThingSection_Standard;
     
    return self;

LError:
    MHVALLOC_FAIL;
}


-(void)clearCache
{
    [m_localStore clearCache];
}

-(MHVThing *)getlocalThingWithID:(NSString *)thingID
{
    return [m_localStore getThing:thingID];
}

-(MHVThing *)getLocalThingWithKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    MHVThing* thing  = [self getlocalThingWithID:key.thingID];
    if (!thing)
    {
        return nil;
    }
    
    if (!key.hasVersion)
    {
        // Did not want a version specific thing.. so return the thing we have
        return thing;
    }
    
    if ([thing isVersion:key.version]) // Check version stamp
    {
        return thing;
    }
    
LError:
    return nil;
}

-(MHVThingCollection *)getLocalThingsWithKeys:(MHVThingKeyCollection *)keys
{
    return [self getLocalThingsWithKeys:keys nullForNotFound:TRUE];
}

-(BOOL)putLocalThing:(MHVThing *)thing
{
    return [m_localStore putThing:thing];
}

-(void) removeLocalThingWithKey:(MHVThingKey *)key
{
    return [m_localStore removeThing:key.thingID];
}

-(MHVTask *)downloadThingsWithKeys:(MHVThingKeyCollection *)keys inView:(MHVTypeView *)view
{
    return [self downloadThingsWithKeys:keys typeID:nil inView:view];
}

-(MHVTask *)downloadThingsWithKeys:(MHVThingKeyCollection *)keys typeID:(NSString *)typeID inView:(MHVTypeView *)view
{
    MHVCHECK_NOTNULL(keys);
    
    MHVThingQuery* query = [self newQueryFromKeys:keys];
    MHVCHECK_NOTNULL(query);
    
    if (![NSString isNilOrEmpty:typeID])
    {
        [query.view.typeVersions addObject:typeID];
    }
    
    return [self getThingsInRecord:view.record forQuery:query callback:^(MHVTask *task) {
        
        [self completedDownloadKeys:keys inView:view task:task];
        
    }];
    
LError:
    return nil;
}

-(MHVTask *)getThingsInRecord:(MHVRecordReference *)record withKeys:(MHVThingKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVThingQuery* query = [self newQueryFromKeys:keys];
    return [self getThingsInRecord:record forQuery:query callback:callback];
}

-(MHVTask *)getThingsInRecord:(MHVRecordReference *)record forQuery:(MHVThingQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(query);
    
    MHVTask* getThingsTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(getThingsTask);
    getThingsTask.taskName = @"getThingsInRecord";
    //
    // We'll run the download task as a child of the parent getThingsTask
    //
    MHVDownloadThingsTask *downloadTask = [self newDownloadThingsInRecord:record forQuery:query callback:^(MHVTask *task) {
        //
        // Make sure the download succeeded
        //
        [task checkSuccess];
        MHVThingKeyCollection *downloadedKeys = ((MHVDownloadThingsTask *) task).downloadedKeys;
        //
        // When the download sub-task completes, collect up all local things and return them to the caller...
        //
        task.parent.result = [self getLocalThingsWithKeys:downloadedKeys nullForNotFound:FALSE];
        
    }];
    MHVCHECK_NOTNULL(downloadTask);
    
    [getThingsTask setNextTask:downloadTask];
    
    [getThingsTask start];  // this can throw
    
    return getThingsTask;

LError:
    return nil;
}

// Deprecated
-(BOOL)putThing:(MHVThing *)thing
{
    return [self putLocalThing:thing];
}

-(MHVDownloadThingsTask *)downloadThingsInRecord:(MHVRecordReference *)record forKeys:(MHVThingKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVDownloadThingsTask* task = [self newDownloadThingsInRecord:record forKeys:keys callback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;    
}

-(MHVDownloadThingsTask *)downloadThingsInRecord:(MHVRecordReference *) record query :(MHVThingQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVDownloadThingsTask* task = [self newDownloadThingsInRecord:record forQuery:query callback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    
    return task;
    
LError:
    return nil;
}

-(MHVDownloadThingsTask *)newDownloadThingsInRecord:(MHVRecordReference *)record forKeys:(MHVThingKeyCollection *)keys callback:(MHVTaskCompletion)callback
{
    MHVThingQuery* query = [self newQueryFromKeys:keys];
    MHVCHECK_NOTNULL(query);
    
    return [self newDownloadThingsInRecord:record forQuery:query callback:callback];
    
LError:
    return nil;
}

-(MHVDownloadThingsTask *)newDownloadThingsInRecord:(MHVRecordReference *)record forQuery:(MHVThingQuery *)query callback:(MHVTaskCompletion)callback
{
    MHVDownloadThingsTask* downloadTask = nil;
    
    MHVCHECK_NOTNULL(record); 
    MHVCHECK_NOTNULL(query);
        
    downloadTask = [[MHVDownloadThingsTask alloc] initWithCallback:callback]; // do not auto release
    MHVCHECK_NOTNULL(downloadTask);
    downloadTask.taskName = @"downloadThings";
 
    MHVGetThingsTask* getThingsTask = [[[MHVClient current] methodFactory] newGetThingsForRecord:record query:query andCallback:^(MHVTask *task) {
        [self completedGetThingsTask:task];
    }];
    MHVCHECK_NOTNULL(getThingsTask);
    getThingsTask.taskName = @"getThingsTask";
    
    [downloadTask setNextTask:getThingsTask];
    
    return downloadTask;
}

@end


@implementation MHVSynchronizedStore (MHVPrivate)

-(MHVThingCollection *)getLocalThingsWithKeys:(MHVThingKeyCollection *)keys nullForNotFound:(BOOL)includeNull
{    
    MHVThingCollection *results = [[MHVThingCollection alloc] init];
    MHVCHECK_NOTNULL(results);
    
    if (keys)
    {
        for (MHVThingKey* key in keys)
        {
            MHVThing* thing = [self getLocalThingWithKey:key];
            if (thing)
            {
                [results addObject:thing];
            }
            else if (includeNull)
            {
                [results addObject:(MHVThing *)[NSNull null]];
            }
        }
    }
    
    return results;
    
LError:
    return nil;
}

//
// We actually query for things by their IDs only
// This allows to retrieve the latest version of a particular thing always, which is what we want
//
-(MHVThingQuery *)newQueryFromKeys:(MHVThingKeyCollection *)keys
{
    MHVThingQuery* query = [[MHVThingQuery alloc] init];
    MHVCHECK_NOTNULL(query);
    
    query.view.sections = m_sections;
    for (MHVThingKey* key in keys) 
    {
        [query.thingIDs addObject:key.thingID];
    }
    
    return query;
    
LError:
    return nil;
}

-(void)setLocalStore:(id<MHVThingStore>)store
{
    m_localStore = store;
}

-(void)completedGetThingsTask:(MHVTask *)task
{
    MHVGetThingsTask* getThings = (MHVGetThingsTask *) task;
    //
    // Exceptions will fall through and propagate to caller
    //
    MHVThingQueryResult* result = getThings.queryResults.firstResult;
    if (!result.hasThings)
    {
        // Nothing returned
        return;
    }
    //
    // Write things we got back from the server to the local store
    //
    if (![self updateThingsInLocalStore:result.things])
    {
        [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_PutLocalStore)];
    }
    //
    // Record keys that were successfully downloaded
    //
    [((MHVDownloadThingsTask *) task.parent) recordThingsAsDownloaded:result.things];
    
    if (!result.hasPendingThings)
    {
        return;
    }
    //
    // Trigger a load of pending things
    //
    MHVThingQuery *pendingQuery = [[MHVThingQuery alloc] initWithPendingThings:result.pendingThings];
    if (!pendingQuery)
    {
        return;
    }
    pendingQuery.view = getThings.firstQuery.view;
    MHVGetThingsTask* getPendingTask = [[MHVClient current].methodFactory newGetThingsForRecord:getThings.record query:pendingQuery andCallback:^(MHVTask *task) {
        
        [self completedGetThingsTask:task];
        
    }];
    getPendingTask.record = getThings.record;
    
    [task.parent setNextTask:getPendingTask];
    
}

-(void)completedDownloadKeys:(MHVThingKeyCollection *)keys inView:(MHVTypeView *)view task:(MHVTask *)task
{
    if (task.hasError)
    {
        [self notifyView:view ofError:task.exception retrievingKeys:keys];
    }
    else
    {
        [self notifyView:view ofThings:task.result requestedKeys:keys];
    }
}

-(BOOL)updateThingsInLocalStore:(MHVThingCollection *)things
{
    MHVCHECK_NOTNULL(things);
    
    for (NSInteger i = 0, count = things.count; i < count; ++i)
    {
        MHVThing* thing = [things objectAtIndex:i];
        MHVCHECK_SUCCESS([self replaceLocalThingWithDownloaded:thing]);
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)replaceLocalThingWithDownloaded:(MHVThing *)thing
{
    if (self.syncMgr)
    {
        @try
        {
            return [self.syncMgr replaceLocalWithDownloaded:thing];
        }
        @catch (id ex)
        {
        }
        return FALSE;
    }
    
    return [m_localStore putThing:thing];
}

-(void)notifyView:(MHVTypeView *)view ofThings:(MHVThingCollection *)things requestedKeys:(MHVThingKeyCollection *)requestedKeys
{
    [view thingsRetrieved:things forKeys:requestedKeys];
}

-(void)notifyView:(MHVTypeView *)view ofError:(id)error retrievingKeys:(MHVThingKeyCollection *)keys
{
    [view keysNotRetrieved:keys withError:error];
}

@end

