//
//  MHVClientFactory.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/18/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHVConnectionProtocol, MHVPersonClientProtocol, MHVPlatformClientProtocol, MHVThingClientProtocol, MHVVocabularyClientProtocol, MHVSessionCredentialClientProtocol;

@interface MHVClientFactory : NSObject

- (id<MHVPersonClientProtocol>)personClientWithConnection:(id<MHVConnectionProtocol>)connection;

- (id<MHVPlatformClientProtocol>)platformClientWithConnection:(id<MHVConnectionProtocol>)connection;

- (id<MHVThingClientProtocol>)thingClientWithConnection:(id<MHVConnectionProtocol>)connection;

- (id<MHVVocabularyClientProtocol>)vocabularyClientWithConnection:(id<MHVConnectionProtocol>)connection;

- (id<MHVSessionCredentialClientProtocol>)credentialClientWithConnection:(id<MHVConnectionProtocol>)connection;

@end
