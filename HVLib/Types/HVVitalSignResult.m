//
//  HVVitalSignResult.m
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
#import "HVVitalSignResult.h"

static NSString* const c_element_title = @"title";
static NSString* const c_element_value = @"value";
static NSString* const c_element_unit = @"unit";
static NSString* const c_element_refMin = @"reference-minimum";
static NSString* const c_element_refMax = @"reference-maximum";
static NSString* const c_element_textValue = @"text-value";
static NSString* const c_element_flag = @"flag";

@implementation HVVitalSignResult

@synthesize title = m_title;
@synthesize value = m_value;
@synthesize unit = m_unit;
@synthesize referenceMin = m_referenceMin;
@synthesize referenceMax = m_referenceMax;
@synthesize textValue = m_textValue;
@synthesize flag = m_flag;

-(id)initWithTitle:(NSString *)title andValue:(double)value
{
    return [self initWithTitle:title value:value andUnit:nil];
}

-(id)initWithTitle:(NSString *)title value:(double)value andUnit:(NSString *)unit
{
    HVCHECK_STRING(title);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_title = [[HVCodableValue alloc] initWithText:title];
    HVCHECK_NOTNULL(m_title);
    
    m_value = [[HVDouble alloc] initWith:value];
    HVCHECK_NOTNULL(m_value);
    
    if (unit)
    {
        m_unit = [[HVCodableValue alloc] initWithText:unit];
        HVCHECK_NOTNULL(m_unit);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_title release];
    [m_value release];
    [m_unit release];
    [m_referenceMin release];
    [m_referenceMax release];
    [m_textValue release];
    [m_flag release];
    
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [NSString stringWithFormat:@"%@, %@ %@", 
            (m_title) ? [m_title toString] : c_emptyString, 
            (m_value) ? [m_value toStringWithFormat:@"%.2f"] : c_emptyString, 
            (m_unit) ? [m_unit toString] : c_emptyString];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_title, HVClientError_InvalidVitalSignResult);
    HVVALIDATE_OPTIONAL(m_value);
    HVVALIDATE_OPTIONAL(m_unit);
    HVVALIDATE_OPTIONAL(m_referenceMin);
    HVVALIDATE_OPTIONAL(m_referenceMax);
    HVVALIDATE_STRINGOPTIONAL(m_textValue, HVClientError_InvalidVitalSignResult);
    HVVALIDATE_OPTIONAL(m_flag);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_title, c_element_title);
    HVSERIALIZE(m_value, c_element_value);
    HVSERIALIZE(m_unit, c_element_unit);
    HVSERIALIZE(m_referenceMin, c_element_refMin);
    HVSERIALIZE(m_referenceMax, c_element_refMax);
    HVSERIALIZE_STRING(m_textValue, c_element_textValue);
    HVSERIALIZE(m_flag, c_element_flag);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_title, c_element_title, HVCodableValue);
    HVDESERIALIZE(m_value, c_element_value, HVDouble);
    HVDESERIALIZE(m_unit, c_element_unit, HVCodableValue);
    HVDESERIALIZE(m_referenceMin, c_element_refMin, HVDouble);
    HVDESERIALIZE(m_referenceMax, c_element_refMax, HVDouble);
    HVDESERIALIZE_STRING(m_textValue, c_element_textValue);
    HVDESERIALIZE(m_flag, c_element_flag, HVCodableValue);   
}

@end

@implementation HVVitalSignResultCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVVitalSignResult class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVVitalSignResult *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end