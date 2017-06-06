//
//  MHVLinearItemTypePropertyConverer.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVLinearItemTypePropertyConverer.h"

static const xmlChar *x_element_offset = XMLSTRINGCONST("offset");
static const xmlChar *x_element_multiplier = XMLSTRINGCONST("multiplier");

@implementation MHVLinearItemTypePropertyConverer

- (instancetype)initWithMultiplier:(double)multiplier offset:(double)offset
{
    self = [super init];
    
    if (self)
    {
        _multiplier = multiplier;
        _offset = offset;
    }
    
    return self;
}

- (double)convertDoubleValue:(double)doubleValue
{
    return (doubleValue * self.multiplier) + self.offset;
}

- (void)deserialize:(XReader *)reader
{
    _offset = [reader readDoubleElementXmlName:x_element_offset];
    _multiplier = [reader readDoubleElementXmlName:x_element_multiplier];
}

@end
