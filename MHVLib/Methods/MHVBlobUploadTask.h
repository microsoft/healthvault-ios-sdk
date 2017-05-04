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
#import "MHVBlob.h"
#import "MHVHttp.h"
#import "MHVBlobSource.h"
#import "MHVRecordReference.h"

//----------------------------
//
// A Task that you can use to upload blobs to HealthVault
//
// You push blobs to Urls returned by MHVBeginBlobPut. 
// You upload a blob to HealthVault by splitting into equal sized chunks - also returned by MHVBeginBlobPut
// You POST with application/octet-stream contentType
// You indicate the "last" chunk by setting a special header on the request [see addIsFinalUploadChunkHeader]
//
// You can upload multiple chunks in parallel for efficiency [HTTP Content-Range], although
// this this simple class does then one at a time. 
//
//----------------------------
@interface MHVBlobUploadTask : MHVTask<MHVHttpDelegate>
{
@private
    MHVBlobPutParameters* m_putParams;
    id<MHVBlobSource> m_source;
    NSURL* m_blobUrl;
    int m_byteCountUploaded;
    
    MHVRecordReference* m_record; // Target record
}

@property (strong, readonly, nonatomic) id<MHVBlobSource> source;
@property (readwrite, nonatomic, weak) id<MHVHttpDelegate> delegate;
@property (strong, readonly, nonatomic) MHVRecordReference* record;

//
// The result of the task, if successful, is the Url of the blob uploaded
//
@property (strong, readonly, nonatomic) NSString* blobUrl;

-(id) initWithData:(NSData *) data record:(MHVRecordReference *) record andCallback:(MHVTaskCompletion) callback;
-(id) initWithFilePath:(NSString *) filePath record:(MHVRecordReference *) record andCallback:(MHVTaskCompletion) callback;
-(id) initWithSource:(id<MHVBlobSource>) source record:(MHVRecordReference *) record andCallback:(MHVTaskCompletion) callback;

//
// Create a web request configured to upload blobs correctly
//
+(MHVHttpRequestResponse *) newUploadRequestForUrl:(NSURL *) url withCallback:(MHVTaskCompletion) callback;

// Mark this chunk as the last chunk. We indicate this by setting a special HealthVault header
//
+(void) addIsFinalUploadChunkHeaderTo:(NSMutableURLRequest *) request;

@end
