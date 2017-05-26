//
//  MHVVocabularyKey.m
//  MHVLib
//
//  Created by Andrew Butler on 5/24/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVVocabularyKey.h"

static const xmlChar *x_element_code = XMLSTRINGCONST("code-value");
static const xmlChar *x_element_name = XMLSTRINGCONST("name");
static const xmlChar *x_element_family = XMLSTRINGCONST("family");
static const xmlChar *x_element_version = XMLSTRINGCONST("version");
static const xmlChar *x_element_description = XMLSTRINGCONST("description");

@implementation MHVVocabularyKey

-(NSString *)toString
{
    return self.name;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_code value:self.code];
    [writer writeElementXmlName:x_element_name value:self.name];
    [writer writeElementXmlName:x_element_family value:self.family];
    [writer writeElementXmlName:x_element_version value:self.version];
    
    // NOTE: We do not serialize the description field. It is optional
    // and only used for requests, not respones
}

- (void) deserialize:(XReader *)reader
{
    self.code = [reader readStringElementWithXmlName:x_element_code];
    self.name = [reader readStringElementWithXmlName:x_element_name];
    self.family = [reader readStringElementWithXmlName:x_element_family];
    self.version = [reader readStringElementWithXmlName:x_element_version];
    self.descriptionText = [reader readStringElementWithXmlName:x_element_description];
}

- (void)serializeAttributes:(XWriter *)writer
{
}

- (void)deserializeAttributes:(XReader *)reader
{
}

@end

@implementation MHVVocabularyKeyCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVVocabularyKey class];
    }
    
    return self;
}

- (void)serializeAttributes:(XWriter *)writer
{
}

- (void)deserializeAttributes:(XReader *)reader
{
}

- (void)serialize:(XWriter *)writer
{
    NSLog(@"");
}

- (void) deserialize:(XReader *)reader
{
    NSLog(@"");
}
@end
