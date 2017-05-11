//
//  MHVSessionCredentialClient.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

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
    
    [self.connection executeMethod:MHVMethod.createAuthenticatedSessionToken
                           version:2
                        parameters:[self infoSection]
                          recordId:nil
                     correlationId:nil
                        completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
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
