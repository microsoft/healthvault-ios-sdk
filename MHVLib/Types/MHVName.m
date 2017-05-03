//
//  MHVName.m
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
#import "MHVName.h"

static NSString* const c_element_fullName = @"full";
static NSString* const c_element_title = @"title";
static NSString* const c_element_first = @"first";
static NSString* const c_element_middle = @"middle";
static NSString* const c_element_last = @"last";
static NSString* const c_element_suffix = @"suffix";

@implementation MHVName

@synthesize fullName = m_full;
@synthesize title = m_title;
@synthesize first = m_first;
@synthesize middle = m_middle;
@synthesize last = m_last;
@synthesize suffix = m_suffix;

-(id)initWithFirst:(NSString *)first andLastName:(NSString *)last
{
    return [self initWithFirst:first middle:nil andLastName:last];
}

-(id)initWithFirst:(NSString *)first middle:(NSString *)middle andLastName:(NSString *)last
{
    HVCHECK_NOTNULL(first);
    HVCHECK_NOTNULL(last);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.first = first;
    self.middle = middle;
    self.last = last;
    
    [self buildFullName];
    HVCHECK_NOTNULL(m_full);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithFullName:(NSString *)name
{
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.fullName = name;
    
    return self;

LError:
    HVALLOC_FAIL;
}


-(BOOL)buildFullName
{
    NSMutableString* fullName = [[NSMutableString alloc] init];
    HVCHECK_NOTNULL(fullName);
    
    if (m_title)
    {
        [fullName appendOptionalString:m_title.text];
    }
    
    [fullName appendOptionalString:m_first withSeparator:@" "];
    if (![NSString isNilOrEmpty:m_middle])
    {
        NSString* middleInitial = [NSString stringWithFormat:@"%c.", toupper([m_middle characterAtIndex:0])];
        [fullName appendOptionalString:middleInitial withSeparator:@" "];
    }
    [fullName appendOptionalString:m_last withSeparator:@" "];
    if (m_suffix)
    {
        [fullName appendOptionalString:m_suffix.text withSeparator:@" "];
    }
    
    self.fullName = fullName;
    
    return TRUE;

LError:
    return FALSE;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_full) ? m_full : c_emptyString;
}

+(MHVVocabIdentifier *)vocabForTitle
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"name-prefixes"];    
}

+(MHVVocabIdentifier *)vocabForSuffix
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"name-suffixes"];        
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRING(m_full, HVClientError_InvalidName);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_fullName value:m_full];
    [writer writeElement:c_element_title content:m_title];
    [writer writeElement:c_element_first value:m_first];
    [writer writeElement:c_element_middle value:m_middle];
    [writer writeElement:c_element_last value:m_last];
    [writer writeElement:c_element_suffix content:m_suffix];
}

-(void)deserialize:(XReader *)reader
{
    m_full = [reader readStringElement:c_element_fullName];
    m_title = [reader readElement:c_element_title asClass:[MHVCodableValue class]];
    m_first = [reader readStringElement:c_element_first];
    m_middle = [reader readStringElement:c_element_middle];
    m_last = [reader readStringElement:c_element_last];
    m_suffix = [reader readElement:c_element_suffix asClass:[MHVCodableValue class]];
}

@end
