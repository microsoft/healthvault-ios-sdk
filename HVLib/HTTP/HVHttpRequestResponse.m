//
//  HVURLRequestExtensions.m
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
#import "HVCommon.h"
#import "HVHttpRequestResponse.h"

@implementation HVHttpResponse

@synthesize response = m_response;

-(NSMutableData *)responseBody
{
    return (NSMutableData *) self.result;
}


-(void)start
{
    HVENSURE(m_responseBody, NSMutableData);
    [m_responseBody setLength:0];
    
    self.result = m_responseBody;
    
    [super start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    m_response = response;
    [m_responseBody setLength:0];    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_responseBody appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    int statusCode = (int)[((NSHTTPURLResponse *)m_response) statusCode];
    if (statusCode != 200)
    {       
        HVHttpException* ex = [[HVHttpException alloc] initWithStatusCode:statusCode];
        [super handleError:ex];
    }
    
    [self complete];
}

@end

@implementation HVHttpRequestResponse

@synthesize requestBody = m_requestBody;


-(void)start
{
    if (m_requestBody)
    {
        [m_request setContentLength:m_requestBody.length];
        [m_request setHTTPBody:m_requestBody];
    }
    
    [super start];
}

@end
