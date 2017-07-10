//
//  MHVCacheStatus.h
//  Pods
//
//  Created by Nathan Malubay on 7/7/17.
//
//

#import <Foundation/Foundation.h>
#import "MHVCacheStatusProtocol.h"

@class MHVCachedRecord;

@interface MHVCacheStatus : NSObject<MHVCacheStatusProtocol>

- (instancetype)initWithCachedRecord:(MHVCachedRecord *)cachedRecord;

@end
