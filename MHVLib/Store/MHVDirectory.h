//
//  MHVDirectory.h
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

#import <Foundation/Foundation.h>
#import "MHVObjectStore.h"
#import "XConverter.h"
#import "MHVDirectoryNameEnumerator.h"

@interface NSFileManager (MHVExtensions) 

-(NSURL *) pathForStandardDirectory:(NSSearchPathDirectory) name;
-(NSURL *) documentDirectoryPath;
-(NSURL *) cacheDirectoryPath;

-(long) sizeOfFileAtPath:(NSString *) path;

+(NSString *) mimeTypeForFile:(NSString *) filePath;
+(NSString *) mimeTypeForFileExtension:(NSString *) ext;
+(NSString *) fileExtForMimeType:(NSString *) mimeType;

@end

@interface NSFileHandle (MHVExtensions)

+(NSFileHandle *) createOrOpenForWriteAtPath:(NSString *) path;

-(BOOL) writeText:(NSString *) text;
-(BOOL) appendText:(NSString *) text;

+(NSString *) stringFromFileAtPath:(NSString *) path;

@end

//
// MHVDirectory implements all methods in MHVObjectStore
// ALL serializable objects must inherit from XSerializableType
//
@interface MHVDirectory : NSObject <MHVObjectStore>
{
@private
    NSURL *m_path;
    NSString *m_stringPath;
    XConverter* m_converter;  // Cached, to speed up deserialization/serialization
}

@property (readonly, nonatomic, strong) NSURL* url;
@property (readonly, nonatomic, strong) NSString* stringPath;

-(id) initWithPath:(NSURL *) path;
-(id) initWithRelativePath:(NSString *) path;

-(NSURL *) makeChildUrl:(NSString *) name;
-(NSString *) makeChildPath:(NSString *) name;

-(MHVDirectory *) newChildNamed:(NSString *) name;

-(NSEnumerator *) getFileNames;
-(NSEnumerator *) getDirectoryNames;

-(BOOL) fileExists:(NSString *) fileName;
-(NSString *) makeFilePathIfExists:(NSString *) fileName;
-(BOOL) createFile:(NSString *) fileName;
-(BOOL) deleteFile:(NSString *) fileName;

+(void) deleteUrl:(NSURL *) url;

-(NSDictionary *) getFileProperties:(NSString *) fileName;
-(BOOL) isFileNamed:(NSString *) name aged:(NSTimeInterval) maxAge;

-(NSFileHandle *) openFileForRead:(NSString *) fileName;
-(NSFileHandle *) openFileForWrite:(NSString *) fileName;

-(id) newObjectWithKey:(NSString *) key name:(NSString *) name andClass:(Class) cls;

@end
