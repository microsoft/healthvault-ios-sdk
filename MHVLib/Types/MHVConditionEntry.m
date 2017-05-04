//
//  MHVConditionEntry.m
//  MHVLib
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
#import "MHVConditionEntry.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_onsetDate = @"onset-date";
static NSString* const c_element_resolutionDate = @"resolution-date";
static NSString* const c_element_resolution = @"resolution";
static NSString* const c_element_occurrence = @"occurrence";
static NSString* const c_element_severity = @"severity";

@implementation MHVConditionEntry

@synthesize name = m_name;
@synthesize onsetDate = m_onsetDate;
@synthesize resolutionDate = m_resolutionDate;
@synthesize resolution = m_resolution;
@synthesize occurrence = m_occurrence;
@synthesize severity = m_severity;

-(id)initWithName:(NSString *)name
{
    MHVCHECK_STRING(name);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    return self;
LError:
    MHVALLOC_FAIL;
}


-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_name, MHVClientError_InvalidCondition);
    MHVVALIDATE_OPTIONAL(m_onsetDate);
    MHVVALIDATE_STRINGOPTIONAL(m_resolution, MHVClientError_InvalidCondition);
    MHVVALIDATE_OPTIONAL(m_resolutionDate);
    MHVVALIDATE_OPTIONAL(m_occurrence);
    MHVVALIDATE_OPTIONAL(m_severity);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_onsetDate content:m_onsetDate];
    [writer writeElement:c_element_resolutionDate content:m_resolutionDate];
    [writer writeElement:c_element_resolution value:m_resolution];
    [writer writeElement:c_element_occurrence content:m_occurrence];
    [writer writeElement:c_element_severity content:m_severity];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_onsetDate = [reader readElement:c_element_onsetDate asClass:[MHVApproxDate class]];
    m_resolutionDate = [reader readElement:c_element_resolutionDate asClass:[MHVApproxDate class]];
    m_resolution = [reader readStringElement:c_element_resolution];
    m_occurrence = [reader readElement:c_element_occurrence asClass:[MHVCodableValue class]];
    m_severity = [reader readElement:c_element_severity asClass:[MHVCodableValue class]];    
}

@end

@implementation MHVConditionEntryCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVConditionEntry class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

@end


