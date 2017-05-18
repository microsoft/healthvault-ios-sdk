//
//  MHVClientFactory.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/18/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVClientFactory.h"
#import "MHVPersonClient.h"
#import "MHVPlatformClient.h"
#import "MHVSessionCredentialClient.h"

@implementation MHVClientFactory

- (id<MHVPersonClientProtocol>)personClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVPersonClient alloc] initWithConnection:connection];
}

- (id<MHVPlatformClientProtocol>)platformClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVPlatformClient alloc] initWithConnection:connection];
}

- (id<MHVThingClientProtocol>)thingClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return nil;
}

- (id<MHVVocabularyClientProtocol>)vocabularyClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return nil;
}

- (id<MHVSessionCredentialClientProtocol>)credentialClientWithConnection:(id<MHVConnectionProtocol>)connection
{
    return [[MHVSessionCredentialClient alloc] initWithConnection:connection];
}

@end
