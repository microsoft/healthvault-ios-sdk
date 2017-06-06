//
//  MHVLocation.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVLocation.h"
#import "MHVValidator.h"
#import "MHVStringExtensions.h"

static NSString *const c_element_country = @"country";
static NSString *const c_element_state_province = @"state-province";

@implementation MHVLocation

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _country = @"US";
    }
    
    return self;
}

- (instancetype)initWithCountry:(NSString *)country stateProvince:(NSString *)stateProvince
{
    // country is required, state province is optional.
    MHVASSERT_TRUE(![NSString isNilOrEmpty:country]);
    
    self = [super init];
    
    if (self)
    {
        _country = country;
        _stateProvince = stateProvince;
    }
    
    return self;
}

- (void)setCountry:(NSString *)country
{
    if ([NSString isNilOrEmpty:country])
    {
        MHVASSERT_MESSAGE(@"country cannot be empty or set to nil.");
        
        return;
    }
    
    _country = country;
}

- (void)serialize:(XWriter *)writer
{
    if (![NSString isNilOrEmpty:self.country])
    {
        [writer writeElement:c_element_country value:self.country];
        
        // Only write the state if the country is not nil.
        if (![NSString isNilOrEmpty:self.stateProvince])
        {
            [writer writeElement:c_element_state_province value:self.stateProvince];
        }
    }
}

- (void)deserialize:(XReader *)reader
{
    self.country = [reader readStringElement:c_element_country];
    self.stateProvince = [reader readStringElement:c_element_state_province];
}

@end
