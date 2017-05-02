//
//  HVVocabIdentifier.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVVocabIdentifier.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_family = @"family";
static NSString* const c_element_version = @"version";
static NSString* const c_element_lang = @"xml:lang";
static NSString* const c_element_code = @"code-value";

NSString* const c_rxNormFamily = @"RxNorm";
NSString* const c_snomedFamily = @"Snomed";
NSString* const c_hvFamily = @"wc";
NSString* const c_icdFamily = @"icd";
NSString* const c_hl7Family = @"HL7";
NSString* const c_isoFamily = @"iso";
NSString* const c_usdaFamily = @"usda";

@implementation HVVocabIdentifier

@synthesize name = m_name;
@synthesize family = m_family; 
@synthesize version = m_version;
@synthesize language = m_lang;
@synthesize codeValue = m_codeValue;

-(id)initWithFamily:(NSString *)family andName:(NSString *)name
{
    HVCHECK_STRING(family);
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.family = family;
    self.name = name;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_family release];
    [m_version release];
    [m_lang release];
    [m_codeValue release];
    
    [m_keyString release];
    
    [super dealloc];
}

-(HVCodedValue *)codedValueForItem:(HVVocabItem *)vocabItem
{
    HVCHECK_NOTNULL(vocabItem);
    
    return [[[HVCodedValue alloc] initWithCode:vocabItem.code vocab:m_name vocabFamily:m_family vocabVersion:m_version] autorelease];
    
LError:
    return nil;
}

-(HVCodedValue *)codedValueForCode:(NSString *)code
{
    HVCHECK_STRING(code);
    
    return [[[HVCodedValue alloc] initWithCode:code vocab:m_name vocabFamily:m_family vocabVersion:m_version] autorelease];
LError:
    return nil;
}

-(HVCodableValue *)codableValueForText:(NSString *)text andCode:(NSString *)code
{
    HVCodableValue* codable = [HVCodableValue fromText:text];
    HVCHECK_NOTNULL(codable);
    
    HVCodedValue* codedValue = [self codedValueForCode:code];
    HVCHECK_NOTNULL(codedValue);
    
    [codable addCode:codedValue];
    
    return codable;
    
LError:
    return nil;
}

-(NSString *)toKeyString
{
    if (m_keyString)
    {
        return m_keyString;
    }
    
    NSString* keyString;
    if (m_version)
    {
        keyString = [NSString stringWithFormat:@"%@_%@_%@", m_name, m_family, m_version];
    }
    else 
    {
        keyString = [NSString stringWithFormat:@"%@_%@", m_name, m_family];
    }
    
    HVRETAIN(m_keyString, keyString);
    return m_keyString;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_name, HVClientError_InvalidVocabIdentifier);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_element_lang value:m_lang];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:m_name];
    [writer writeElement:c_element_family value:m_family];
    [writer writeElement:c_element_version value:m_version];
    [writer writeElement:c_element_code value:m_codeValue];
}

-(void)deserializeAttributes:(XReader *)reader
{
    m_lang = [[reader readAttribute:c_element_lang] retain];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readStringElement:c_element_name] retain];
    m_family = [[reader readStringElement:c_element_family] retain];
    m_version = [[reader readStringElement:c_element_version] retain];
    m_codeValue = [[reader readStringElement:c_element_code] retain];
}

@end

@implementation HVVocabIdentifierCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVVocabIdentifier class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end

