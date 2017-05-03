//
//  HVPlatformInfo.m
//  HVLib
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

#import "HVCommon.h"
#import "HVPlatformInfo.h"

static const xmlChar* x_element_url = XMLSTRINGCONST("url");
static const xmlChar* x_element_version = XMLSTRINGCONST("version");
static NSString* c_element_config = @"configuration";

@implementation HVPlatformInfo

@synthesize url = m_url;
@synthesize version = m_version;
@synthesize config = m_config;


-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_url value:m_url];
    [writer writeElementXmlName:x_element_version value:m_version];
    [writer writeElementArray:c_element_config elements:m_config];
}

-(void)deserialize:(XReader *)reader
{
    m_url = [reader readStringElementWithXmlName:x_element_url];
    m_version = [reader readStringElementWithXmlName:x_element_version];
    m_config = (HVConfigurationEntryCollection *)[reader readElementArray:c_element_config asClass:[HVConfigurationEntry class] andArrayClass:[HVConfigurationEntryCollection class]];
}

@end
