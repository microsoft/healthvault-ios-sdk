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

-(NSString *)toString
{
    if (!self.hasConditions)
    {
        return c_emptyString;
    }
    
    if (m_conditions.count == 1)
    {
        return [[m_conditions objectAtIndex:0] toString];
    }
    
    NSMutableString* output = [[[NSMutableString alloc] init] autorelease];
    for (NSUInteger i = 0, count = m_conditions.count; i < count; ++i)
    {
        if (i > 0)
        {
            [output appendString:@","];
        }
        [output appendString:[[m_conditions objectAtIndex:i] toString]];
    }

    return output;
}

-(NSString *)description
{
    return [self toString];
}

-(void)dealloc
{
    [m_relative release];
    [m_conditions release];
    [super dealloc];
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
    [writer writeElementArray:c_element_condition elements:m_conditions];
    [writer writeElement:c_element_relative content:m_relative];
}

-(void)deserialize:(XReader *)reader
{
    m_conditions = (HVConditionEntryCollection *)[[reader readElementArray:c_element_condition asClass:[HVConditionEntry class] andArrayClass:[HVConditionEntryCollection class]] retain];
    m_relative = [[reader readElement:c_element_relative asClass:[HVRelative class]] retain];
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

-(NSString *)typeName
{
    return NSLocalizedString(@"Family History", @"Family History Type Name");
}

@end
