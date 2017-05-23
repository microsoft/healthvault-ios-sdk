//
//  MHVHttpServiceOperationProtocol.h
//  MHVLib
//
//  Created by Michael Burford on 5/22/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHVHttpServiceOperationProtocol <NSObject>

/**
 A Boolean representing whether the operation call requires authentication
 */
@property (nonatomic, assign, readonly) BOOL isAnonymous;

@end
