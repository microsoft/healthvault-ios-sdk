//
//  HVServerResponseStatus.h
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

#import <Foundation/Foundation.h>

//
// Common Status codes
//
enum HVServerStatusCode 
{
    HVServerStatusCodeOK = 0,
    HVServerStatusCodeFailed = 1,
    HVServerStatusCodeBadHttp = 2,
    HVServerStatusCodeInvalidXml = 3,
    HVServerStatusCodeInvalidRequestIntegrity = 4,
    HVServerStatusCodeBadMethod = 5,
    HVServerStatusCodeInvalidApp = 6,
    HVServerStatusCodeCredentialTokenExpired = 7,
    HVServerStatusCodeInvalidToken = 8,
    HVServerStatusCodeInvalidPerson = 9,
    HVServerStatusCodeInvalidRecord = 10,
    HVServerStatusCodeAccessDenied = 11,
    HVServerStatusCodeInvalidItem = 13,
    HVServerStatusCodeInvalidFilter = 15,
    HVServerStatusCodeInvalidApplicationAuthorization = 18,
    HVServerStatusCodeTypeIDNotFound = 19,
    HVServerStatusCodeDuplicateCredentialFound = 22,
    HVServerStatusCodeInvalidRecordState = 37,
    HVServerStatusCodeRequestTimedOut = 0x31,
    HVServerStatusCodeVersionStampMismatch = 0x3d,
    HVServerStatusCodeAuthSessionTokenExpired = 0x41,
    HVServerStatusCodeRecordQuotaExceeded = 0x44,
    HVServerStatusCodeApplicationLimitExceeded = 0x5d,
    HVServerStatusCodeVocabAccessDenied = 130,
    HVServerStatusCodeInvalidAge = 157,
    HVServerStatusCodeInvalidIPAddress = 158,
    HVServerStatusCodeMaxRecordsExceeded = 160
};

@interface HVServerResponseStatus : NSObject
{
@private
    int m_statusCode;
    NSString* m_errorText;
    NSString* m_errorDetails;
    int m_webStatusCode;
}

-(id) initWithStatusCode:(enum HVServerStatusCode) code;

@property (readonly, nonatomic) BOOL hasError;
//
// If status code is <= 0, then the error was due to Connectivity or
// other failure, but not a HealthVault failure. 
//
@property (readonly, nonatomic) BOOL isHVError;
@property (readwrite, nonatomic) int statusCode;
@property (readwrite, nonatomic, strong) NSString* errorText;
@property (readwrite, nonatomic, strong) NSString* errorDetailsXml;
//
// Web result code, if any
//
@property (readwrite, nonatomic) int webStatusCode;

@property (readonly, nonatomic) BOOL isWebError;
@property (readonly, nonatomic) BOOL isAccessDenied;
@property (readonly, nonatomic) BOOL isServerTokenError;
@property (readonly, nonatomic) BOOL isInvalidTarget;
@property (readonly, nonatomic) BOOL isItemNotFound;
@property (readonly, nonatomic) BOOL isVersionStampMismatch;
@property (readonly, nonatomic) BOOL isItemKeyNotFound;
@property (readonly, nonatomic) BOOL isServerError;

-(void) clear;

@end

@interface HVServerException : NSException 
{
    HVServerResponseStatus* m_status;
}

@property (readwrite, nonatomic, strong) HVServerResponseStatus* status;

-(id) initWithStatus:(HVServerResponseStatus *) status;

+(void) throwExceptionWithStatus:(HVServerResponseStatus *) status;

@end
