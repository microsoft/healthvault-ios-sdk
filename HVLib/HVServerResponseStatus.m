//
//  HVServerResult.m
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

#import "HVCommon.h"
#import "HVServerResponseStatus.h"

@implementation HVServerResponseStatus

@synthesize statusCode = m_statusCode;
@synthesize errorText  = m_errorText;
@synthesize errorDetailsXml = m_errorDetails;

-(BOOL)hasError
{
    return (m_statusCode != 0 || m_errorText != nil);
}

-(void)dealloc
{
    [m_errorText release];
    [m_errorDetails release];
    [super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"[StatusCode=%d], %@", m_statusCode, m_errorText];
}

@end

@implementation HVServerException

@synthesize status = m_status;

-(id)initWithStatus:(HVServerResponseStatus *)status
{
    HVCHECK_NOTNULL(status);
    
    self = [super initWithName:@"HVServerException" reason:c_emptyString userInfo:nil];
    HVCHECK_SELF;
    
    self.status = status;
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(NSString *)description
{
    return m_status.description;
}
                                
-(void)dealloc
{
    [m_status release];
    [super dealloc];
}

+(void)throwExceptionWithStatus:(HVServerResponseStatus *)status
{
    @throw [[HVServerException alloc] initWithStatus:status];
}

@end