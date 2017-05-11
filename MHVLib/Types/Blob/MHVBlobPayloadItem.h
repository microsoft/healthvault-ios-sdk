//
// MHVBlobPayloadItem.h
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
#import "MHVType.h"
#import "MHVBlobInfo.h"
#import "MHVBlobPutParameters.h"

@interface MHVBlobPayloadItem : MHVType

// -------------------------
//
// Data
//
// -------------------------
//
// (Required)
//
@property (readwrite, nonatomic, strong) MHVBlobInfo *blobInfo;
//
// (Required)
//
@property (readwrite, nonatomic) NSInteger length;
//
// You use THIS URL TO DOWNLOAD THE BLOB
// The download is just plain vanilla HTTP (you can use the wrappers below)
// The Url is valid for a SHORT period of time. See HealthVault service documentation for duration
//
@property (readwrite, nonatomic, strong) NSString *blobUrl;

//
// Convenience properties
//
@property (strong, readonly, nonatomic) NSString *name;
@property (strong, readonly, nonatomic) NSString *contentType;

// -------------------------
//
// Initializers
//
// -------------------------
- (instancetype)initWithBlobName:(NSString *)name contentType:(NSString *)contentType length:(NSInteger)length andUrl:(NSString *)blobUrl;

// -------------------------
//
// Methods
//
// -------------------------
- (void)downloadBlobToFilePath:(NSString *)filePath completion:(void (^)(NSError *error))completion;
- (void)downloadBlobDataWithCompletion:(void (^)(NSData *data, NSError *error))completion;

@end

@interface MHVBlobPayloadItemCollection : MHVCollection

- (NSUInteger)indexofDefaultBlob;
- (NSUInteger)indexOfBlobNamed:(NSString *)name;

- (MHVBlobPayloadItem *)itemAtIndex:(NSUInteger)index;

- (MHVBlobPayloadItem *)getDefaultBlob;
- (MHVBlobPayloadItem *)getBlobNamed:(NSString *)name;

@end
