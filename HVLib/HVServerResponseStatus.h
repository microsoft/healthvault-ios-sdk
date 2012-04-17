//
//  HVServerResponseStatus.h
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

#import <Foundation/Foundation.h>

@interface HVServerResponseStatus : NSObject
{
    int m_statusCode;
    NSString* m_errorText;
    NSString* m_errorDetails;
}

@property (readonly, nonatomic) BOOL hasError;
@property (readwrite, nonatomic) int statusCode;
@property (readwrite, nonatomic, retain) NSString* errorText;
@property (readwrite, nonatomic, retain) NSString* errorDetailsXml;

@end

@interface HVServerException : NSException 
{
    HVServerResponseStatus* m_status;
}

@property (readwrite, nonatomic, retain) HVServerResponseStatus* status;

-(id) initWithStatus:(HVServerResponseStatus *) status;

+(void) throwExceptionWithStatus:(HVServerResponseStatus *) status;

@end