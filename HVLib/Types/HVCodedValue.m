//
//  HVCodedValue.m
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
#import "HVCodedValue.h"


static NSString* const c_element_value = @"value";
static NSString* const c_element_family = @"family";
static NSString* const c_element_type = @"type";
static NSString* const c_element_version = @"version";

@implementation HVCodedValue

@synthesize code = m_code;
@synthesize vocabularyName = m_vocab;
@synthesize vocabularyFamily = m_family;
@synthesize vocabularyVersion = m_version;

-(id) initWithCode:(NSString *)code andVocab:(NSString *)vocab
{
    return [self initWithCode:code vocab:vocab vocabFamily:nil vocabVersion:nil];
}

-(id)initWithCode:(NSString *)code vocab:(NSString *)vocab vocabFamily:(NSString *)family vocabVersion:(NSString *)version
{    
    HVCHECK_STRING(code);
    HVCHECK_STRING(vocab);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.code = code;
    self.vocabularyName = vocab;
    if (family)
    {
        self.vocabularyFamily = family;
    }
    if (version)
    {
        self.vocabularyVersion = version;
    }
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_code release];
    [m_vocab release];
    [m_family release];
    [m_version release];
    [super dealloc];
 }

+(HVCodedValue *)fromCode:(NSString *)code andVocab:(NSString *)vocab
{
    return [[[HVCodedValue alloc] initWithCode:code andVocab:vocab] autorelease];
}

+(HVCodedValue *)fromCode:(NSString *)code vocab:(NSString *)vocab vocabFamily:(NSString *)family vocabVersion:(NSString *)version
{
    return [[[HVCodedValue alloc] initWithCode:code vocab:vocab vocabFamily:family vocabVersion:version] autorelease];
}

-(BOOL)isEqualToCodedValue:(HVCodedValue *)value
{
    if (value == nil)
    {
        return FALSE;
    }
    
    return (
                ((m_vocab == nil && value.vocabularyName == nil) || [m_vocab isEqualToString:value.vocabularyName])
            &&  ((m_code == nil && value.code == nil) || [m_code isEqualToString:value.code])
            &&  ((m_family == nil && value.vocabularyFamily == nil) || [m_family isEqualToString:value.vocabularyFamily])
            &&  ((m_version == nil && value.vocabularyVersion == nil) || [m_version isEqualToString:value.vocabularyVersion])
            );
}

-(BOOL)isEqualToCode:(NSString *)code fromVocab:(NSString *)vocabName
{
    return ([m_code isEqualToString:code] && [m_vocab isEqualToString:vocabName]);
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[HVCodedValue class]])
    {
        return FALSE;
    }
    
    return [self isEqualToCodedValue:(HVCodedValue *) object];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN; 
    
    HVVALIDATE_STRING(m_code, HVClientError_InvalidCodedValue);
    HVVALIDATE_STRING(m_vocab, HVClientError_InvalidCodedValue);
    HVVALIDATE_STRINGOPTIONAL(m_family, HVClientError_InvalidCodedValue);
    HVVALIDATE_STRINGOPTIONAL(m_version, HVClientError_InvalidCodedValue);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL; 
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_code, c_element_value);
    HVSERIALIZE_STRING(m_family, c_element_family);
    HVSERIALIZE_STRING(m_vocab, c_element_type);
    HVSERIALIZE_STRING(m_version, c_element_version);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_code, c_element_value);
    HVDESERIALIZE_STRING(m_family, c_element_family);
    HVDESERIALIZE_STRING(m_vocab, c_element_type);
    HVDESERIALIZE_STRING(m_version, c_element_version);
}

@end

@implementation HVCodedValueCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVCodedValue class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVCodedValue *)firstCode
{
    return [self itemAtIndex:0];
}

-(HVCodedValue *)itemAtIndex:(NSUInteger)index
{
    return (HVCodedValue *) [self objectAtIndex:index];
}

-(NSUInteger)indexOfCode:(HVCodedValue *)code
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        if ([[self itemAtIndex:i] isEqualToCodedValue:code])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(BOOL)containsCode:(HVCodedValue *)code
{
    return ([self indexOfCode:code] != NSNotFound);
}

@end
