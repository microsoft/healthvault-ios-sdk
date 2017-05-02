//
//  HVNameValue.m
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
#import "HVNameValue.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_value = @"value";

@implementation HVNameValue

@synthesize name = m_name;
@synthesize value = m_value;

-(double)measurementValue
{
    return (m_value) ? m_value.value : NAN;
}

-(void)setMeasurementValue:(double)measurementValue
{
    HVENSURE(m_value, HVMeasurement);
    m_value.value = measurementValue;
}

-(id)initWithName:(HVCodedValue *)name andValue:(HVMeasurement *)value
{
    HVCHECK_NOTNULL(name);
    HVCHECK_NOTNULL(value);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.name = name;
    self.value = value;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_value release];
    
    [super dealloc];
}

+(HVNameValue *)fromName:(HVCodedValue *)name andValue:(HVMeasurement *)value
{
    return [[[HVNameValue alloc] initWithName:name andValue:value] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_name, HVClientError_InvalidNameValue);
    HVVALIDATE(m_value, HVClientError_InvalidNameValue);
    
    HVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_value content:m_value];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readElement:c_element_name asClass:[HVCodedValue class]] retain];
    m_value = [[reader readElement:c_element_value asClass:[HVMeasurement class]] retain];
}

@end

@implementation HVNameValueCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVNameValue class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVNameValue *)itemAtIndex:(NSUInteger)index
{
    return (HVNameValue *) [self objectAtIndex:index];
}

-(NSUInteger)indexOfItemWithName:(HVCodedValue *)code
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        if ([[self itemAtIndex:i].name isEqualToCodedValue:code])
        {
            return i;
        }
     }     
    
    return NSNotFound;
}

-(NSUInteger)indexOfItemWithNameCode:(NSString *)nameCode
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        if ([[self itemAtIndex:i].name.code isEqualToString:nameCode])
        {
            return i;
        }
    }     
    
    return NSNotFound;   
}

-(HVNameValue *)getItemWithNameCode:(NSString *)nameCode
{
    NSUInteger index = [self indexOfItemWithNameCode:nameCode];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self itemAtIndex:index];
}

-(void)addOrUpdate:(HVNameValue *)value
{
    NSUInteger indexOf = [self indexOfItemWithName:value.name];
    if (indexOf != NSNotFound)
    {
        [self replaceObjectAtIndex:indexOf withObject:value];
    }
    else
    {
        [super addObject:value];
    }
}

@end
