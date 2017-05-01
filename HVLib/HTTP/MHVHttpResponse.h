//
//  MHVHttpResponse.h
//  HVLib
//
//  Created by Michael Burford on 4/28/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHVHttpResponse : NSObject

// The response data.
@property (nonatomic, strong, readonly, nullable) NSData *responseData;
@property (nonatomic, strong, readonly, nullable) NSString *responseString;

// The localized error text.
@property (nonatomic, strong, readonly, nullable) NSString *errorText;

// Gets error status for response. Returns YES if request has been failed.
@property (nonatomic, assign, readonly) BOOL hasError;

@property (nonatomic, assign, readonly) NSInteger statusCode;

- (instancetype _Nonnull)initWithResponseData:(NSData *_Nullable)responseData
                                   statusCode:(NSInteger)statusCode;

@end
