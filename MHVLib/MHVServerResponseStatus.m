//
// MHVServerResult.m
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

#import "MHVCommon.h"
#import "MHVServerResponseStatus.h"

@implementation MHVServerResponseStatus

- (instancetype)initWithStatusCode:(MHVServerStatusCode)code
{
    self = [super init];
    if (self)
    {
        _statusCode = code;
    }

    return self;
}

- (BOOL)hasError
{
    return self.statusCode != 0 ||
           self.errorText != nil ||
           self.webStatusCode >= 400;
}

- (BOOL)isHVError
{
    return self.statusCode > 0;
}

- (BOOL)isWebError
{
    return self.webStatusCode >= 400;
}

- (BOOL)isAccessDenied
{
    switch (self.statusCode)
    {
        case MHVServerStatusCodeAccessDenied:
        case MHVServerStatusCodeInvalidApp:
        case MHVServerStatusCodeInvalidApplicationAuthorization:
            return TRUE;
            
        default:
            break;
    }

    return FALSE;
}

- (BOOL)isServerTokenError
{
    switch (self.statusCode)
    {
        case MHVServerStatusCodeAuthSessionTokenExpired:
        case MHVServerStatusCodeCredentialTokenExpired:
            return TRUE;
            
        default:
            break;
    }

    return FALSE;
}

- (BOOL)isInvalidTarget
{
    switch (self.statusCode)
    {
        case MHVServerStatusCodeInvalidRecord:
        case MHVServerStatusCodeInvalidPerson:
            return TRUE;

        default:
            break;
    }

    return FALSE;
}

- (BOOL)isThingNotFound
{
    return self.statusCode == MHVServerStatusCodeInvalidThing;
}

- (BOOL)isVersionStampMismatch
{
    return self.statusCode == MHVServerStatusCodeVersionStampMismatch;
}

- (BOOL)isThingKeyNotFound
{
    switch (self.statusCode)
    {
        case MHVServerStatusCodeInvalidThing:
        case MHVServerStatusCodeVersionStampMismatch:
        case MHVServerStatusCodeInvalidXml:
            return TRUE;

        default:
            break;
    }

    return FALSE;
}

- (BOOL)isServerError
{
    switch (self.statusCode)
    {
        case MHVServerStatusCodeFailed:
        case MHVServerStatusCodeRequestTimedOut:
            return TRUE;
            
        default:
            break;
    }

    return FALSE;
}

- (BOOL)isStatusCode:(MHVServerStatusCode)code
{
    return self.statusCode == (int)code;
}

- (NSString *)description
{
    if (self.isHVError)
    {
        return [NSString stringWithFormat:@"[StatusCode=%d], %@", self.statusCode, self.errorText];
    }

    return self.errorText;
}

- (void)clear
{
    self.statusCode = MHVServerStatusCodeOK;
    self.errorText = nil;
    self.errorDetailsXml = nil;
    self.webStatusCode = 0;
}

@end

@implementation MHVServerException

- (instancetype)initWithStatus:(MHVServerResponseStatus *)status
{
    MHVCHECK_NOTNULL(status);

    self = [super initWithName:@"MHVServerException" reason:c_emptyString userInfo:nil];
    if (self)
    {
        _status = status;
    }

    return self;
}

- (NSString *)description
{
    return self.status.description;
}

+ (void)throwExceptionWithStatus:(MHVServerResponseStatus *)status
{
    @throw [[MHVServerException alloc] initWithStatus:status];
}

@end
