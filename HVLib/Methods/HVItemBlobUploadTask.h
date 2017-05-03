//
//  HVBlobUploadTask.h
//  HVLib
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
//

#import <Foundation/Foundation.h>
#import "HVAsyncTask.h"
#import "HVBlobUploadTask.h"

//--------------------------------------
//
// A specialized task to:
//   - Push a blob into HealthVault
//   - Update the HVItem that owns it
//     - Update Blob Payload information
//     - Put/Commit the item into HV
//
//--------------------------------------
@interface HVItemBlobUploadTask : HVTask<HVHttpDelegate>
{
@private
    HVBlobInfo* m_blobInfo;
    HVItem *m_item; // Item that will contain the blob
    
    HVRecordReference* m_record; // Target record
}

@property (readonly, nonatomic, strong) HVBlobInfo* blobInfo;
@property (readonly, nonatomic, strong) HVItem* item;
@property (readwrite, nonatomic, weak) id<HVHttpDelegate> delegate;
@property (readonly, nonatomic, strong) HVRecordReference* record;
//
// When the file upload completes, use this to retrieve the item key
//
@property (readonly, nonatomic, strong) HVItemKey* itemKey;

-(id) initWithSource:(id<HVBlobSource>) data blobInfo:(HVBlobInfo *) blobInfo forItem:(HVItem *) item record:(HVRecordReference *) record andCallback:(HVTaskCompletion) callback;

@end
