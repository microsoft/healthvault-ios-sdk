//
//  MHVHttp.h
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
#import <Foundation/Foundation.h>
#import "MHVAsyncTask.h"

@interface MHVHttpException : NSException
{
    NSError* m_error;
    int m_statusCode;
}

-(id) initWithError:(NSError *) error;
-(id) initWithStatusCode:(int) statusCode;

@property (readonly, nonatomic, strong) NSError* error;
@property (readonly, nonatomic) int statusCode;


@end

@interface NSMutableURLRequest (MHVURLRequestExtensions)

-(void) setContentLength:(NSUInteger) length;
-(void) setContentRangeStart:(NSUInteger) start end:(NSUInteger) end;
-(void) setContentType:(NSString *) type;
-(void) setGzipCompression;

@end

//-------------------------
//
// Async Http Task
//
//-------------------------
@class MHVHttp;

@protocol MHVHttpDelegate <NSObject>

-(void) totalBytesWritten:(NSInteger) byteCount;

@end

@interface MHVHttp : MHVTask <NSURLConnectionDataDelegate>
{
@protected
    NSMutableURLRequest* m_request;
    NSURLConnection* m_connection;
    NSInteger m_maxAttempts;
    NSInteger m_currentAttempt;
}

@property (strong, readonly, nonatomic) NSMutableURLRequest* request;
@property (strong, readonly, nonatomic) NSURLConnection* connection;

@property (readwrite, nonatomic) NSInteger maxAttempts;
@property (readonly, nonatomic) NSInteger currentAttempt;

@property (readwrite, nonatomic, weak) id<MHVHttpDelegate> delegate;

-(id) initWithUrl:(NSURL *) url andCallback:(MHVTaskCompletion) callback;
-(id) initWithVerb:(NSString *) verb url:(NSURL *) url andCallback:(MHVTaskCompletion) callback;

@end

