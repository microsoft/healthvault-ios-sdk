//
//  MHVThingTypeDefinition.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVThingTypeDefinition.h"
#import "MHVBool.h"
#import "MHVThingTypeVersionInfo.h"

static NSString *const c_element_id = @"id";
static NSString *const c_element_name = @"name";
static NSString *const c_element_uncreatable = @"uncreatable";
static NSString *const c_element_immutable = @"immutable";
static NSString *const c_element_singleton = @"singleton";
static NSString *const c_element_xsd = @"xsd";
static NSString *const c_element_versions = @"versions";
static NSString *const c_element_effective_date_xpath = @"effective-date-xpath";
static NSString *const c_element_updated_end_date_xpath =@"updated-end-date-xpath";
static NSString *const c_element_allow_readonly = @"allow-readonly";

@implementation MHVThingTypeDefinition

- (void)deserialize:(XReader *)reader
{
    _typeId = [[NSUUID alloc] initWithUUIDString:[reader readStringElement:c_element_id]];
    _name = [reader readStringElement:c_element_name];
    MHVBool *uncreatable = [reader readElement:c_element_uncreatable asClass:[MHVBool class]];
    if (uncreatable)
    {
        _isCreatable = [[MHVBool alloc] initWith:!uncreatable.value];
    }
    _isImmutable = [reader readElement:c_element_immutable asClass:[MHVBool class]];
    _isSingletonType = [reader readElement:c_element_singleton asClass:[MHVBool class]];
    _xmlSchemaDefinition = [reader readStringElement:c_element_xsd];
    _effectiveDateXPath = [reader readStringElement:c_element_effective_date_xpath];
    _updatedEndDateXPath = [reader readStringElement:c_element_updated_end_date_xpath];
    _versions = [reader readElementArray:c_element_versions asClass:[MHVThingTypeVersionInfo class]];
    _allowReadOnly = [reader readElement:c_element_allow_readonly asClass:[MHVBool class]];
}

@end
