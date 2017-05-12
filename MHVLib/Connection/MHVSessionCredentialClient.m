//
//  MHVSessionCredentialClient.m
//  MHVLib
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

#import "MHVSessionCredentialClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVValidator.h"
#import "MHVMethod.h"
#import "DateTimeUtils.h"
#import "MobilePlatform.h"
#import "MHVSessionCredential.h"

@interface MHVSessionCredentialClient ()

@property (nonatomic, strong) id<MHVConnectionProtocol> connection;

@end

@implementation MHVSessionCredentialClient

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection
{
    MHVASSERT_PARAMETER(connection);
    
    self = [super init];
    
    if (self)
    {
        _connection = connection;
    }
    
    return self;
}

- (void)getSessionCredentialWithCompletion:(void (^_Nonnull)(MHVSessionCredential *_Nullable, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    MHVMethod *method = [MHVMethod createAuthenticatedSessionToken];
    method.parameters = [self infoSection];
    
    [self.connection executeMethod:MHVMethod.createAuthenticatedSessionToken
                        completion:^(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error)
    {
        if (error)
        {
            if (completion)
            {
                completion(nil, error);
            }
        }
        else
        {
            // Process Response
        }
    }];
}

- (NSString *)infoSection
{
    NSString *msgTimeString = [DateTimeUtils dateToUtcString:[NSDate date]];
    
    NSMutableString *stringToSign = [NSMutableString new];
    
    [stringToSign appendString:@"<content>"];
    [stringToSign appendFormat:@"<app-id>%@</app-id>", self.connection.applicationId];
    [stringToSign appendString:@"<hmac>HMACSHA256</hmac>"];
    [stringToSign appendFormat:@"<signing-time>%@</signing-time>", msgTimeString];
    [stringToSign appendString:@"</content>"];
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:self.connection.sessionCredential.sharedSecret options:0];
    NSString *hmac = [MobilePlatform computeSha256Hmac:keyData data:stringToSign];
    
    NSMutableString *xml = [NSMutableString new];
    [xml appendString:@"<info>"];
    [xml appendString:@"<auth-info>"];
    [xml appendFormat:@"<app-id>%@</app-id>", self.connection.applicationId];
    [xml appendString:@"<credential>"];
    [xml appendString:@"<appserver2>"];
    [xml appendFormat:@"<hmacSig algName=\"HMACSHA256\">%@</hmacSig>", hmac];
    [xml appendString:stringToSign];
    [xml appendString:@"</appserver2>"];
    [xml appendString:@"</credential>"];
    [xml appendString:@"</auth-info>"];
    [xml appendString:@"</info>"];
    
    return xml;
}


@end
