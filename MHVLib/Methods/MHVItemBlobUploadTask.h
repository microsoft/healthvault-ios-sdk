//
//  MHVBlobUploadTask.h
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
//

#import <Foundation/Foundation.h>
#import "MHVAsyncTask.h"
#import "MHVBlobUploadTask.h"

//--------------------------------------
//
// A specialized task to:
//   - Push a blob into HealthVault
//   - Update the MHVItem that owns it
//     - Update Blob Payload information
//     - Put/Commit the item into HV
//
//--------------------------------------
@interface MHVItemBlobUploadTask : MHVTask<MHVHttpDelegate>
{
@private
    MHVBlobInfo* m_blobInfo;
    MHVItem *m_item; // Item that will contain the blob
    
    MHVRecordReference* m_record; // Target record
}

@property (readonly, nonatomic, strong) MHVBlobInfo* blobInfo;
@property (readonly, nonatomic, strong) MHVItem* item;
@property (readwrite, nonatomic, weak) id<MHVHttpDelegate> delegate;
@property (readonly, nonatomic, strong) MHVRecordReference* record;
//
// When the file upload completes, use this to retrieve the item key
//
@property (readonly, nonatomic, strong) MHVItemKey* itemKey;

-(id) initWithSource:(id<MHVBlobSource>) data blobInfo:(MHVBlobInfo *) blobInfo forItem:(MHVItem *) item record:(MHVRecordReference *) record andCallback:(HVTaskCompletion) callback;

@end
