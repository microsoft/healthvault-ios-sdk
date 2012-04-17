//
//  HVBloodPressure.m
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
#import "HVBloodPressure.h"

static NSString* const c_typeID = @"ca3c57f4-f4c1-4e15-be67-0a3caf5414ed";
static NSString* const c_typeName = @"blood-pressure";

static NSString* const c_element_when = @"when";
static NSString* const c_element_systolic = @"systolic";
static NSString* const c_element_diastolic = @"diastolic";
static NSString* const c_element_pulse = @"pulse";
static NSString* const c_element_heartbeat = @"irregular-heartbeat";


@implementation HVBloodPressure

@synthesize when = m_when;
@synthesize irregularHeartbeat = m_heartbeat;
@synthesize systolic = m_systolic;
@synthesize diastolic = m_diastolic;
@synthesize pulse = m_pulse;

-(int) systolicValue
{
    return (m_systolic) ? m_systolic.value : -1;
}

-(void) setSystolicValue:(int)systolicValue
{
    HVENSURE(m_systolic, HVNonNegativeInt);
    m_systolic.value = systolicValue;
}

-(int) diastolicValue
{
    return (m_diastolic) ? m_diastolic.value : -1;
}

-(void) setDiastolicValue:(int)diastolicValue
{
    HVENSURE(m_diastolic, HVNonNegativeInt);
    m_diastolic.value = diastolicValue;
}

-(int) pulseValue
{
    return (m_pulse) ? m_pulse.value : -1;
}

-(void) setPulseValue:(int)pulseValue
{
    HVENSURE(m_pulse, HVNonNegativeInt);
    m_pulse.value = pulseValue;
}

-(id) initWithSystolic:(int)sVal diastolic:(int)dVal
{
    return [self initWithSystolic:sVal diastolic:dVal pulse:-1];
}

-(id) initWithSystolic:(int)sVal diastolic:(int)dVal andDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [self initWithSystolic:sVal diastolic:dVal];
    HVCHECK_SELF;
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithSystolic:(int)sVal diastolic:(int)dVal pulse:(int)pVal
{
    self = [super init];
    HVCHECK_SELF;
    
    m_systolic = [[HVNonNegativeInt alloc] initWith:sVal];
    HVCHECK_NOTNULL(m_systolic);
    
    m_diastolic = [[HVNonNegativeInt alloc] initWith:dVal];
    HVCHECK_NOTNULL(m_diastolic);
    
    if (pVal >= 0)
    {
        m_pulse = [[HVNonNegativeInt alloc] initWith:pVal];
        HVCHECK_NOTNULL(m_pulse);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(void) dealloc
{
    [m_when release];
    [m_systolic release];
    [m_diastolic release];
    [m_pulse release];
    [m_heartbeat release];
    
    [super dealloc];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"%d/%d"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, self.systolicValue, self.diastolicValue];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidBloodPressure);
    HVVALIDATE(m_systolic, HVClientError_InvalidBloodPressure);
    HVVALIDATE(m_diastolic, HVClientError_InvalidBloodPressure);
    
    HVVALIDATE_OPTIONAL(m_pulse);
    HVVALIDATE_OPTIONAL(m_heartbeat);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    
    HVSERIALIZE(m_systolic, c_element_systolic);
    HVSERIALIZE(m_diastolic, c_element_diastolic);
    
    HVSERIALIZE(m_pulse, c_element_pulse);
    HVSERIALIZE(m_heartbeat, c_element_heartbeat);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    
    HVDESERIALIZE(m_systolic, c_element_systolic, HVNonNegativeInt);
    HVDESERIALIZE(m_diastolic, c_element_diastolic, HVNonNegativeInt);
    
    HVDESERIALIZE(m_pulse, c_element_pulse, HVNonNegativeInt);
    HVDESERIALIZE(m_heartbeat, c_element_heartbeat, HVBool);
}

+(NSString *) typeID
{
    return c_typeID;
}

+(NSString *) XRootElement
{
    return c_typeName;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVBloodPressure typeID]];
}

@end
