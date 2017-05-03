//
//  HVMethodCall.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
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
#import "MHVMethodCallTask.h"
#import "MHVClient.h"
#import "MHVRecordReference.h"
#import "HealthVaultRequest.h"
#import "HealthVaultResponse.h"

@interface MHVMethodCallTask (HVPrivate)

-(void) sendRequest;
-(void) handleResponse:(HealthVaultResponse *) response;

-(NSString *) serializeRequestBody;
-(id) deserializeResponse:(HealthVaultResponse *) response;

-(BOOL) shouldRetry:(HealthVaultResponse *) response;

@end

@implementation MHVMethodCallTask

@synthesize status = m_status;
@synthesize record = m_record;
@synthesize useMasterAppID = m_useMasterAppID;

-(NSString *)name
{
    return c_emptyString;
}

-(float) version
{
    return 1;
}

-(BOOL)hasError
{
    @synchronized(self)
    {
        return (m_status.hasError || super.hasError);
    }
}

-(id)initWithCallback:(HVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_status = [[MHVServerResponseStatus alloc] init];
    HVCHECK_NOTNULL(m_status);
    
    m_useMasterAppID = FALSE;
    
    return self;
    
LError:
    HVALLOC_FAIL;    
}


-(void)clearError
{
    [super clearError];
    [m_status clear];
}

-(void)checkSuccess
{
    if (m_status.hasError)
    {
        [MHVServerException throwExceptionWithStatus:m_status];
    }
    [super checkSuccess];
}

-(void)start
{
    [self prepare];
    [super start:^{
        [self sendRequest];
    }];
}

-(void) validateObject:(id)obj
{
    if ([obj respondsToSelector:@selector(validate)])
    {
        MHVClientResult* validationResult = [obj validate];
        if (validationResult.isError)
        {
            NSLog(@"%@", validationResult.description);
            [MHVClientException throwExceptionWithError:validationResult];
        }
    }
}

-(void) prepare
{
    
}

-(void)ensureRecord
{
    //
    // We need to make sure the caller specified exactly which record they are using
    // Can't use [MHVClient current].currentRecord - which won't necessarily be the one the
    // user intended to use - in multi-threaded cases
    //
    if (!m_record)
    {
        [MHVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_InvalidRecordReference)];
    }
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
    
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    if ([reader isStartElement])
    {
        [reader skipElement:reader.localName];
    }
    
    return nil;
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader asClass:(Class)cls
{
    return [NSObject newFromReader:reader withRoot:@"info" asClass:cls];
}

@end

@implementation MHVMethodCallTask (HVPrivate)

-(void)sendRequest
{
    ++m_attempt;
    HealthVaultRequest* request = nil;    
    NSString* xml = [self serializeRequestBody];
    @try 
    {
        request = [[HealthVaultRequest alloc] 
                   initWithMethodName:self.name 
                   methodVersion:self.version 
                   infoSection:xml 
                   target:self 
                   callBack:@selector(handleResponse:)];
        HVCHECK_OOM(request);
        
        self.operation = request;        
        if (m_record)
        {
            request.recordId = m_record.ID;
            request.personId = m_record.personID;
        }
        
        if (m_useMasterAppID)
        {
            request.appIdInstance = [MHVClient current].settings.masterAppID;
        }
        
        [[MHVClient current].service sendRequest:request];
    }
    @finally 
    {
        request = nil;
        xml = nil;
    }
}

-(void)handleResponse:(HealthVaultResponse *)response
{
    BOOL isDone = TRUE;
    @try 
    {
        @synchronized(self)
        {
            if ([self shouldRetry:response])
            {
                isDone = FALSE;
                NSLog(@"Retrying request \r\n%@", response.request.infoXml);
                [self sendRequest];
                return;
            }
            
            m_status.statusCode = response.statusCode;
            m_status.errorText = response.errorText;
            m_status.errorDetailsXml = response.errorContextXml;    
            m_status.webStatusCode = response.webStatusCode;
            
            if (m_status.hasError)
            {
                NSLog(@"Error for \r\n%@", response.request.infoXml);
                return;
            }
            
            id resultObj = [self deserializeResponse:response]; 
            self.result = resultObj;
        }
    }
    @catch (id ex) 
    {
        [self handleError:ex];
    }
    @finally 
    {
        if (isDone)
        {
            [self complete];
        }
    }
}

-(NSString *)serializeRequestBody
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    HVCHECK_NOTNULL(writer);
    
    @try 
    {
        HVCHECK_XWRITE([writer writeStartElement:@"info"]);
        {
            [self serializeRequestBodyToWriter:writer];
        }
        HVCHECK_XWRITE([writer writeEndElement]);
        
        return [writer newXmlString];
    }
    @finally 
    {
        writer = nil;
    }
    
LError:
    return nil;
}

-(id)deserializeResponse:(HealthVaultResponse *)response
{
    NSString* infoXml = response.infoXml;
    if ([NSString isNilOrEmpty:infoXml])
    {
        return nil;
    }

#ifdef LOGXML
    NSLog(@"%@", response.infoXml);
#endif
    
    XReader *reader = [[XReader alloc] initFromString:response.infoXml];
    HVCHECK_OOM(reader);
    @try
    {
        return [self deserializeResponseBodyFromReader:reader];
    }
    @finally 
    {
        reader = nil;
    }
}

-(BOOL)shouldRetry:(HealthVaultResponse *) response
{
    return (m_attempt < [MHVClient current].settings.maxAttemptsPerRequest && response.webStatusCode >= 500);
}
@end
