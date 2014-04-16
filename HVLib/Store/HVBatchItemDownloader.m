//
//  HVBatchItemDownloader.m
//  HVLib
//
// Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
#import "HVCommon.h"
#import "HVBatchItemDownloader.h"
#import "HVClient.h"

@interface HVBatchItemDownloader (HVPrivate)

-(void) collectNextBatch;
-(BOOL) setNextBatch:(HVTask *) parentTask;
-(void) batchComplete:(HVDownloadItemsTask *) task;

@end

static const NSUInteger c_defaultBatchSize = 250;

@implementation HVBatchItemDownloader

@synthesize batchSize = m_batchSize;
-(void)setBatchSize:(NSUInteger)batchSize
{
    if (batchSize == 0)
    {
        m_batchSize = c_defaultBatchSize;
    }
}

-(NSMutableArray *)keysToDownload
{
    return m_keysToDownload;
}

-(id)initWithRecordStore:(HVLocalRecordStore *)store
{
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_keysToDownload = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_keysToDownload);
    
    m_keyBatch = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_keyBatch);
    
    HVRETAIN(m_store, store);
    
    m_batchSize = c_defaultBatchSize;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_store release];
    [m_keysToDownload release];
    [m_keyBatch release];
    
    [super dealloc];
}

-(BOOL)addKeyToDownload:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    [m_keysToDownload addObject:key];
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addKeyForItemToEnsureDownloaded:(HVItemKey *)key
{
    HVCHECK_NOTNULL(key);
    
    if (![m_store.data getLocalItemWithKey:key])
    {
        [m_keysToDownload addObject:key];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)addRangeOfKeysToEnsureDownloaded:(NSRange)range inView:(id<HVTypeView>)view
{
    HVCHECK_NOTNULL(view);
    
    int max = range.location + range.length;
    if (max > [view count])
    {
        max = [view count];
    }
    for (NSUInteger i = range.location; i < max; ++i)
    {
        [self addKeyForItemToEnsureDownloaded:[view itemKeyAtIndex:i]];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(HVTask *)downloadWithCallback:(HVTaskCompletion)callback
{
    HVTask* task = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(task);
    
    if (![self setNextBatch:task])
    {
        return nil;
    }
    
    [task start];
    return task;

LError:
    return nil;
}

@end

@implementation HVBatchItemDownloader (HVPrivate)

-(void)collectNextBatch
{
    [m_keyBatch removeAllObjects];
    while (m_keyBatch.count < m_batchSize)
    {
        HVItemKey* key = [m_keysToDownload dequeueObject];
        if (!key)
        {
            break;
        }
        
        [m_keyBatch addObject:key];
    }
}

-(BOOL)setNextBatch:(HVTask *)parentTask
{
    [self collectNextBatch];
    if (m_keyBatch.count == 0)
    {
        return FALSE;
    }
    
    HVDownloadItemsTask* downloadTask = [m_store.data newDownloadItemsInRecord:m_store.record forKeys:m_keyBatch callback:^(HVTask *task) {
        
        [self batchComplete:(HVDownloadItemsTask *) task];
        
    }];
    
    [parentTask setNextTask:downloadTask];
    [downloadTask release];
    
    return TRUE;
}

-(void)batchComplete:(HVDownloadItemsTask *)task
{
    [task checkSuccess];
    [self setNextBatch:task.parent];
}

@end
