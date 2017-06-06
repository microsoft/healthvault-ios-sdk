//
//  MHVThingTypeProperty.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVThingTypeProperty.h"
#import "MHVLinearItemTypePropertyConverer.h"

static const xmlChar *x_element_name = XMLSTRINGCONST("name");
static const xmlChar *x_element_type = XMLSTRINGCONST("type");
static const xmlChar *x_element_xpath = XMLSTRINGCONST("xpath");
static NSString *const c_element_converter = @"converter";

@implementation MHVThingTypeProperty

- (void)deserialize:(XReader *)reader
{
    _name = [reader readStringElementWithXmlName:x_element_name];
    _type = [reader readStringElementWithXmlName:x_element_type];
    _xpath = [reader readStringElementWithXmlName:x_element_xpath];
    _converter = [reader readElement:c_element_converter asClass:[MHVLinearItemTypePropertyConverer class]];
}

@end
