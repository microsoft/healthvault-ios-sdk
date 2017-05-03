//
//  HVDirectoryNameEnumerator.m
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
//
#import "HVCommon.h"
#import "HVDirectoryNameEnumerator.h"

@implementation HVDirectoryNameEnumerator

-(id)init
{
    return [self initWithPath:nil inFileMode:TRUE];
}

-(id)initWithPath:(NSURL *) path inFileMode :(BOOL)filesOnly
{
    self = [super init];
    HVCHECK_SELF;

    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSArray* fileProperties = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey,nil];
    NSDirectoryEnumerator *inner = [fm enumeratorAtURL:path
                                    includingPropertiesForKeys:fileProperties
                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                    errorHandler:nil];

    HVCHECK_NOTNULL(inner);
    m_inner = inner;
    
    m_listFilesMode = filesOnly;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(id)nextObject
{
    while (TRUE)
    {
        NSURL* pathUrl = [m_inner nextObject];
        if (pathUrl == nil)
        {
            break;
        }
        
        NSString *name;
        [pathUrl getResourceValue:&name forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [pathUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        BOOL isFile = ![isDirectory boolValue];
        if (m_listFilesMode == isFile)
        {
            return name;
        }
    }
    
    return nil;
}

@end
