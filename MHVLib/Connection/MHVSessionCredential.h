//
//  MHVSessionCredential.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHVSessionCredential : NSObject

- (instancetype)initWithToken:(NSString *)token sharedSecret:(NSString *)sharedSecret;

@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSString *sharedSecret;

@end

NS_ASSUME_NONNULL_END
