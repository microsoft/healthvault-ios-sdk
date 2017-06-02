//
//  MHVBlobDownloadRequest.h
//  MHVLib
//
//  Created by Michael Burford on 6/2/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHVHttpServiceOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVBlobDownloadRequest : NSObject <MHVHttpServiceOperationProtocol>

@property (nonatomic, strong, readonly)           NSURL         *url;
@property (nonatomic, strong, readonly, nullable) NSString      *toFilePath;
@property (nonatomic, assign, readonly)           BOOL          isAnonymous;

- (instancetype)initWithURL:(NSURL *)url
                 toFilePath:(NSString *_Nullable)toFilePath;

@end

NS_ASSUME_NONNULL_END
