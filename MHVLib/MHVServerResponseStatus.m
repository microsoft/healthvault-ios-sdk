//
//  MHVServerResult.m
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

#import "MHVCommon.h"
#import "MHVServerResponseStatus.h"

@implementation MHVServerResponseStatus

@synthesize statusCode = m_statusCode;
@synthesize errorText  = m_errorText;
@synthesize errorDetailsXml = m_errorDetails;

-(BOOL)hasError
{
    return (m_statusCode != 0 ||
            m_errorText != nil ||
            m_webStatusCode >= 400);
}

-(BOOL)isHVError
{
    return (m_statusCode > 0);
}

@synthesize webStatusCode = m_webStatusCode;

-(BOOL)isWebError
{
    return (m_webStatusCode >= 400);
}

-(BOOL)isAccessDenied
{
    switch (m_statusCode)
    {
        default:
            return FALSE;

        case MHVServerStatusCodeAccessDenied:
        case MHVServerStatusCodeInvalidApp:
        case MHVServerStatusCodeInvalidApplicationAuthorization:
            break;
    }
    
    return TRUE;
}

-(BOOL)isServerTokenError
{
    switch (m_statusCode)
    {
        default:
            return FALSE;
            
        case MHVServerStatusCodeAuthSessionTokenExpired:
        case MHVServerStatusCodeCredentialTokenExpired:
            break;
    }
    
    return TRUE;
}

-(BOOL)isInvalidTarget
{
    switch (m_statusCode)
    {
        default:
            return FALSE;
            
        case MHVServerStatusCodeInvalidRecord:
        case MHVServerStatusCodeInvalidPerson:
            break;
    }
    
    return TRUE;
}

-(BOOL)isItemNotFound
{
    return (m_statusCode == MHVServerStatusCodeInvalidItem);
}

-(BOOL)isVersionStampMismatch
{
    return (m_statusCode == MHVServerStatusCodeVersionStampMismatch);
}

-(BOOL)isItemKeyNotFound
{
    switch (m_statusCode)
    {
        default:
            return FALSE;
            
        case MHVServerStatusCodeInvalidItem:
        case MHVServerStatusCodeVersionStampMismatch:
        case MHVServerStatusCodeInvalidXml:
            break;
    }
    
    return TRUE;
}

-(BOOL)isServerError
{
    switch (m_statusCode)
    {
        default:
            return FALSE;
            
        case MHVServerStatusCodeFailed:
        case MHVServerStatusCodeRequestTimedOut:
            break;
    }
    
    return TRUE;
}

-(id)initWithStatusCode:(enum MHVServerStatusCode)code
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_statusCode = code;
    
    return self;

LError:
    MHVALLOC_FAIL;
}


-(BOOL)isStatusCode:(enum MHVServerStatusCode)code
{
    return (m_statusCode == (int) code);
}

-(NSString *)description
{
    if (self.isHVError)
    {
        return [NSString stringWithFormat:@"[StatusCode=%d], %@", m_statusCode, m_errorText];
    }
    
    return m_errorText;
}

-(void)clear
{
    m_statusCode = MHVServerStatusCodeOK;
    m_errorText = nil;
    m_errorDetails = nil;
    m_webStatusCode = 0;
}

@end

@implementation MHVServerException

@synthesize status = m_status;

-(id)initWithStatus:(MHVServerResponseStatus *)status
{
    MHVCHECK_NOTNULL(status);
    
    self = [super initWithName:@"MHVServerException" reason:c_emptyString userInfo:nil];
    MHVCHECK_SELF;
    
    self.status = status;
    
    return self;

LError:
    MHVALLOC_FAIL;
}

-(NSString *)description
{
    return m_status.description;
}
                                

+(void)throwExceptionWithStatus:(MHVServerResponseStatus *)status
{
    @throw [[MHVServerException alloc] initWithStatus:status];
}

@end
