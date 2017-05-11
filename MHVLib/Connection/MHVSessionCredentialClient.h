//
//  MHVSessionCredentialClient.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVSessionCredentialClientProtocol.h"

@protocol MHVConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface MHVSessionCredentialClient : NSObject<MHVSessionCredentialClientProtocol>

- (instancetype )initWithConnection:(id<MHVConnectionProtocol>)connection;

@end

NS_ASSUME_NONNULL_END
