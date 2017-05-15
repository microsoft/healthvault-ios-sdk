//
//  MHVThingCommitErrorHandler.m
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
//
#import "MHVCommon.h"
#import "MHVThingCommitErrorHandler.h"
#import "XException.h"

@implementation MHVThingCommitErrorHandler

@synthesize  maxAttemptsPerChange = m_maxAttemptsPerChange;

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_maxAttemptsPerChange = 0;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(BOOL)isHaltingException:(id)ex
{
    if ([self isServerException:ex] ||
        [self isAccessDeniedException:ex] ||
        [self isClientException:ex]
        )
    {
        return TRUE;
    }
    
    if ([self isNetworkError:ex])
    {
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)shouldRetryChange:(MHVThingChange *)change onException:(id)ex
{
    if ([self isClientException:ex] ||
        [self isSerializationException:ex] ||
        ![self isHttpException:ex]
        )
    {
        return FALSE;
    }
    
    if (m_maxAttemptsPerChange > 0 && change.attemptCount >= m_maxAttemptsPerChange)
    {
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)shouldCreateNewThingForConflict:(MHVThingChange *)change onException:(id)ex
{
    return [self isThingKeyNotFoundException:ex];
}

//
// The server returns these errors when the ThingKey of the thing we were trying to put is not found
// Translation:
//   -Thing updated already, causing a versionstamp change
//   -Thing deleted
//
-(BOOL)isThingKeyNotFoundException:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerException* serverEx = (MHVServerException *) ex;
        return serverEx.status.isThingKeyNotFound;
    }

    return FALSE;
}

-(BOOL)isSerializationException:(id)ex
{
    return ([ex isKindOfClass:[XException class]]);
}

-(BOOL)isAccessDeniedException:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerException* serverEx = (MHVServerException *) ex;
        return serverEx.status.isAccessDenied;
    }
    
    return FALSE;
}

-(BOOL)isClientException:(id)ex
{
    return ([ex isKindOfClass:[MHVClientException class]]);
}

-(BOOL)isHttpException:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerException* serverEx = (MHVServerException *) ex;
        return (serverEx.status.webStatusCode >= 400);
    }
    
    return FALSE;
}

-(BOOL)isNetworkError:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerResponseStatus* status = ((MHVServerException *) ex).status;
        return(
               status.hasError &&
               !status.isHVError &&
               status.webStatusCode <= 0
        );
    }
    
    return FALSE;
}

-(BOOL)isServerException:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerException* serverEx = (MHVServerException *) ex;
        return serverEx.status.isServerError;
    }
    
    return FALSE;
}

-(BOOL)isServerTokenException:(id)ex
{
    if ([ex isKindOfClass:[MHVServerException class]])
    {
        MHVServerException* serverEx = (MHVServerException *) ex;
        return serverEx.status.isServerTokenError;
    }
    
    return FALSE;
}


@end
