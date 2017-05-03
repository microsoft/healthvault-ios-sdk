//
//  MHVLabTestResultsDetails.m
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
//
#import "MHVCommon.h"
#import "MHVLabTestResultsDetails.h"

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_substance = XMLSTRINGCONST("substance");
static const xmlChar* x_element_method = XMLSTRINGCONST("collection-method");
static const xmlChar* x_element_clinicalCode = XMLSTRINGCONST("clinical-code");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");
static const xmlChar* x_element_status = XMLSTRINGCONST("status");
static const xmlChar* x_element_note = XMLSTRINGCONST("note");

@implementation MHVLabTestResultsDetails

@synthesize when = m_when;
@synthesize name = m_name;
@synthesize substance = m_substance;
@synthesize collectionMethod = m_collectionMethod;
@synthesize clinicalCode = m_clinicalCode;
@synthesize value = m_value;
@synthesize status = m_status;
@synthesize note = m_note;


-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_OPTIONAL(m_substance);
    HVVALIDATE_OPTIONAL(m_collectionMethod);
    HVVALIDATE_OPTIONAL(m_clinicalCode);
    HVVALIDATE_OPTIONAL(m_value);
    HVVALIDATE_OPTIONAL(m_status);
    
    HVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_name value:m_name];
    [writer writeElementXmlName:x_element_substance content:m_substance];
    [writer writeElementXmlName:x_element_method content:m_collectionMethod];
    [writer writeElementXmlName:x_element_clinicalCode content:m_clinicalCode];
    [writer writeElementXmlName:x_element_value content:m_value];
    [writer writeElementXmlName:x_element_status content:m_status];
    [writer writeElementXmlName:x_element_note value:m_note];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    m_name = [reader readStringElementWithXmlName:x_element_name];
    m_substance = [reader readElementWithXmlName:x_element_substance asClass:[MHVCodableValue class]];
    m_collectionMethod = [reader readElementWithXmlName:x_element_method asClass:[MHVCodableValue class]];
    m_clinicalCode = [reader readElementWithXmlName:x_element_clinicalCode asClass:[MHVCodableValue class]];
    m_value = [reader readElementWithXmlName:x_element_value asClass:[MHVLabTestResultValue class]];
    m_status = [reader readElementWithXmlName:x_element_status asClass:[MHVCodableValue class]];
    m_note = [reader readStringElementWithXmlName:x_element_note];
}

@end

@implementation MHVLabTestResultsDetailsCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVLabTestResultsDetails class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(MHVLabTestResultsDetails *)item
{
    [super addObject:item];
}

-(MHVLabTestResultsDetails *)itemAtIndex:(NSUInteger)index
{
    return [super objectAtIndex:index];
}

@end
