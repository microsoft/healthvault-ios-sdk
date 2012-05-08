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
    [super dealloc];
}

-(HVCodedValue *)codedValueForItem:(HVVocabItem *)vocabItem
{
    HVCHECK_NOTNULL(vocabItem);
    
    return [[[HVCodedValue alloc] initWithCode:vocabItem.code vocab:m_name vocabFamily:m_family vocabVersion:m_version] autorelease];
    
LError:
    return nil;
}

-(NSString *)toKeyString
{
    return [NSString stringWithFormat:@"%@_%@_%@", m_name, m_family, m_version];
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
    HVSERIALIZE_ATTRIBUTE(m_lang, c_element_lang);
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_name, c_element_name);
    HVSERIALIZE_STRING(m_family, c_element_family);
    HVSERIALIZE_STRING(m_version, c_element_version);
    HVSERIALIZE_STRING(m_codeValue, c_element_code);
}

-(void)deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE(m_lang, c_element_lang);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_name, c_element_name);
    HVDESERIALIZE_STRING(m_family, c_element_family);
    HVDESERIALIZE_STRING(m_version, c_element_version);
    HVDESERIALIZE_STRING(m_codeValue, c_element_code);
}

@end
