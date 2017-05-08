//
//  MHVHttpDownload.m
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

#import "MHVCommon.h"
#import "MHVHttpDownload.h"
#import "MHVDirectory.h"

@implementation MHVHttpDownload

@synthesize file = m_file;

-(id)initWithUrl:(NSURL *)url filePath:(NSString *)path andCallback:(MHVTaskCompletion)callback
{
    return [self initWithUrl:url fileHandle:[NSFileHandle createOrOpenForWriteAtPath:path] andCallback:callback];
}

-(id)initWithUrl:(NSURL *)url fileHandle:(NSFileHandle *)file andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(file);
  
    self = [super initWithUrl:url andCallback:callback];
    MHVCHECK_SELF;
    
    m_file = file;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    m_response = response;

    if (m_file)
    {
        [m_file truncateFileAtOffset:0];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_file writeData:data];
    m_totalBytesWritten += data.length;
    if (self.delegate)
    {
        [self.delegate totalBytesWritten:m_totalBytesWritten];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    int statusCode = (int)[((NSHTTPURLResponse *)m_response) statusCode];
    if (statusCode >= 400)
    {       
        MHVHttpException* ex = [[MHVHttpException alloc] initWithStatusCode:statusCode];
        [super handleError:ex];
    }

    [self completeTask];
}

@end
