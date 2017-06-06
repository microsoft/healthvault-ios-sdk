//
//  MHVThingTypeOrderByProperties.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVThingTypeOrderByProperties.h"
#import "MHVThingTypeProperty.h"

static NSString *const c_element_property = @"property";

@implementation MHVThingTypeOrderByProperties

- (void)deserialize:(XReader *)reader
{
    _properties = (NSArray<MHVThingTypeProperty *> *)[reader readElementArray:c_element_property
                                                                      asClass:[MHVThingTypeProperty class]];
}

@end
