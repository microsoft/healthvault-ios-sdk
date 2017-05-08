//
// MHVPersonalImage.m
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
#import "MHVCommon.h"
#import "MHVPersonalImage.h"
#import "MHVBlob.h"

static NSString *const c_typeid = @"a5294488-f865-4ce3-92fa-187cd3b58930";
static NSString *const c_typename = @"personal-image";

@implementation MHVPersonalImage

+ (NSString *)typeID
{
    return c_typeid;
}

+ (NSString *)XRootElement
{
    return c_typename;
}

+ (MHVItem *)newItem
{
    return [[MHVItem alloc] initWithType:[MHVPersonalImage typeID]];
}

+ (MHVTask *)updateImage:(NSData *)imageData contentType:(NSString *)contentType forRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVTask *uploadImageTask = nil;

    MHVCHECK_NOTNULL(imageData);
    MHVCHECK_STRING(contentType);
    MHVCHECK_NOTNULL(record);

    uploadImageTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(uploadImageTask);

    MHVGetItemsTask *getExistingTask = [record getItemsForType:[MHVPersonalImage typeID] callback:^(MHVTask *task)
    {
        MHVItem *item = nil;
        @try
        {
            item = ((MHVGetItemsTask *)task).firstItemRetrieved;
        }
        @catch (id exception)
        {
        }

        if (!item)
        {
            item = [MHVPersonalImage newItem];
            MHVCHECK_OOM(item);
        }

        id<MHVBlobSource> blobSource = [[MHVBlobMemorySource alloc] initWithData:imageData];
        MHVCHECK_OOM(blobSource);

        MHVTask *blobUploadTask = (MHVTask *)[item newUploadBlobTask:blobSource forBlobName:c_emptyString contentType:contentType record:record andCallback:^(MHVTask *task)
        {
            [task checkSuccess];
        }];
        MHVCHECK_OOM(blobUploadTask);

        [task.parent setNextTask:blobUploadTask];
    } ];

    MHVCHECK_NOTNULL(getExistingTask);

    [uploadImageTask setNextTask:getExistingTask];

    [uploadImageTask start];

    return uploadImageTask;
}

@end
