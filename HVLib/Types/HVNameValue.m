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

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_name, HVClientError_InvalidNameValue);
    HVVALIDATE(m_value, HVClientError_InvalidNameValue);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;      
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_value, c_element_value);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodedValue);
    HVDESERIALIZE(m_value, c_element_value, HVMeasurement);
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

@end