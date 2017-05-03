//
//  HVServiceDefinition.m
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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
//

#import "HVCommon.h"
#import "HVServiceDefinition.h"

static const xmlChar* x_element_platform = XMLSTRINGCONST("platform");
static const xmlChar* x_element_shell = XMLSTRINGCONST("shell");
static const xmlChar* x_element_instance = XMLSTRINGCONST("instances");

@implementation HVServiceDefinition

@synthesize platform = m_platform;
@synthesize shell = m_shell;
@synthesize systemInstances = m_instances;

-(void)dealloc
{
    [m_platform release];
    [m_shell release];
    [m_instances release];
    
    [super dealloc];
}

-(void)deserialize:(XReader *)reader
{
    m_platform = [[reader readElementWithXmlName:x_element_platform asClass:[HVPlatformInfo class]] retain];
    m_shell = [[reader readElementWithXmlName:x_element_shell asClass:[HVShellInfo class]] retain];
    [reader skipElement:@"xml-method"];
    [reader skipElement:@"common-schema"];
    m_instances = [[reader readElementWithXmlName:x_element_instance asClass:[HVSystemInstances class]] retain];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_platform content:m_platform];
    [writer writeElementXmlName:x_element_shell content:m_shell];
    [writer writeElementXmlName:x_element_instance content:m_instances];
}

@end

static NSString* const c_element_updated = @"updated-date";
static NSString* const c_element_sections = @"response-sections";
static NSString* const c_element_section = @"section";

@implementation HVServiceDefinitionParams

@synthesize updatedSince = m_updatedSince;

-(HVStringCollection *)sections
{
    HVENSURE(m_sections, HVStringCollection);
    return m_sections;
}

-(void)setSections:(HVStringCollection *)sections
{
    m_sections = [sections retain];
}

-(void)dealloc
{
    [m_updatedSince release];
    [m_sections release];
    [super dealloc];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_updated dateValue:m_updatedSince];
    [writer writeElementArray:c_element_sections itemName:c_element_section elements:m_sections];
}

@end
