//
//  HVSystemInstances.m
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
//

#import "HVCommon.h"
#import "HVSystemInstances.h"

static const xmlChar* x_attribute_currentinstance = XMLSTRINGCONST("current-instance-id");
static NSString* const c_element_instance = @"instance";

@implementation HVSystemInstances

@synthesize currentInstanceID = m_currentInstanceID;
@synthesize instances = m_instances;


-(void)deserializeAttributes:(XReader *)reader
{
    m_currentInstanceID = [reader readAttributeWithXmlName:x_attribute_currentinstance];
}

-(void)deserialize:(XReader *)reader
{
    m_instances = (HVInstanceCollection *)[reader readElementArray:c_element_instance asClass:[HVInstance class] andArrayClass:[HVInstanceCollection class]];
}

-(void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttributeXmlName:x_attribute_currentinstance value:m_currentInstanceID];    
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_instance elements:m_instances];
}

@end
