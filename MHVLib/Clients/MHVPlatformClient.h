//
//  MHVPlatformClient.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/16/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVPlatformClientProtocol.h"

@protocol MHVConnectionProtocol;

@interface MHVPlatformClient : NSObject<MHVPlatformClientProtocol>

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection;

@end
