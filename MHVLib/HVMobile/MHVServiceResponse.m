//
// MHVServiceResponse.m
// MHVLib
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
#import "MHVServiceResponse.h"
#import "MHVResponse.h"

@implementation MHVServiceResponse

- (instancetype)initWithWebResponse:(MHVHttpServiceResponse *)response
                            request:(HealthVaultRequest *)request
{
    self = [super init];
    
    if (self)
    {
        _request = request;
        _webStatusCode = (int)response.statusCode;
        
        if (response.hasError)
        {
            _errorText = response.errorText;
        }
        else
        {
            NSString *xml = response.responseAsString;
            
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
    MHVResponse *response = (MHVResponse *)[NSObject newFromString:xml withRoot:@"response" asClass:[MHVResponse class]];
    
    if (!response)
    {
        return NO;
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
    
    return YES;
}

@end
