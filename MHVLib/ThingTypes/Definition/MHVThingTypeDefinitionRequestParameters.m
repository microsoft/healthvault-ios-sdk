//
//  MHVThingTypeDefinitionRequestParameters.m
//  MHVLib
//
//  Created by Nathan Malubay on 6/5/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVThingTypeDefinitionRequestParameters.h"

static NSString *const c_element_id = @"id";
static NSString *const c_element_section = @"section";
static NSString *const c_element_last_client_refresh = @"last-client-refresh";
static NSString *const c_element_image_type = @"image-type";

@interface MHVThingTypeDefinitionRequestParameters ()

@property (nonatomic, strong) NSArray<NSString *> *typeIds;
@property (nonatomic, assign) MHVThingTypeSections sections;
@property (nonatomic, strong) NSArray<NSString *> *imageTypes;
@property (nonatomic, strong) NSDate *lastClientRefreshDate;

@end

@implementation MHVThingTypeDefinitionRequestParameters

- (instancetype)initWithTypeIds:(NSArray<NSString *> *_Nullable)typeIds
                       sections:(MHVThingTypeSections)sections
                     imageTypes:(NSArray<NSString *> *_Nullable)imageTypes
          lastClientRefreshDate:(NSDate *_Nullable)lastClientRefreshDate
{
    self = [super init];
    
    if (self)
    {
        _typeIds = typeIds;
        _sections = sections;
        _imageTypes = imageTypes;
        _lastClientRefreshDate = lastClientRefreshDate;
    }
    
    return self;
}

- (void)serialize:(XWriter *)writer
{
    // Write each typeId as a separate element
    for (NSString *typeId in self.typeIds)
    {
        [writer writeElement:c_element_id value:typeId];
    }
    
    // Write each section
    if ((self.sections & MHVThingTypeSectionsCore) == MHVThingTypeSectionsCore)
    {
        [writer writeElement:c_element_section value:@"core"];
    }
    
    if ((self.sections & MHVThingTypeSectionsXsd) == MHVThingTypeSectionsXsd)
    {
        [writer writeElement:c_element_section value:@"xsd"];
    }
    
    if ((self.sections & MHVThingTypeSectionsColumns) == MHVThingTypeSectionsColumns)
    {
        [writer writeElement:c_element_section value:@"columns"];
    }
    
    if ((self.sections & MHVThingTypeSectionsTransforms) == MHVThingTypeSectionsTransforms)
    {
        [writer writeElement:c_element_section value:@"transforms"];
    }
    
    if ((self.sections & MHVThingTypeSectionsTransformSource) == MHVThingTypeSectionsTransformSource)
    {
        [writer writeElement:c_element_section value:@"transformsource"];
    }
    
    if ((self.sections & MHVThingTypeSectionsVersions) == MHVThingTypeSectionsVersions)
    {
        [writer writeElement:c_element_section value:@"versions"];
    }
    
    if ((self.sections & MHVThingTypeSectionsEffectiveDateXPath) == MHVThingTypeSectionsEffectiveDateXPath)
    {
        [writer writeElement:c_element_section value:@"effectivedatexpath"];
    }
    
    // Write each image type as a separate element
    for (NSString *imageType in self.imageTypes)
    {
        [writer writeElement:c_element_image_type value:imageType];
    }
    
    // Write the last clietn refresh date (if not nil)
    if (self.lastClientRefreshDate)
    {
        [writer writeElement:c_element_last_client_refresh dateValue:self.lastClientRefreshDate];
    }
}

@end
