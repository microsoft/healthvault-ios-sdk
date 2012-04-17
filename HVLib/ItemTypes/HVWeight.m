//
//  Weight.m
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
#import "HVWeight.h"

static NSString* const c_typeid = @"3d34d87e-7fc1-4153-800f-f56592cb0d17";
static NSString* const c_typename = @"weight";

static NSString* const c_element_when = @"when";
static NSString* const c_element_value = @"value";

@implementation HVWeight

@synthesize when = m_when;
@synthesize value = m_value;

-(double)inPounds
{
    return (m_value) ? m_value.pounds : NAN;
}

-(void)setInPounds:(double)inPounds
{
    HVENSURE(m_value, HVWeightMeasurement);
    m_value.pounds = inPounds;
}

-(void)setInKg:(double)inKg
{
    HVENSURE(m_value, HVWeightMeasurement);
    m_value.kg = inKg;
}

-(double)inKg
{
    return (m_value) ? m_value.kg : NAN;
}

-(void) dealloc
{
    [m_when release];
    [m_value release];
    [super dealloc];
}

-(id) initWithKg:(double)kg andDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_value = [[HVWeightMeasurement alloc] initWithKg:kg];
    HVCHECK_NOTNULL(m_value);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithPounds:(double)pounds andDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_value = [[HVWeightMeasurement alloc] initwithPounds:pounds];
    HVCHECK_NOTNULL(m_value);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSString *)stringInPounds
{
    return [self stringInPoundsWithFormat:@"%.2f"];
}

-(NSString *)stringInKg
{
    return [self stringInKgWithFormat:@"%.3f"];  // 3rd place precision to support Grams
}

-(NSString *)stringInPoundsWithFormat:(NSString *)format
{
    return (m_value) ? [m_value stringInPounds:format] : c_emptyString;
}

-(NSString *)stringInKgWithFormat:(NSString *)format
{
    return (m_value) ? [m_value stringInKg:format] : c_emptyString;
}

-(NSString *)toString
{
    return (m_value) ? [m_value toString] : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidWeight);
    HVVALIDATE(m_value, HVClientError_InvalidWeight);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_value, c_element_value);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_value, c_element_value, HVWeightMeasurement);
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
    return [[HVItem alloc] initWithType:[HVWeight typeID]];
}

@end
