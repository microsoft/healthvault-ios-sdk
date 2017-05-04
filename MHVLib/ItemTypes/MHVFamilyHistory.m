//
//  MHVFamilyHistory.m
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
#import "MHVFamilyHistory.h"

static NSString* const c_typeid = @"4a04fcc8-19c1-4d59-a8c7-2031a03f21de";
static NSString* const c_typename = @"family-history";

static NSString* const c_element_condition = @"condition";
static NSString* const c_element_relative = @"relative";

@implementation MHVFamilyHistory

@synthesize relative = m_relative;

-(MHVConditionEntryCollection *)conditions
{
    MHVENSURE(m_conditions, MHVConditionEntryCollection);
    return m_conditions;
}

-(void)setConditions:(MHVConditionEntryCollection *)conditions
{
    m_conditions = conditions;
}

-(BOOL)hasConditions
{
    return ![NSArray isNilOrEmpty:m_conditions];
}

-(MHVConditionEntry *)firstCondition
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
    
    NSMutableString* output = [[NSMutableString alloc] init];
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


-(id)initWithRelative:(MHVRelative *)relative andCondition:(MHVConditionEntry *)condition
{
    MHVCHECK_NOTNULL(relative);
    MHVCHECK_NOTNULL(condition);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.relative = relative;

    [self.conditions addObject:condition];
    MHVCHECK_NOTNULL(m_conditions);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_OPTIONAL(m_relative);
    MHVVALIDATE_ARRAYOPTIONAL(m_conditions, MHVClientError_InvalidFamilyHistory);

    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_condition elements:m_conditions];
    [writer writeElement:c_element_relative content:m_relative];
}

-(void)deserialize:(XReader *)reader
{
    m_conditions = (MHVConditionEntryCollection *)[reader readElementArray:c_element_condition asClass:[MHVConditionEntry class] andArrayClass:[MHVConditionEntryCollection class]];
    m_relative = [reader readElement:c_element_relative asClass:[MHVRelative class]];
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
    return [[MHVItem alloc] initWithType:[MHVFamilyHistory typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Family History", @"Family History Type Name");
}

@end
