//
//  HVMethodCall.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVMethodCallTask.h"
#import "HVClient.h"
#import "HVRecordReference.h"
#import "HealthVaultRequest.h"
#import "HealthVaultResponse.h"

@interface HVMethodCallTask (HVPrivate)

-(void) handleResponse:(HealthVaultResponse *) response;
-(NSString *) serializeRequestBody;
-(id) deserializeResponse:(HealthVaultResponse *) response;

@end

@implementation HVMethodCallTask

@synthesize status = m_status;
@synthesize record = m_record;

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
    
    m_status = [[HVServerResponseStatus alloc] init];
    HVCHECK_NOTNULL(m_status);
    
    return self;
    
LError:
    HVALLOC_FAIL;    
    
}

-(void)dealloc
{
    [m_status release];
    [m_record release];
    [super dealloc];
}

-(void)checkSuccess
{
    if (m_status.hasError)
    {
        [HVServerException throwExceptionWithStatus:m_status];
    }
    [super checkSuccess];
}

-(void )start
{
    [self prepare];
    
    NSString* xml = [self serializeRequestBody];
    HealthVaultRequest* request = nil;
    
    [self retain];
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
        
        [[HVClient current].service sendRequest:request];   
    }
    @catch (id ex) 
    {
        [self release];
        [self handleError:ex];
        @throw;
    }
    @finally 
    {
        [request release];
        [xml release];
    }
}

-(void) validateObject:(id)obj
{
    if ([obj respondsToSelector:@selector(validate)])
    {
        HVClientResult* validationResult = [obj validate];
        if (validationResult.isError)
        {
            NSLog(@"%@", validationResult.description);
            [HVClientException throwExceptionWithError:validationResult];
        }
    }
}

-(void) prepare
{
    
}

-(void)ensureRecord
{
    if (!m_record)
    {
        self.record = [HVClient current].currentRecord;
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

@implementation HVMethodCallTask (HVPrivate)

-(void)handleResponse:(HealthVaultResponse *)response
{
    @try 
    {
        @synchronized(self)
        {
            m_status.statusCode = response.statusCode;
            m_status.errorText = response.errorText;
            m_status.errorDetailsXml = response.errorContextXml;    
            if (m_status.hasError)
            {
                NSLog(@"Protocol Error for %@", response.request.infoXml);
                return;
            }
            
            id resultObj = [self deserializeResponse:response]; 
            self.result = resultObj;
            [resultObj release];
        }
    }
    @catch (id ex) 
    {
        [self handleError:ex];
    }
    @finally 
    {
        [self complete];
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
        [writer release];
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
        [reader release];
    }
}

@end