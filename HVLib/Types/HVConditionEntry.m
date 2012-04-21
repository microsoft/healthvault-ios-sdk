//
//  HVConditionEntry.m
//  HVLib
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
#import "HVConditionEntry.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_onsetDate = @"onset-date";
static NSString* const c_element_resolutionDate = @"resolution-date";
static NSString* const c_element_resolution = @"resolution";
static NSString* const c_element_occurrence = @"occurrence";
static NSString* const c_element_severity = @"severity";

@implementation HVConditionEntry

@synthesize name = m_name;
@synthesize onsetDate = m_onsetDate;
@synthesize resolutionDate = m_resolutionDate;
@synthesize resolution = m_resolution;
@synthesize occurrence = m_occurrence;
@synthesize severity = m_severity;

-(id)initWithName:(NSString *)name
{
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[HVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_onsetDate release];
    [m_resolutionDate release];
    [m_resolution release];
    [m_occurrence release];
    [m_severity release];
    [super dealloc];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidCondition);
    HVVALIDATE_OPTIONAL(m_onsetDate);
    HVVALIDATE_STRINGOPTIONAL(m_resolution, HVClientError_InvalidCondition);
    HVVALIDATE_OPTIONAL(m_resolutionDate);
    HVVALIDATE_OPTIONAL(m_occurrence);
    HVVALIDATE_OPTIONAL(m_severity);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_onsetDate, c_element_onsetDate);
    HVSERIALIZE(m_resolutionDate, c_element_resolutionDate);
    HVSERIALIZE_STRING(m_resolution, c_element_resolution);
    HVSERIALIZE(m_occurrence, c_element_occurrence);
    HVSERIALIZE(m_severity, c_element_severity);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_onsetDate, c_element_onsetDate, HVApproxDate);
    HVDESERIALIZE(m_resolutionDate, c_element_resolutionDate, HVApproxDate);
    HVDESERIALIZE_STRING(m_resolution, c_element_resolution);
    HVDESERIALIZE(m_occurrence, c_element_occurrence, HVCodableValue);
    HVDESERIALIZE(m_severity, c_element_severity, HVCodableValue);    
}

@end

@implementation HVConditionEntryCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVConditionEntry class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end


