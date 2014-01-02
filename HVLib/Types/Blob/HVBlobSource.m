//
//  HVBlobSource.m
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
#import "HVCommon.h"
#import "HVBlobSource.h"
#import "HVDirectory.h"

//------------------------------
//
// HVBlobMemorySource
//
//------------------------------
@implementation HVBlobMemorySource

-(NSUInteger)length
{
    return m_source.length;
}

-(void)dealloc
{
    [m_source release];
    [super dealloc];
}

-(id)init
{
    return [self initWithData:nil];
}

-(id)initWithData:(NSData *)data
{
    HVCHECK_NOTNULL(data);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_source, data);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSData *)readStartAt:(int)offset chunkSize:(int)chunkSize
{
    NSRange range = NSMakeRange(offset, chunkSize);
    return [m_source subdataWithRange:range];
}

@end

//------------------------------
//
// HVBlobFileHandleSource
//
//------------------------------
@implementation HVBlobFileHandleSource

-(NSUInteger)length
{
    return m_size;
}

-(id)init
{
    return [self initWithFilePath:nil];
}

-(id)initWithFilePath:(NSString *)filePath
{
    HVCHECK_NOTNULL(filePath);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_file, [NSFileHandle fileHandleForReadingAtPath:filePath]);
    HVCHECK_NOTNULL(m_file);
    
    m_size = [[NSFileManager defaultManager] sizeOfFileAtPath:filePath];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_file release];
    [super dealloc];
}

-(NSData *)readStartAt:(int)offset chunkSize:(int)chunkSize
{
    [m_file seekToFileOffset:offset];
    return [m_file readDataOfLength:chunkSize];
}

@end
