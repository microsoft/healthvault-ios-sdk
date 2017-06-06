//
//  MHVLinearItemTypePropertyConverer.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"
#import "MHVItemTypePropertyConverterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVLinearItemTypePropertyConverer : MHVType<MHVItemTypePropertyConverterProtocol>

/**
 The value by which to multiply the original value - The 'm' in the equation x' = mx + b.
 */
@property (nonatomic, assign, readonly) double multiplier;

/**
 The offset to add in the linear conversion - The 'b' in the equation x' = mx + b.
 */
@property (nonatomic, assign, readonly) double offset;

/**
 Creates a new instance of the MHVLinearItemTypePropertyConverer class.

 @param multiplier The multiplier to use in the linear conversion.
 @param offset The offset to use in the linear conversion.
 @return A new instance of MHVLinearItemTypePropertyConverer
 */
- (instancetype)initWithMultiplier:(double)multiplier offset:(double)offset;

+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

@end

NS_ASSUME_NONNULL_END
