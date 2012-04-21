//
//  HVFamilyHistory.m
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
#import "HVFamilyHistory.h"

static NSString* const c_typeid = @"4a04fcc8-19c1-4d59-a8c7-2031a03f21de";
static NSString* const c_typename = @"family-history";

static NSString* const c_element_condition = @"condition";
static NSString* const c_element_relative = @"relative";

@implementation HVFamilyHistory

@synthesize relative = m_relative;

-(HVConditionEntryCollection *)conditions
{
    HVENSURE(m_conditions, HVConditionEntryCollection);
    return m_conditions;
}

-(void)setConditions:(HVConditionEntryCollection *)conditions
{
    HVRETAIN(m_conditions, conditions);
}

-(BOOL)hasConditions
{
    return ![NSArray isNilOrEmpty:m_conditions];
}

-(HVConditionEntry *)firstCondition
{
    return (self.hasConditions) ? [m_conditions objectAtIndex:0] : nil;
}

-(id)initWithRelative:(HVRelative *)relative andCondition:(HVConditionEntry *)condition
{
    HVCHECK_NOTNULL(relative);
    HVCHECK_NOTNULL(condition);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.relative = relative;

    [self.conditions addObject:condition];
    HVCHECK_NOTNULL(m_conditions);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_relative release];
    [m_conditions release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_OPTIONAL(m_relative);
    HVVALIDATE_ARRAYOPTIONAL(m_conditions, HVClientError_InvalidFamilyHistory);

    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_conditions, c_element_condition);
    HVSERIALIZE(m_relative, c_element_relative);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_conditions, c_element_condition, HVConditionEntry, HVConditionEntryCollection);
    HVDESERIALIZE(m_relative, c_element_relative, HVRelative);
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVFamilyHistory typeID]];
}

@end
