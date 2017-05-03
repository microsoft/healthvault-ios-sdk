//
//  MHVCondition.m
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
#import "MHVCondition.h"
#import "MHVClient.h"
#import "MHVLocalVocabStore.h"

static NSString* const c_typeid = @"7ea7a1f9-880b-4bd4-b593-f5660f20eda8";
static NSString* const c_typename = @"condition";

static NSString* const c_element_name = @"name";
static NSString* const c_element_onset = @"onset-date";
static NSString* const c_element_status = @"status";
static NSString* const c_element_stop = @"stop-date";
static NSString* const c_element_reason = @"stop-reason";

@implementation MHVCondition

@synthesize name = m_name;
@synthesize onsetDate = m_onsetDate;
@synthesize status = m_status;
@synthesize stopDate = m_stopDate;
@synthesize stopReason = m_stopReason;

-(id)initWithName:(NSString *)name
{
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}


+(MHVVocabIdentifier *)vocabForStatus
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"condition-occurrence"];    
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidCondition);
    HVVALIDATE_OPTIONAL(m_onsetDate);
    HVVALIDATE_OPTIONAL(m_status);
    HVVALIDATE_OPTIONAL(m_stopDate);
    HVVALIDATE_STRINGOPTIONAL(m_stopReason, HVClientError_InvalidCondition);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_onset content:m_onsetDate];
    [writer writeElement:c_element_status content:m_status];
    [writer writeElement:c_element_stop content:m_stopDate];
    [writer writeElement:c_element_reason value:m_stopReason];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_onsetDate = [reader readElement:c_element_onset asClass:[MHVApproxDateTime class]];
    m_status = [reader readElement:c_element_status asClass:[MHVCodableValue class]];
    m_stopDate = [reader readElement:c_element_stop asClass:[MHVApproxDateTime class]];
    m_stopReason = [reader readStringElement:c_element_reason];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVCondition typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Condition", @"Condition Type Name");
}

@end
