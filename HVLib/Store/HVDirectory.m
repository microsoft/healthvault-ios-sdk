//
//  HVDirectory.m
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

#import "HVCommon.h"
#import "HVDirectory.h"
#import "XLib.h"

@implementation NSFileManager (HVDirectorExtensions) 

-(NSURL *) pathForStandardDirectory:(NSSearchPathDirectory)name
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* urls = [fm URLsForDirectory:name inDomains:NSUserDomainMask];
    if ([NSArray isNilOrEmpty:urls])
    {
        return nil;
    }

    return [urls objectAtIndex:0];
}

-(NSURL *)documentDirectoryPath
{
    return [self pathForStandardDirectory:NSDocumentDirectory];
}

-(NSURL *)cacheDirectoryPath
{
    return [self pathForStandardDirectory:NSCachesDirectory];
}

@end

@interface HVFileNameEnumerator : NSEnumerator 
{
    NSEnumerator* m_fileNames;
}

-(id) initWithFileNames:(NSEnumerator *) fileNames;

@end

@implementation HVFileNameEnumerator

-(id)initWithFileNames:(NSEnumerator *)fileNames
{
    HVCHECK_NOTNULL(fileNames);
    
    HVRETAIN(m_fileNames, fileNames);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_fileNames release];
    [super dealloc];
}

-(id)nextObject
{
    NSString* nextPath = [m_fileNames nextObject];
    if (nextPath)
    {
        return [nextPath lastPathComponent];
    }
    
    return nil;
}
@end

@implementation HVDirectory

@synthesize url = m_path;
@synthesize stringPath = m_stringPath;

-(id)initWithPath:(NSURL *)path
{
    HVCHECK_NOTNULL(path);
    
    self = [super init];
    HVCHECK_SELF;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    HVRETAIN(m_path, path);
    HVRETAIN(m_stringPath, m_path.path);
    
    HVCHECK_SUCCESS([fm createDirectoryAtPath:m_stringPath withIntermediateDirectories:TRUE attributes:nil error:nil]);
    
    return self;
    
LError:
    HVALLOC_FAIL;
   
}

-(id)initWithRelativePath:(NSString *)path
{
    HVCHECK_STRING(path);
    
    self = [super init];
    HVCHECK_SELF;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *fullPath = [[fm documentDirectoryPath] URLByAppendingPathComponent:path];
    HVCHECK_NOTNULL(fullPath);
    
    return [self initWithPath:fullPath];
     
LError:
    HVALLOC_FAIL;
}

-(NSURL *) makeChildUrl:(NSString *)name
{
    return [m_path URLByAppendingPathComponent:name];
}

-(NSString *)makeChildPath:(NSString *)name
{
    HVCHECK_STRING(name);
    
    return [m_stringPath stringByAppendingPathComponent:name];
    
LError:
    return nil;
}

-(NSEnumerator *)getFileNames
{
    return [[NSFileManager defaultManager] enumeratorAtPath:m_stringPath];
}

-(HVDirectory *)newChildNamed:(NSString *)name
{
    NSURL *path = [self makeChildUrl:name];
    HVCHECK_NOTNULL(path);
    
    return [[HVDirectory alloc] initWithPath:path];
    
LError:
    return nil;
}

-(BOOL)fileExists:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    HVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
LError:
    return FALSE;
}

-(NSString *)makeFilePathIfExists:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    HVCHECK_NOTNULL(filePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return filePath;
    }
    
LError:
    return nil;
   
}

-(BOOL)createFile:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    HVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
LError:
    return FALSE;
}

-(BOOL)deleteFile:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    HVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

LError:
    return FALSE;
}

-(NSFileHandle *)openFileForRead:(NSString *)fileName
{
    NSString* filePath = [self makeFilePathIfExists:fileName];
    if (!filePath)
    {
        return nil;
    }
    
    return [NSFileHandle fileHandleForReadingAtPath:filePath];
}

-(NSFileHandle *)openFileForWrite:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    HVCHECK_NOTNULL(filePath);
    
    return [NSFileHandle fileHandleForWritingAtPath:filePath];
    
LError:
    return nil;
}

//---------------------
//
// HVObjectStore
//
//---------------------

-(NSEnumerator *)allKeys
{
    return [[[HVFileNameEnumerator alloc] initWithFileNames:[self getFileNames]] autorelease];
}

-(BOOL)keyExists:(NSString *)key
{
    return [self fileExists:key];
}

-(BOOL)deleteKey:(NSString *)key
{
    @try 
    {
        return [self deleteFile:key]; 
    }
    @catch (id ex) 
    {
        [ex log];
    }
    
    return FALSE;
}

-(id)newObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    NSString *filePath = [self makeFilePathIfExists:key];
    if (!filePath)
    {
        return nil;
    }
    
    return [NSObject newFromFilePath:filePath withRoot:name asClass:cls];
}

-(id)getObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    return [[self newObjectWithKey:key name:name andClass:cls] autorelease];
}

-(BOOL) putObject:(id)obj withKey:(NSString *)key andName:(NSString *)name
{
    return [XSerializer serialize:obj withRoot:name toFilePath:[self makeChildPath:key]];
}

-(NSData *)getBlob:(NSString *)key
{
    NSFileHandle *handle = [self openFileForRead:key];
    if (!handle)
    {
        return nil;
    }
    
    @try 
    {
        return [handle readDataToEndOfFile];
    }
    @finally 
    {
        [handle closeFile];
    }
}

-(BOOL)putBlob:(NSData *)blob withKey:(NSString *)key
{
    NSFileHandle *handle = [self openFileForWrite:key];
    if (handle == nil)
    {
        [self createFile:key];
        handle = [self openFileForWrite:key];
    }
    HVCHECK_NOTNULL(handle);
    
    @try 
    {
        [handle writeData:blob];
    }
    @finally 
    {
        [handle closeFile];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(id<HVObjectStore>)newChildStore:(NSString *)name
{
    return [self newChildNamed:name];
}

-(void)dealloc
{
    [m_path release];
    [super dealloc];
}
@end
