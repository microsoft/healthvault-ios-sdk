//
// MHVBlobUploadTask.h
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

#import <Foundation/Foundation.h>
#import "MHVAsyncTask.h"
#import "MHVBlobUploadTask.h"

// --------------------------------------
//
// A specialized task to:
// - Push a blob into HealthVault
// - Update the MHVThing that owns it
// - Update Blob Payload information
// - Put/Commit the thing into MHV
//
// --------------------------------------
@interface MHVThingBlobUploadTask : MHVTask

@property (readonly, nonatomic, strong) MHVBlobInfo *blobInfo;
@property (readonly, nonatomic, strong) MHVThing *thing;
@property (readonly, nonatomic, strong) MHVRecordReference *record;
//
// When the file upload completes, use this to retrieve the thing key
//
@property (readonly, nonatomic, strong) MHVThingKey *thingKey;

- (instancetype)initWithSource:(id<MHVBlobSourceProtocol>)data
                      blobInfo:(MHVBlobInfo *)blobInfo
                       forThing:(MHVThing *)thing
                        record:(MHVRecordReference *)record
                   andCallback:(MHVTaskCompletion)callback;

@end
