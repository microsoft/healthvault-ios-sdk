//
//  MHVBatchItemDownloader.h
//  MHVLib
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
// Efficiently downloads items in batches, minimizing roundtrops
// Currently, batch sizes should be <= 250. Currently, the server will only return max 250 items at a time
//
@interface MHVBatchItemDownloader : NSObject
{
@private
    MHVLocalRecordStore* m_store;
    NSMutableArray* m_keysToDownload;
    NSMutableArray* m_keyBatch;
    NSUInteger m_batchSize;
}

@property (readwrite, nonatomic) NSUInteger batchSize;
@property (strong, readonly, nonatomic) NSMutableArray* keysToDownload;

-(id) initWithRecordStore:(MHVLocalRecordStore *) store;

-(BOOL) addKeyToDownload:(MHVItemKey *)key;
//
// These methods only download items if the item is NOT available locally
//
-(BOOL) addKeyForItemToEnsureDownloaded:(MHVItemKey *) key;
-(BOOL) addRangeOfKeysToEnsureDownloaded:(NSRange) range inView:(id<MHVTypeView>) view;

//
// Returns nil if no task started
//
-(MHVTask *) downloadWithCallback:(HVTaskCompletion) callback;

@end
