//
// MHVBatchThingDownloader.m
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
#import "MHVBatchThingDownloader.h"
#import "MHVClient.h"

static const NSUInteger c_defaultBatchSize = 250;

@interface MHVBatchThingDownloader ()

@property (nonatomic, strong) MHVLocalRecordStore *store;
@property (nonatomic, strong) MHVThingKeyCollection *keyBatch;

@end

@implementation MHVBatchThingDownloader

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
        _keysToDownload = [MHVThingKeyCollection new];
        _keyBatch = [MHVThingKeyCollection new];
        _store = store;
        _batchSize = c_defaultBatchSize;
    }
    
    return self;
}

- (BOOL)addKeyToDownload:(MHVThingKey *)key
{
    MHVASSERT_PARAMETER(key);
    
    if (!key)
    {
        return NO;
    }

    [self.keysToDownload addObject:key];
    
    return YES;
}

- (BOOL)addKeyForThingToEnsureDownloaded:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);

    if (![self.store.data getLocalThingWithKey:key])
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
        [self addKeyForThingToEnsureDownloaded:[view thingKeyAtIndex:i]];
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
        MHVThingKey *key = [self.keysToDownload lastObject];

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

    MHVDownloadThingsTask *downloadTask = [self.store.data newDownloadThingsInRecord:self.store.record forKeys:self.keyBatch callback:^(MHVTask *task)
    {
        [self batchComplete:(MHVDownloadThingsTask *)task];
    }];

    [parentTask setNextTask:downloadTask];

    return TRUE;
}

- (void)batchComplete:(MHVDownloadThingsTask *)task
{
    [task checkSuccess];
    [self setNextBatch:task.parent];
}

@end
