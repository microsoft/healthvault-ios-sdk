//
// MHVVocabIdentifier.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MHVCommon.h"
#import "MHVVocabIdentifier.h"

static NSString *const c_element_name = @"name";
static NSString *const c_element_family = @"family";
static NSString *const c_element_version = @"version";
static NSString *const c_element_lang = @"xml:lang";
static NSString *const c_element_code = @"code-value";

NSString *const c_rxNormFamily = @"RxNorm";
NSString *const c_snomedFamily = @"Snomed";
NSString *const c_hvFamily = @"wc";
NSString *const c_icdFamily = @"icd";
NSString *const c_hl7Family = @"HL7";
NSString *const c_isoFamily = @"iso";
NSString *const c_usdaFamily = @"usda";

@interface MHVVocabIdentifier ()

@property (nonatomic, strong) NSString *keyString;

@end

@implementation MHVVocabIdentifier

- (instancetype)initWithFamily:(NSString *)family andName:(NSString *)name
{
    MHVCHECK_STRING(family);
    MHVCHECK_STRING(name);

    self = [super init];
    if (self)
    {
        _family = family;
        _name = name;
    }

    return self;
}

- (MHVCodedValue *)codedValueForItem:(MHVVocabItem *)vocabItem
{
    MHVCHECK_NOTNULL(vocabItem);

    return [[MHVCodedValue alloc] initWithCode:vocabItem.code vocab:self.name vocabFamily:self.family vocabVersion:self.version];
}

- (MHVCodedValue *)codedValueForCode:(NSString *)code
{
    MHVCHECK_STRING(code);

    return [[MHVCodedValue alloc] initWithCode:code vocab:self.name vocabFamily:self.family vocabVersion:self.version];
}

- (MHVCodableValue *)codableValueForText:(NSString *)text andCode:(NSString *)code
{
    MHVCodableValue *codable = [MHVCodableValue fromText:text];

    MHVCHECK_NOTNULL(codable);

    MHVCodedValue *codedValue = [self codedValueForCode:code];
    MHVCHECK_NOTNULL(codedValue);

    [codable addCode:codedValue];

    return codable;
}

- (NSString *)toKeyString
{
    if (self.keyString)
    {
        return self.keyString;
    }

    if (self.version)
    {
        self.keyString = [NSString stringWithFormat:@"%@_%@_%@", self.name, self.family, self.version];
    }
    else
    {
        self.keyString = [NSString stringWithFormat:@"%@_%@", self.name, self.family];
    }

    return self.keyString;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_STRING(self.name, MHVClientError_InvalidVocabIdentifier);

    MHVVALIDATE_SUCCESS;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_element_lang value:self.language];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElement:c_element_family value:self.family];
    [writer writeElement:c_element_version value:self.version];
    [writer writeElement:c_element_code value:self.codeValue];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.language = [reader readAttribute:c_element_lang];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.family = [reader readStringElement:c_element_family];
    self.version = [reader readStringElement:c_element_version];
    self.codeValue = [reader readStringElement:c_element_code];
}

@end

@implementation MHVVocabIdentifierCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVVocabIdentifier class];
    }

    return self;
}

@end
