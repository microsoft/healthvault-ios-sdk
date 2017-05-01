//
//  MHVHttpResponse.m
//  HVLib
//
//  Created by Michael Burford on 4/28/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVHttpResponse.h"

@implementation MHVHttpResponse

- (instancetype)initWithResponseData:(NSData *_Nullable)responseData
                          statusCode:(NSInteger)statusCode
{
    self = [super init];
    if (self)
    {
        _responseData = responseData;
        _statusCode = statusCode;
        _hasError = (statusCode >= 400);
        
        if (_hasError)
        {
            _errorText = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        }
    }
    return self;
}

- (NSString *)responseString
{
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}

@end
