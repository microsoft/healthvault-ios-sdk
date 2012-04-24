//
//  HVHttp.m
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
#import "HVHttp.h"
#import "HVClient.h"

@implementation HVHttpException

@synthesize error = m_error;

-(id)initWithError:(NSError *)error
{
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_error, error);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_error dealloc];
    [super dealloc];
}

@end

@implementation HVHttp

-(NSMutableURLRequest *)request
{
    HVENSURE(m_request, NSMutableURLRequest);
    return m_request;
}

@synthesize connection = m_connection;

-(id)initWithUrl:(NSURL *)url andCallback:(HVTaskCompletion)callback
{
    return [self initWithVerb:nil url:url andCallback:callback];
}

-(id)initWithVerb:(NSString *)verb url:(NSURL *)url andCallback:(HVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.request.URL = url;
    if (verb)
    {
        self.request.HTTPMethod = verb;
    }
 
    HVCHECK_NOTNULL(m_request);
    if ([HVClient current].settings.httpTimeout > 0)
    {
        m_request.timeoutInterval = [HVClient current].settings.httpTimeout;
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_request release];
    [m_connection release];
    [super dealloc];
}

-(void)start
{
    if (!m_connection)
    {
        m_connection = [[NSURLConnection alloc] initWithRequest:m_request delegate:self];
    }
    if (!self.operation)
    {
        self.operation = m_connection;
    }
    
    [super start];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HVHttpException* ex = [[HVHttpException alloc] initWithError:error];
    [super handleError:ex];
    [ex release];
    
    [self complete];
}

@end
