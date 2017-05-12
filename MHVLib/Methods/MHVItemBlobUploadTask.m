//
// MHVBlobUploadTask.m
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
#import "MHVLib.h"
#import "MHVItemBlobUploadTask.h"

@implementation MHVItemBlobUploadTask

- (MHVItemKey *)itemKey
{
    return (MHVItemKey *)self.result;
}

- (instancetype)initWithSource:(id<MHVBlobSourceProtocol>)data
                      blobInfo:(MHVBlobInfo *)blobInfo
                       forItem:(MHVItem *)item
                        record:(MHVRecordReference *)record
                   andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(data);
    MHVCHECK_NOTNULL(blobInfo);
    MHVCHECK_NOTNULL(record);

    self = [super initWithCallback:callback];
    if (self)
    {
        _blobInfo = blobInfo;
        _item = item;
        _record = record;
        //
        // Step 1 - upload the blob to HealthVault
        // If that succeeds, then update the item
        //
        MHVBlobUploadTask *uploadTask = [[MHVBlobUploadTask alloc] initWithSource:data record:record andCallback:^(MHVTask *task)
        {
            [self uploadBlobComplete:task];
        }];

        MHVCHECK_NOTNULL(uploadTask);

        [self setNextTask:uploadTask];
    }

    return self;
}

#pragma mark - Internal methods

- (void)uploadBlobComplete:(MHVTask *)task
{
    MHVBlobUploadTask *uploadTask = (MHVBlobUploadTask *)task;
    //
    // The URL for this blob
    //
    NSString *blobUrl = uploadTask.blobUrl;

    //
    // Update the item with the new Blob & Length info
    // The Item will now contain an updated reference to the new blob
    //
    [self updateBlobWithUrl:blobUrl andLength:uploadTask.source.length];
    //
    // Step 2. push item into MHV
    //
    [self putItemInHV];
}

- (void)updateBlobWithUrl:(NSString *)url andLength:(NSInteger)length
{
    MHVBlobPayloadItem *blobItem = [[MHVBlobPayloadItem alloc] init];

    MHVCHECK_OOM(blobItem);

    blobItem.blobInfo = self.blobInfo;
    blobItem.length = length;
    blobItem.blobUrl = url;

    [self.item.blobs addOrUpdateBlob:blobItem];
}

- (void)putItemInHV
{
    MHVPutItemsTask *putTask = [[MHVClient current].methodFactory newPutItemForRecord:self.record item:self.item andCallback:^(MHVTask *task)
    {
        [task checkSuccess];
        self.result = ((MHVPutItemsTask *)task).firstKey;
    } ];

    putTask.record = self.record;
    [self setNextTask:putTask];
}

@end
