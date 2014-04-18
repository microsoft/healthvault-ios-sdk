//
//  HVLabTestResultsDetails.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//
#import "HVCommon.h"
#import "HVLabTestResultsDetails.h"

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_substance = XMLSTRINGCONST("substance");
static const xmlChar* x_element_method = XMLSTRINGCONST("collection-method");
static const xmlChar* x_element_clinicalCode = XMLSTRINGCONST("clinical-code");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");
static const xmlChar* x_element_status = XMLSTRINGCONST("status");
static const xmlChar* x_element_note = XMLSTRINGCONST("note");

@implementation HVLabTestResultsDetails

@synthesize when = m_when;
@synthesize name = m_name;
@synthesize substance = m_substance;
@synthesize collectionMethod = m_collectionMethod;
@synthesize clinicalCode = m_clinicalCode;
@synthesize value = m_value;
@synthesize status = m_status;
@synthesize note = m_note;

-(void)dealloc
{
    [m_when release];
    [m_name release];
    [m_substance release];
    [m_collectionMethod release];
    [m_clinicalCode release];
    [m_value release];
    [m_status release];
    [m_note release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_OPTIONAL(m_substance);
    HVVALIDATE_OPTIONAL(m_collectionMethod);
    HVVALIDATE_OPTIONAL(m_clinicalCode);
    HVVALIDATE_OPTIONAL(m_value);
    HVVALIDATE_OPTIONAL(m_status);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_when, x_element_when);
    HVSERIALIZE_STRING_X(m_name, x_element_name);
    HVSERIALIZE_X(m_substance, x_element_substance);
    HVSERIALIZE_X(m_collectionMethod, x_element_method);
    HVSERIALIZE_X(m_clinicalCode, x_element_clinicalCode);
    HVSERIALIZE_X(m_value, x_element_value);
    HVSERIALIZE_X(m_status, x_element_status);
    HVSERIALIZE_STRING_X(m_note, x_element_note);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_when, x_element_when, HVApproxDateTime);
    HVDESERIALIZE_STRING_X(m_name, x_element_name);
    HVDESERIALIZE_X(m_substance, x_element_substance, HVCodableValue);
    HVDESERIALIZE_X(m_collectionMethod, x_element_method, HVCodableValue);
    HVDESERIALIZE_X(m_clinicalCode, x_element_clinicalCode, HVCodableValue);
    HVDESERIALIZE_X(m_value, x_element_value, HVLabTestResultValue);
    HVDESERIALIZE_X(m_status, x_element_status, HVCodableValue);
    HVDESERIALIZE_STRING_X(m_note, x_element_note);
}

@end

@implementation HVLabTestResultsDetailsCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVLabTestResultsDetails class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(HVLabTestResultsDetails *)item
{
    [super addObject:item];
}

-(HVLabTestResultsDetails *)itemAtIndex:(NSUInteger)index
{
    return [super objectAtIndex:index];
}

@end
