//
//  MHVMethodRequest.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/16/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHVMethod, MHVServiceResponse;

typedef void (^MHVRequestCompletion)(MHVServiceResponse *_Nullable response, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface MHVMethodRequest : NSObject

@property (nonatomic, strong, readonly) MHVMethod *method;
@property (nonatomic, strong, readonly, nullable) MHVRequestCompletion completion;
@property (nonatomic, assign) NSInteger retryAttempts;

- (instancetype)initWithMethod:(MHVMethod *)method completion:(MHVRequestCompletion _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

