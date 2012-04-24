//
//  HVHttp.h
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
#import <Foundation/Foundation.h>
#import "HVAsyncTask.h"

@interface HVHttpException : NSException
{
    NSError* m_error;
}

-(id) initWithError:(NSError *) error;

@property (readonly, nonatomic) NSError* error;

@end

//-------------------------
//
// Async Http Task
//
//-------------------------
@interface HVHttp : HVTask <NSURLConnectionDataDelegate>
{
@protected
    NSMutableURLRequest* m_request;
    NSURLConnection* m_connection;
}

@property (readonly, nonatomic) NSMutableURLRequest* request;
@property (readonly, nonatomic) NSURLConnection* connection;

-(id) initWithUrl:(NSURL *) url andCallback:(HVTaskCompletion) callback;
-(id) initWithVerb:(NSString *) verb url:(NSURL *) url andCallback:(HVTaskCompletion) callback;

@end

