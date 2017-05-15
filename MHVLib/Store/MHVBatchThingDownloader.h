//
// MHVBatchThingDownloader.h
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

#import <Foundation/Foundation.h>
#import "MHVTypeView.h"

//
// Efficiently downloads things in batches, minimizing roundtrops
// Currently, batch sizes should be <= 250. Currently, the server will only return max 250 things at a time
//
@interface MHVBatchThingDownloader : NSObject

@property (readwrite, nonatomic) NSUInteger batchSize;
@property (strong, readonly, nonatomic) MHVThingKeyCollection *keysToDownload;

- (instancetype)initWithRecordStore:(MHVLocalRecordStore *)store;

- (BOOL)addKeyToDownload:(MHVThingKey *)key;
//
// These methods only download things if the thing is NOT available locally
//
- (BOOL)addKeyForThingToEnsureDownloaded:(MHVThingKey *)key;
- (BOOL)addRangeOfKeysToEnsureDownloaded:(NSRange)range inView:(id<MHVTypeView>)view;

//
// Returns nil if no task started
//
- (MHVTask *)downloadWithCallback:(MHVTaskCompletion)callback;

@end
