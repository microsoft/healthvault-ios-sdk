//
//  HVSystemInstances.m
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
#import "HVSystemInstances.h"

static const xmlChar* x_attribute_currentinstance = XMLSTRINGCONST("current-instance-id");
static NSString* const c_element_instance = @"instance";

@implementation HVSystemInstances

@synthesize currentInstanceID = m_currentInstanceID;
@synthesize instances = m_instances;

-(void)dealloc
{
    [m_currentInstanceID release];
    [m_instances release];
    [super dealloc];
}

-(void)deserializeAttributes:(XReader *)reader
{
    HVDESERIALIZE_ATTRIBUTE_X(m_currentInstanceID, x_attribute_currentinstance);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_instances, c_element_instance, HVInstance, HVInstanceCollection);
}

-(void)serializeAttributes:(XWriter *)writer
{
    HVSERIALIZE_ATTRIBUTE_X(m_currentInstanceID, x_attribute_currentinstance);    
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_instances, c_element_instance);
}

@end
