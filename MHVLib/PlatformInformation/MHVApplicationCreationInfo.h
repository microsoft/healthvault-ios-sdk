//
//  MHVApplicationCreationInfo.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/10/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XSerializer.h"

@interface MHVApplicationCreationInfo : NSObject<XSerializable>

@property (nonatomic, strong, readonly) NSUUID *appInstanceId;
@property (nonatomic, strong, readonly) NSString *sharedSecret;
@property (nonatomic, strong, readonly) NSString *appCreationToken;

@end
