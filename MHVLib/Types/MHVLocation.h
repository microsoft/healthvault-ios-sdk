//
//  MHVLocation.h
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVLocation : MHVType


/**
 An ISO 3166-1 two letter country code (defaults to US)
 */
@property (nonatomic, strong) NSString *country;

/**
 An ISO 3166-2 state/province code without the country prefix.
 */
@property (nonatomic, strong, nullable) NSString *stateProvince;

/**
 Initializes a new instance of MHVLocation

 @param country An ISO 3166-1 two letter country code
 @param stateProvince An ISO 3166-2 state/province code without the country prefix.
 @return A new MHVLocation populated with the specified country and state or province
 */
- (instancetype)initWithCountry:(NSString *)country stateProvince:(NSString *_Nullable)stateProvince;

@end

NS_ASSUME_NONNULL_END
