//
//  MHVAssessmentField.m
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

#import "MHVCommon.h"
#import "MHVAssessmentField.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_value = @"value";
static NSString* const c_element_group = @"group";

@implementation MHVAssessmentField

@synthesize name = m_name;
@synthesize value = m_value;
@synthesize fieldGroup = m_group;

-(id)initWithName:(NSString *)name andValue:(NSString *)value
{
    return [self initWithName:name value:value andGroup:nil];
}

-(id)initWithName:(NSString *)name value:(NSString *)value andGroup:(NSString *)group
{
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    m_value = [[MHVCodableValue alloc] initWithText:value];
    MHVCHECK_NOTNULL(m_value);
    
    if (group)
    {
        m_group = [[MHVCodableValue alloc] initWithText:group];
        MHVCHECK_NOTNULL(m_group);
    }
        
    return self;
    
LError:
    MHVALLOC_FAIL;
}

+(MHVAssessmentField *)from:(NSString *)name andValue:(NSString *)value
{
    return [[MHVAssessmentField alloc] initWithName:name andValue:value];
}


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE(m_name, MHVClientError_InvalidAssessmentField);
    MHVVALIDATE(m_value, MHVClientError_InvalidAssessmentField);
    MHVVALIDATE_OPTIONAL(m_group);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_value content:m_value];
    [writer writeElement:c_element_group content:m_group];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_value = [reader readElement:c_element_value asClass:[MHVCodableValue class]];
    m_group = [reader readElement:c_element_group asClass:[MHVCodableValue class]];    
}

@end


@implementation MHVAssessmentFieldCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVAssessmentField class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

@end
