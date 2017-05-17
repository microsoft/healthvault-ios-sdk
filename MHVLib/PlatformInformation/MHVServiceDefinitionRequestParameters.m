//
//  MHVServiceDefinitionRequestParameters.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/17/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVServiceDefinitionRequestParameters.h"
#import "DateTimeUtils.h"

static const xmlChar *x_element_updated_date = XMLSTRINGCONST("updated-date");
static NSString *const c_element_response_sections = @"response-sections";
static NSString *const c_element_section = @"section";

@interface MHVServiceDefinitionRequestParameters ()

@property (nonatomic, assign) MHVServiceInfoSections infoSections;
@property (nonatomic, strong) NSArray *sectionsArray;
@property (nonatomic, strong) NSDate *lastUpdatedTime;

@end

@implementation MHVServiceDefinitionRequestParameters

- (instancetype)initWithInfoSections:(MHVServiceInfoSections)infoSections
                     lastUpdatedTime:(NSDate *)lastUpdatedTime
{
    self = [super init];
    
    if (self)
    {
        _infoSections = infoSections;
        _lastUpdatedTime = lastUpdatedTime;
    }
    
    return self;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_updated_date dateValue:self.lastUpdatedTime];
    [writer writeElementArray:c_element_response_sections thingName:c_element_section elements:self.sectionsArray];
}

- (NSArray *)sectionsArray
{
    if (!_sectionsArray)
    {
        NSMutableArray *sections = [NSMutableArray new];
        
        if ((self.infoSections & MHVServiceInfoSectionsPlatform) == MHVServiceInfoSectionsPlatform)
        {
            [sections addObject:@"platform"];
        }
        
        if ((self.infoSections & MHVServiceInfoSectionsShell) == MHVServiceInfoSectionsShell)
        {
            [sections addObject:@"shell"];
        }
        
        if ((self.infoSections & MHVServiceInfoSectionsTopology) == MHVServiceInfoSectionsTopology)
        {
            [sections addObject:@"topology"];
        }
        
        if ((self.infoSections & MHVServiceInfoSectionsXmlOverHttpMethods) == MHVServiceInfoSectionsXmlOverHttpMethods)
        {
            [sections addObject:@"xml-over-http-methods"];
        }
        
        if ((self.infoSections & MHVServiceInfoSectionsMeaningfulUse) == MHVServiceInfoSectionsMeaningfulUse)
        {
            [sections addObject:@"meaningful-use"];
        }
        
        _sectionsArray = sections;
    }
    
    return _sectionsArray;
}

@end
