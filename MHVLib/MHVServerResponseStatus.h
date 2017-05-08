//
// MHVServerResponseStatus.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
typedef NS_ENUM (NSInteger, MHVServerStatusCode)
{
    MHVServerStatusCodeOK = 0,
    MHVServerStatusCodeFailed = 1,
    MHVServerStatusCodeBadHttp = 2,
    MHVServerStatusCodeInvalidXml = 3,
    MHVServerStatusCodeInvalidRequestIntegrity = 4,
    MHVServerStatusCodeBadMethod = 5,
    MHVServerStatusCodeInvalidApp = 6,
    MHVServerStatusCodeCredentialTokenExpired = 7,
    MHVServerStatusCodeInvalidToken = 8,
    MHVServerStatusCodeInvalidPerson = 9,
    MHVServerStatusCodeInvalidRecord = 10,
    MHVServerStatusCodeAccessDenied = 11,
    MHVServerStatusCodeInvalidItem = 13,
    MHVServerStatusCodeInvalidFilter = 15,
    MHVServerStatusCodeInvalidApplicationAuthorization = 18,
    MHVServerStatusCodeTypeIDNotFound = 19,
    MHVServerStatusCodeDuplicateCredentialFound = 22,
    MHVServerStatusCodeInvalidRecordState = 37,
    MHVServerStatusCodeRequestTimedOut = 0x31,
    MHVServerStatusCodeVersionStampMismatch = 0x3d,
    MHVServerStatusCodeAuthSessionTokenExpired = 0x41,
    MHVServerStatusCodeRecordQuotaExceeded = 0x44,
    MHVServerStatusCodeApplicationLimitExceeded = 0x5d,
    MHVServerStatusCodeVocabAccessDenied = 130,
    MHVServerStatusCodeInvalidAge = 157,
    MHVServerStatusCodeInvalidIPAddress = 158,
    MHVServerStatusCodeMaxRecordsExceeded = 160
};

@interface MHVServerResponseStatus : NSObject

- (instancetype)initWithStatusCode:(MHVServerStatusCode)code;

@property (readonly, nonatomic) BOOL hasError;
//
// If status code is <= 0, then the error was due to Connectivity or
// other failure, but not a HealthVault failure.
//
@property (readonly, nonatomic) BOOL isHVError;
@property (readwrite, nonatomic) int statusCode;
@property (readwrite, nonatomic, strong) NSString *errorText;
@property (readwrite, nonatomic, strong) NSString *errorDetailsXml;
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

- (void)clear;

@end

@interface MHVServerException : NSException

@property (readwrite, nonatomic, strong) MHVServerResponseStatus *status;

- (instancetype)initWithStatus:(MHVServerResponseStatus *)status;

+ (void)throwExceptionWithStatus:(MHVServerResponseStatus *)status;

@end
