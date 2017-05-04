//
//  MHVCodableValue.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVCodableValue.h"

static const xmlChar* x_element_text = XMLSTRINGCONST("text");
static NSString* const c_element_code = @"code";
static const xmlChar* x_element_code = XMLSTRINGCONST("code");

@implementation MHVCodableValue

@synthesize text = m_text;

-(BOOL) hasCodes
{
    return ![NSArray isNilOrEmpty:m_codes];
}

-(NSMutableArray *) codes
{
    MHVENSURE(m_codes, MHVCodedValueCollection);
    return m_codes;
}

-(void)setCodes:(MHVCodedValueCollection *)codes
{
    m_codes = codes;
}

-(MHVCodedValue *)firstCode
{
    return (self.hasCodes) ? [m_codes itemAtIndex:0] : nil;
}

-(id) initWithText:(NSString *)textValue
{
    return [self initWithText:textValue andCode:nil];
}

-(id) initWithText:(NSString *)textValue andCode:(MHVCodedValue *)code
{
    MHVCHECK_STRING(textValue);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.text = textValue;
    if (code)
    {
        NSMutableArray *codes = self.codes;
        MHVCHECK_NOTNULL(codes);
        [codes addObject:code];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;    
}

-(id) initWithText:(NSString *)textValue code:(NSString *)code andVocab:(NSString *)vocab
{
    MHVCodedValue* codedValue = [[MHVCodedValue alloc] initWithCode:code andVocab:vocab];
    MHVCHECK_NOTNULL(codedValue);
    
    self = [self initWithText:textValue andCode:codedValue];
    
    return self;

LError:
    MHVALLOC_FAIL; 
}

+(MHVCodableValue *)fromText:(NSString *)textValue
{
    return [[MHVCodableValue alloc] initWithText:textValue];
}

+(MHVCodableValue *)fromText:(NSString *)textValue andCode:(MHVCodedValue *)code
{
    return [[MHVCodableValue alloc] initWithText:textValue andCode:code];
}

+(MHVCodableValue *)fromText:(NSString *)textValue code:(NSString *)code andVocab:(NSString *)vocab
{
    return [[MHVCodableValue alloc] initWithText:textValue code:code andVocab:vocab];
}


-(BOOL)matchesDisplayText:(NSString *)text
{
    return ([m_text caseInsensitiveCompare:[text trim]] == NSOrderedSame);
}

-(BOOL)containsCode:(MHVCodedValue *)code
{
    if (!m_codes)
    {
        return FALSE;
    }
    
    return [m_codes containsCode:code];
}

-(BOOL)addCode:(MHVCodedValue *)code
{
    MHVCodedValueCollection* codes = self.codes;
    MHVCHECK_NOTNULL(codes);
    
    [codes addObject:code];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)clearCodes
{
    if (m_codes)
    {
        [m_codes removeAllObjects];
    }
}

-(MHVCodableValue *)clone
{
    MHVCodableValue* cloned = [[MHVCodableValue alloc] initWithText:m_text];
    MHVCHECK_NOTNULL(cloned);
    
    if (self.hasCodes)
    {
        MHVCodedValueCollection* codes = self.codes;
        for (NSUInteger i = 0, count = codes.count; i < count; ++i)
        {
            MHVCodedValue* clonedCode = [[codes itemAtIndex:i] clone];
            MHVCHECK_NOTNULL(clonedCode);
            
            [cloned addCode:clonedCode];
        }
    }
    
    return cloned;

LError:
    return nil;
}

-(NSString *) description
{
    return [self toString];
}

-(NSString *)toString
{
    return m_text;
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, m_text];
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_STRING(self.text, MHVClientError_InvalidCodableValue);
    if (self.hasCodes)
    {
        for (MHVCodedValue* code in self.codes)
        {
            MHVVALIDATE(code, MHVClientError_InvalidCodableValue);
        }
    }
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_text value:m_text];
    [writer writeElementArray:c_element_code elements:m_codes];
}

-(void) deserialize:(XReader *)reader
{
    m_text = [reader readStringElementWithXmlName:x_element_text];
    m_codes = (MHVCodedValueCollection *)[reader readElementArrayWithXmlName:x_element_code asClass:[MHVCodedValue class] andArrayClass:[MHVCodedValueCollection class]];
}

@end

@implementation MHVCodableValueCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVCodableValue class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(void) addItem:(MHVCodableValue *)value
{
    [super addObject:value];
}

-(MHVCodableValue *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
