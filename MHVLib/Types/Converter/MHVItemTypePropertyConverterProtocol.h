//
//  MHVItemTypePropertyConverterProtocol.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MHVItemTypePropertyConverterProtocol <NSObject>

/**
 Converts a value to different units. The conversion formula is determined by the implementation of the MHVItemTypePropertyConverterProtocol and the parameters with which it was constructed.

 @param doubleValue The value to be converted.
 @return the converted value.
 */
- (double)convertDoubleValue:(double)doubleValue;

@end

NS_ASSUME_NONNULL_END
