//
//  HVVocabItem.m
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
#import "HVVocabItem.h"

static NSString* const c_element_code = @"code-value";
static NSString* const c_element_displaytext = @"display-text";
static NSString* const c_element_abbrv = @"abbreviation-text";
static NSString* const c_element_data = @"info-xml";

@implementation HVVocabItem

@synthesize code = m_code;
@synthesize displayText = m_displayText;
@synthesize abbreviation = m_abbrv;
@synthesize dataXml = m_data;

-(void)dealloc
{
    [m_code release];
    [m_displayText release];
    [m_abbrv release];
    [m_data release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_code, HVClientError_InvalidVocabIdentifier);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;    
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_code, c_element_code);
    HVSERIALIZE_STRING(m_displayText, c_element_displaytext);
    HVSERIALIZE_STRING(m_abbrv, c_element_abbrv);
    HVSERIALIZE_RAW(m_data);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_code, c_element_code);
    HVDESERIALIZE_STRING(m_displayText, c_element_displaytext);
    HVDESERIALIZE_STRING(m_abbrv, c_element_abbrv);
    HVDESERIALIZE_RAW(m_data, c_element_data);    
}

@end

@implementation HVVocabItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVVocabItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


@end
