//
//  HVBlobPayloadItem.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVType.h"
#import "HVBlobInfo.h"
#import "HVHttpRequestResponse.h"
#import "HVHttpDownload.h"
#import "HVBlobPutParameters.h"

@interface HVBlobPayloadItem : HVType
{
@private
    HVBlobInfo* m_blobInfo;
    NSInteger m_length;
    NSString* m_blobUrl;
    NSString* m_legacyEncoding;
    NSString* m_encoding;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, retain) HVBlobInfo* blobInfo;
//
// (Required)
//
@property (readwrite, nonatomic) NSInteger length;
//
// You use THIS URL TO DOWNLOAD THE BLOB
// The download is just plain vanilla HTTP (you can use the wrappers below)
// The Url is valid for a SHORT period of time. See HealthVault service documentation for duration
//
@property (readwrite, nonatomic, retain) NSString* blobUrl;

//
// Convenience properties
//
@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) NSString* contentType;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithBlobName:(NSString *) name contentType:(NSString *) contentType length:(NSInteger) length andUrl:(NSString *) blobUrl;

//-------------------------
//
// Methods
//
//-------------------------
-(HVHttpResponse *) createDownloadTaskWithCallback:(HVTaskCompletion) callback;
-(HVHttpResponse *) downloadWithCallback:(HVTaskCompletion) callback;
-(HVHttpDownload *) downloadToFilePath:(NSString *) path andCallback:(HVTaskCompletion) callback;
-(HVHttpDownload *) downloadToFile:(NSFileHandle *) file andCallback:(HVTaskCompletion) callback;

@end

@interface HVBlobPayloadItemCollection : HVCollection

-(NSUInteger) indexofDefaultBlob;
-(NSUInteger) indexOfBlobNamed:(NSString *) name;

-(HVBlobPayloadItem *) itemAtIndex:(NSUInteger) index;

-(HVBlobPayloadItem *) getDefaultBlob;
-(HVBlobPayloadItem *) getBlobNamed:(NSString *) name;

@end
