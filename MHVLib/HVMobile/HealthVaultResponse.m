//
// HealthVaultResponse.m
// HealthVault Mobile Library for iOS
//
// Copyright 2017 Microsoft Corp.
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
#import "HealthVaultResponse.h"
#import "MHVResponse.h"

@implementation HealthVaultResponse

- (instancetype)initWithWebResponse:(MHVHttpServiceResponse *)response
                            request:(HealthVaultRequest *)request
{
    self = [super init];
    if (self)
    {
        NSString *xml = response.responseAsString;
        
        _request = request;
        _responseXml = xml;
        _webStatusCode = (int)response.statusCode;
        
        if (response.hasError)
        {
            _errorText = response.errorText;
        }
        else
        {
            BOOL xmlReaderesult = [self deserializeXml:xml];
            
            if (!xmlReaderesult)
            {
                _errorText = [NSString stringWithFormat:NSLocalizedString(@"Response was not a valid HealthVault response key",
                                                                          @"Format to display incorrect response"), xml];
            }
        }
    }
    
    return self;
}

- (BOOL)getHasError
{
    return self.errorText != nil;
}

- (BOOL)deserializeXml:(NSString *)xml
{
    MHVResponse *response = nil;
    
    @try
    {
        response = (MHVResponse *)[NSObject newFromString:xml withRoot:@"response" asClass:[MHVResponse class]];
        if (!response)
        {
            return FALSE;
        }
        
        MHVResponseStatus *status = response.status;
        if (status)
        {
            self.statusCode = status.code;
            MHVServerError *error = status.error;
            if (status.error)
            {
                self.errorText = error.message;
                self.errorContextXml = error.context;
                self.errorInfo = error.errorInfo;
            }
        }
        
        self.infoXml = response.body;
        
        return TRUE;
    }
    @catch (id ex)
    {
        [ex log];
    }
    @finally
    {
        response = nil;
    }
    
    return FALSE;
}

- (NSString *)getInfoFromXml:(NSString *)xml
{
    NSRange startInfoTagPosition = [xml rangeOfString:@"<wc:info"];
    NSRange endInfoTagPosition = [xml rangeOfString:@"</wc:info>" options:NSBackwardsSearch];
    
    if (startInfoTagPosition.location == NSNotFound || endInfoTagPosition.location == NSNotFound)
    {
        return nil;
    }
    
    NSRange infoTagRange;
    infoTagRange.location = startInfoTagPosition.location;
    infoTagRange.length = endInfoTagPosition.location + endInfoTagPosition.length - startInfoTagPosition.location;
    
    NSString *info = [xml substringWithRange:infoTagRange];
    
    return info;
}

@end
