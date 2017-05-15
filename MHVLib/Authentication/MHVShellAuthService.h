//
//  MHVShellAuthService.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/15/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVShellAuthServiceProtocol.h"

@class MHVConfiguration;

@protocol MHVBrowserAuthBrokerProtocol;

@interface MHVShellAuthService : NSObject<MHVShellAuthServiceProtocol>

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                           authBroker:(id<MHVBrowserAuthBrokerProtocol>)authBroker;


@end
