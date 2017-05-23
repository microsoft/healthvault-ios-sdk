//
//  MHVRestRequest.h
//  MHVLib
//
//  Created by Michael Burford on 5/22/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVHttpServiceOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVRestRequest : NSObject <MHVHttpServiceOperationProtocol>

@property (nonatomic, strong, readonly)           NSString      *path;
@property (nonatomic, strong, readonly)           NSString      *httpMethod;
@property (nonatomic, strong, readonly, nullable) NSDictionary  *pathParams;
@property (nonatomic, strong, readonly, nullable) NSDictionary  *queryParams;
@property (nonatomic, strong, readonly, nullable) NSDictionary  *formParams;
@property (nonatomic, strong, readonly, nullable) id            body;
@property (nonatomic, assign, readonly)           BOOL          isAnonymous;

@property (nonatomic, strong, readonly)           NSURL         *url;

- (instancetype)initWithPath:(NSString *)path
                  httpMethod:(NSString *)httpMethod
                  pathParams:(NSDictionary<NSString *, NSString *> *_Nullable)pathParams
                 queryParams:(NSDictionary<NSString *, NSString *> *_Nullable)queryParams
                  formParams:(NSDictionary<NSString *, NSString *> *_Nullable)formParams
                        body:(NSData *_Nullable)body
                 isAnonymous:(BOOL)isAnonymous;

- (instancetype)initWithURL:(NSURL *)url
                 httpMethod:(NSString *)httpMethod
                       body:(NSData *_Nullable)body
                isAnonymous:(BOOL)isAnonymous;

- (void)updateUrlWithServiceUrl:(NSURL *)serviceUrl;

@end

NS_ASSUME_NONNULL_END
