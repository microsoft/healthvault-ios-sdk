//
// MHVAddress.m
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
#import "MHVAddress.h"

static NSString *const c_element_description = @"description";
static NSString *const c_element_isPrimary = @"is-primary";
static NSString *const c_element_street = @"street";
static NSString *const c_element_city = @"city";
static NSString *const c_element_state = @"state";
static NSString *const c_element_postalCode = @"postcode";
static NSString *const c_element_country = @"country";
static NSString *const c_element_county = @"county";

@implementation MHVAddress

-(BOOL)hasStreet
{
    return ![MHVCollection isNilOrEmpty:self.street];
}

- (MHVStringCollection *)street
{
    MHVENSURE(_street, MHVStringCollection);
    return _street;
}

- (NSString *)toString
{
    NSMutableString *text = [[NSMutableString alloc] init];

    [text appendOptionalWords:[self.street toString]];

    [text appendOptionalStringOnNewLine:self.city];
    [text appendOptionalStringOnNewLine:self.county];

    [text appendOptionalStringOnNewLine:self.state];
    [text appendOptionalWords:self.postalCode];
    [text appendOptionalStringOnNewLine:self.country];

    return text;
}

- (NSString *)description
{
    return [self toString];
}

+ (MHVVocabIdentifier *)vocabForCountries
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_isoFamily andName:@"iso3166"];
}

+ (MHVVocabIdentifier *)vocabForUSStates
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"states"];
}

+ (MHVVocabIdentifier *)vocabForCanadianProvinces
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"provinces"];
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_ARRAY(self.street, MHVClientError_InvalidAddress);

    MHVVALIDATE_STRING(self.city, MHVClientError_InvalidAddress);
    MHVVALIDATE_STRING(self.postalCode, MHVClientError_InvalidAddress);
    MHVVALIDATE_STRING(self.country, MHVClientError_InvalidAddress);

    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_description value:self.type];
    [writer writeElement:c_element_isPrimary content:self.isPrimary];
    [writer writeElementArray:c_element_street elements:self.street.toArray];
    [writer writeElement:c_element_city value:self.city];
    [writer writeElement:c_element_state value:self.state];
    [writer writeElement:c_element_postalCode value:self.postalCode];
    [writer writeElement:c_element_country value:self.country];
    [writer writeElement:c_element_county value:self.county];
}

- (void)deserialize:(XReader *)reader
{
    self.type = [reader readStringElement:c_element_description];
    self.isPrimary = [reader readElement:c_element_isPrimary asClass:[MHVBool class]];
    self.street = [reader readStringElementArray:c_element_street];
    self.city = [reader readStringElement:c_element_city];
    self.state = [reader readStringElement:c_element_state];
    self.postalCode = [reader readStringElement:c_element_postalCode];
    self.country = [reader readStringElement:c_element_country];
    self.county = [reader readStringElement:c_element_county];
}

@end

@implementation MHVAddressCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVAddress class];
    }
    return self;
}

- (MHVAddress *)itemAtIndex:(NSUInteger)index
{
    return (MHVAddress *)[self objectAtIndex:index];
}

@end
