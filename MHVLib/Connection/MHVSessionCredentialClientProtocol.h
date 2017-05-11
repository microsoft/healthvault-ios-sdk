//
//  MHVSessionCredentialClientProtocol.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHVSessionCredential;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVSessionCredentialClientProtocol <NSObject>

- (void)getSessionCredentialWithCompletion:(void (^)(MHVSessionCredential *_Nullable, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
