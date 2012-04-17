//
//  HVAssessmentField.m
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
#import "HVAssessmentField.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_value = @"value";
static NSString* const c_element_group = @"group";

@implementation HVAssessmentField

@synthesize name = m_name;
@synthesize value = m_value;
@synthesize fieldGroup = m_group;

-(void)dealloc
{
    [m_name release];
    [m_value release];
    [m_group release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE(m_name, HVClientError_InvalidAssessmentField);
    HVVALIDATE(m_value, HVClientError_InvalidAssessmentField);
    HVVALIDATE_OPTIONAL(m_group);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_value, c_element_value);
    HVSERIALIZE(m_group, c_element_group);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_value, c_element_value, HVCodableValue);
    HVDESERIALIZE(m_group, c_element_group, HVCodableValue);    
}

@end


@implementation HVAssessmentFieldCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVAssessmentField class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end