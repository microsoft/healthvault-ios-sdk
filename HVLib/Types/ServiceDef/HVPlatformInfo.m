//
//  HVPlatformInfo.m
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

#import "HVCommon.h"
#import "HVPlatformInfo.h"

static const xmlChar* x_element_url = XMLSTRINGCONST("url");
static const xmlChar* x_element_version = XMLSTRINGCONST("version");
static NSString* c_element_config = @"configuration";

@implementation HVPlatformInfo

@synthesize url = m_url;
@synthesize version = m_version;
@synthesize config = m_config;

-(void)dealloc
{
    [m_url release];
    [m_version release];
    [m_config release];
    
    [super dealloc];
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING_X(m_url, x_element_url);
    HVSERIALIZE_STRING_X(m_version, x_element_version);
    HVSERIALIZE_ARRAY(m_config, c_element_config);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING_X(m_url, x_element_url);
    HVDESERIALIZE_STRING_X(m_version, x_element_version);
    HVDESERIALIZE_TYPEDARRAY(m_config, c_element_config, HVConfigurationEntry, HVConfigurationEntryCollection);
}

@end
