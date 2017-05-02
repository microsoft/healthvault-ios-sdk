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

-(id)initWithTitle:(HVCodableValue *)title value:(double)value andUnit:(NSString *)unit
{
    HVCHECK_NOTNULL(title);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.title = title;

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

-(id)initWithTemperature:(double)value inCelsius:(BOOL)celsius
{
    HVCodableValue* title = [HVCodableValue fromText:@"Temperature" code:@"Tmp" andVocab:@"vital-statistics"];
    return [self initWithTitle:title value:value andUnit:(celsius) ? @"celsius" : @"fahrenheit"];
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
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_title content:m_title];
    [writer writeElement:c_element_value content:m_value];
    [writer writeElement:c_element_unit content:m_unit];
    [writer writeElement:c_element_refMin content:m_referenceMin];
    [writer writeElement:c_element_refMax content:m_referenceMax];
    [writer writeElement:c_element_textValue value:m_textValue];
    [writer writeElement:c_element_flag content:m_flag];
}

-(void)deserialize:(XReader *)reader
{
    m_title = [[reader readElement:c_element_title asClass:[HVCodableValue class]] retain];
    m_value = [[reader readElement:c_element_value asClass:[HVDouble class]] retain];
    m_unit = [[reader readElement:c_element_unit asClass:[HVCodableValue class]] retain];
    m_referenceMin = [[reader readElement:c_element_refMin asClass:[HVDouble class]] retain];
    m_referenceMax = [[reader readElement:c_element_refMax asClass:[HVDouble class]] retain];
    m_textValue = [[reader readStringElement:c_element_textValue] retain];
    m_flag = [[reader readElement:c_element_flag asClass:[HVCodableValue class]] retain];   
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
