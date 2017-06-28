//
//  MHVCacheQuery.h
//  Pods
//
//  Created by Nathan Malubay on 6/26/17.
//
//

#import <Foundation/Foundation.h>

@class MHVThingQuery;

NS_ASSUME_NONNULL_BEGIN

@interface MHVCacheQuery : NSObject

@property (nonatomic, assign, readonly) BOOL canQueryCache;
@property (nonatomic, assign, readonly) NSInteger fetchLimit;
@property (nonatomic, strong, readonly, nullable) NSPredicate *predicate;
@property (nonatomic, strong, readonly, nullable) NSError *error;

- (instancetype)initWithQuery:(MHVThingQuery *)query;

@end

NS_ASSUME_NONNULL_END
