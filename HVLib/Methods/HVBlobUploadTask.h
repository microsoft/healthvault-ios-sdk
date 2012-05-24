//
//  HVBlobUploadTask.h
//  HVLib
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
#import "HVBlob.h"
#import "HVHttp.h"
#import "HVBlobSource.h"

//----------------------------
//
// A Task that you can use to upload blobs to HealthVault
//
// You push blobs to Urls returned by HVBeginBlobPut. 
// You upload a blob to HealthVault by splitting into equal sized chunks - also returned by HVBeginBlobPut
// You POST with application/octet-stream contentType
// You indicate the "last" chunk by setting a special header on the request [see addIsFinalUploadChunkHeader]
//
// You can upload multiple chunks in parallel for efficiency [HTTP Content-Range], although
// this this simple class does then one at a time. 
//
//----------------------------
@interface HVBlobUploadTask : HVTask<HVHttpDelegate>
{
@private
    HVBlobPutParameters* m_putParams;
    id<HVBlobSource> m_source;
    NSURL* m_blobUrl;
    int m_byteCountUploaded;
    
    id<HVHttpDelegate> m_delegate;
}

@property (readonly, nonatomic) id<HVBlobSource> source;
@property (readwrite, nonatomic, assign) id<HVHttpDelegate> delegate;

//
// The result of the task, if successful, is the Url of the blob uploaded
//
@property (readonly, nonatomic) NSString* blobUrl;

-(id) initWithData:(NSData *) data andCallback:(HVTaskCompletion) callback;
-(id) initWithFilePath:(NSString *) filePath andCallback:(HVTaskCompletion) callback;
-(id) initWithSource:(id<HVBlobSource>) source andCallback:(HVTaskCompletion) callback;

//
// Create a web request configured to upload blobs correctly
//
+(HVHttpRequestResponse *) newUploadRequestForUrl:(NSURL *) url withCallback:(HVTaskCompletion) callback;

// Mark this chunk as the last chunk. We indicate this by setting a special HealthVault header
//
+(void) addIsFinalUploadChunkHeaderTo:(NSMutableURLRequest *) request;

@end
