//
//  HVHttpDownload.m
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
#import "HVHttpDownload.h"
#import "HVDirectory.h"

@implementation HVHttpDownload

@synthesize file = m_file;

-(id)initWithUrl:(NSURL *)url filePath:(NSString *)path andCallback:(HVTaskCompletion)callback
{
    return [self initWithUrl:url fileHandle:[NSFileHandle createOrOpenForWriteAtPath:path] andCallback:callback];
}

-(id)initWithUrl:(NSURL *)url fileHandle:(NSFileHandle *)file andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(file);
  
    self = [super initWithUrl:url andCallback:callback];
    HVCHECK_SELF;
    
    HVRETAIN(m_file, file);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_file release];
    [m_response release];
    [super dealloc];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    HVRETAIN(m_response, response);

    if (m_file)
    {
        [m_file truncateFileAtOffset:0];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_file writeData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    int statusCode = [((NSHTTPURLResponse *)m_response) statusCode];
    if (statusCode >= 400)
    {       
        HVHttpException* ex = [[HVHttpException alloc] initWithStatusCode:statusCode];
        [super handleError:ex];
        [ex release];
    }

    [self complete];
}

@end
