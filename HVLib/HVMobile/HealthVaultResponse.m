//
// HealthVaultResponse.m
// HealthVault Mobile Library for iOS
//
// Copyright 2011 Microsoft Corp.
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
#import "HealthVaultResponse.h"
#import "XmlTextReader.h"
#import "XmlElement.h"
#import "MHVHttpResponse.h"
#import "HVResponse.h"

@interface HealthVaultResponse (Private)

@end

@implementation HealthVaultResponse

- (instancetype)initWithResponse:(MHVHttpResponse *)response
                         request:(HealthVaultRequest *)request
{
    if ((self = [super init]))
    {
        NSString *xml = response.responseString;

        self.request = request;
        self.responseXml = xml;
        self.webStatusCode = (int)response.statusCode;

        if (response.hasError)
        {
            self.errorText = response.errorText;
        }
        else
        {
            BOOL xmlReaderesult = [self deserializeXml:xml];

            if (!xmlReaderesult)
            {
                self.errorText = [NSString stringWithFormat:NSLocalizedString(@"Response was not a valid HealthVault response key",
                                                                              @"Format to display incorrect response"), xml];
            }
        }
    }

    return self;
}

- (void)dealloc
{
    self.errorText = nil;
    self.errorContextXml = nil;
    self.errorInfo = nil;
    self.request = nil;
    self.infoXml = nil;
    self.responseXml = nil;

    [super dealloc];
}

- (BOOL)getHasError
{
    return self.errorText != nil;
}

- (BOOL)deserializeXml:(NSString *)xml
{
    HVResponse *response = nil;

    @try
    {
        response = (HVResponse *)[NSObject newFromString:xml withRoot:@"response" asClass:[HVResponse class]];
        if (!response)
        {
            return FALSE;
        }

        HVResponseStatus *status = response.status;
        if (status)
        {
            self.statusCode = status.code;
            HVServerError *error = status.error;
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
        [response release];
    }

    return FALSE;
}

// Retrieves info section from xml.
// Info section is represented by <wc:info> xml element.
// @param xml - xml from which to retrieve info section.
// @returns info section in provided xml
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
