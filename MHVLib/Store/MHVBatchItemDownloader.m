//
// MHVBatchItemDownloader.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVCommon.h"
#import "MHVBatchItemDownloader.h"
#import "MHVClient.h"

static const NSUInteger c_defaultBatchSize = 250;

@interface MHVBatchItemDownloader ()

@property (nonatomic, strong) MHVLocalRecordStore *store;
@property (nonatomic, strong) MHVItemKeyCollection *keyBatch;

@end

@implementation MHVBatchItemDownloader

- (void)setBatchSize:(NSUInteger)batchSize
{
    if (batchSize == 0 || batchSize > c_defaultBatchSize)
    {
        self.batchSize = c_defaultBatchSize;
    }
    else
    {
        self.batchSize = batchSize;
    }
}

- (instancetype)initWithRecordStore:(MHVLocalRecordStore *)store
{
    MHVASSERT_PARAMETER(store);
    
    if (!store)
    {
        return nil;
    }

    self = [super init];
    
    if (self)
    {
        _keysToDownload = [MHVItemKeyCollection new];
        _keyBatch = [MHVItemKeyCollection new];
        _store = store;
        _batchSize = c_defaultBatchSize;
    }
    
    return self;
}

- (BOOL)addKeyToDownload:(MHVItemKey *)key
{
    MHVASSERT_PARAMETER(key);
    
    if (!key)
    {
        return NO;
    }

    [self.keysToDownload addObject:key];
    
    return YES;
}

- (BOOL)addKeyForItemToEnsureDownloaded:(MHVItemKey *)key
{
    MHVCHECK_NOTNULL(key);

    if (![self.store.data getLocalItemWithKey:key])
    {
        [self.keysToDownload addObject:key];
    }

    return TRUE;

   LError:
    return FALSE;
}

- (BOOL)addRangeOfKeysToEnsureDownloaded:(NSRange)range inView:(id<MHVTypeView>)view
{
    MHVCHECK_NOTNULL(view);

    int max = (int)range.location + (int)range.length;
    if (max > [view count])
    {
        max = (int)[view count];
    }

    for (NSUInteger i = range.location; i < max; ++i)
    {
        [self addKeyForItemToEnsureDownloaded:[view itemKeyAtIndex:i]];
    }

    return TRUE;

   LError:
    return FALSE;
}

- (MHVTask *)downloadWithCallback:(MHVTaskCompletion)callback
{
    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];

    MHVCHECK_NOTNULL(task);

    if (![self setNextBatch:task])
    {
        return nil;
    }

    [task start];
    return task;

   LError:
    return nil;
}

- (void)collectNextBatch
{
    [self.keyBatch removeAllObjects];
    
    while (self.keyBatch.count < self.batchSize)
    {
        MHVItemKey *key = [self.keysToDownload lastObject];

        if (!key)
        {
            break;
        }

        [self.keysToDownload removeLastObject];

        [self.keyBatch addObject:key];
    }
}

- (BOOL)setNextBatch:(MHVTask *)parentTask
{
    [self collectNextBatch];
    
    if (self.keyBatch.count == 0)
    {
        return FALSE;
    }

    MHVDownloadItemsTask *downloadTask = [self.store.data newDownloadItemsInRecord:self.store.record forKeys:self.keyBatch callback:^(MHVTask *task)
    {
        [self batchComplete:(MHVDownloadItemsTask *)task];
    }];

    [parentTask setNextTask:downloadTask];

    return TRUE;
}

- (void)batchComplete:(MHVDownloadItemsTask *)task
{
    [task checkSuccess];
    [self setNextBatch:task.parent];
}

@end
