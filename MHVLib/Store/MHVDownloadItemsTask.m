//
// MHVDownloadItemsTask.m
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
#import "MHVDownloadItemsTask.h"

@implementation MHVDownloadItemsTask

- (BOOL)didKeysDownload
{
    return ![MHVCollection isNilOrEmpty:self.downloadedKeys];
}

- (MHVItemKey *)firstKey
{
    return (self.didKeysDownload) ? [self.downloadedKeys objectAtIndex:0] : nil;
}

- (instancetype)initWithCallback:(MHVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    
    if (self)
    {
        _downloadedKeys = [MHVItemKeyCollection new];
    }

    return self;
}

- (void)recordItemsAsDownloaded:(MHVItemCollection *)items
{
    MHVItemKeyCollection *keys = self.downloadedKeys;

    self.result = keys;

    for (NSUInteger i = 0; i < items.count; ++i)
    {
        [keys addObject:[items itemAtIndex:i].key];
    }
}

@end
