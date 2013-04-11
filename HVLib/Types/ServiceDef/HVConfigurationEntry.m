//
//  HVConfigurationEntry.m
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
#import "HVConfigurationEntry.h"

static const xmlChar* x_attribute_key = XMLSTRINGCONST("key");

@implementation HVConfigurationEntry

@synthesize key = m_key;
@synthesize value = m_value;

-(void)dealloc
{
    [m_key release];
    [m_value release];
    [super dealloc];
}

-(void)deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE_X(m_key, x_attribute_key);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TEXT(m_value);
}

-(void)serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE_X(m_key, x_attribute_key);
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_TEXT(m_value);
}

@end

@implementation HVConfigurationEntryCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVConfigurationEntry class];
            
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end
