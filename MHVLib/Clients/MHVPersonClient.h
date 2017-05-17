//
//  MHVPersonClient.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/17/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVPersonClientProtocol.h"

@protocol MHVConnectionProtocol;

@interface MHVPersonClient : NSObject<MHVPersonClientProtocol>

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection;

@end
