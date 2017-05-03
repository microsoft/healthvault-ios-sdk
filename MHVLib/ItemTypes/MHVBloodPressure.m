//
//  MHVBloodPressure.m
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
#import "MHVBloodPressure.h"

static NSString* const c_typeID = @"ca3c57f4-f4c1-4e15-be67-0a3caf5414ed";
static NSString* const c_typeName = @"blood-pressure";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_systolic = XMLSTRINGCONST("systolic");
static const xmlChar* x_element_diastolic = XMLSTRINGCONST("diastolic");
static const xmlChar* x_element_pulse = XMLSTRINGCONST("pulse");
static const xmlChar* x_element_heartbeat = XMLSTRINGCONST("irregular-heartbeat");


@implementation MHVBloodPressure

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
    HVENSURE(m_systolic, MHVNonNegativeInt);
    m_systolic.value = systolicValue;
}

-(int) diastolicValue
{
    return (m_diastolic) ? m_diastolic.value : -1;
}

-(void) setDiastolicValue:(int)diastolicValue
{
    HVENSURE(m_diastolic, MHVNonNegativeInt);
    m_diastolic.value = diastolicValue;
}

-(int) pulseValue
{
    return (m_pulse) ? m_pulse.value : -1;
}

-(void) setPulseValue:(int)pulseValue
{
    HVENSURE(m_pulse, MHVNonNegativeInt);
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
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithSystolic:(int)sVal diastolic:(int)dVal pulse:(int)pVal
{
    self = [super init];
    HVCHECK_SELF;
    
    m_systolic = [[MHVNonNegativeInt alloc] initWith:sVal];
    HVCHECK_NOTNULL(m_systolic);
    
    m_diastolic = [[MHVNonNegativeInt alloc] initWith:dVal];
    HVCHECK_NOTNULL(m_diastolic);
    
    if (pVal >= 0)
    {
        m_pulse = [[MHVNonNegativeInt alloc] initWith:pVal];
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

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}


-(NSString *) toString
{
    return [self toStringWithFormat:@"%d/%d"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.systolicValue, self.diastolicValue];
}

-(MHVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidBloodPressure);
    HVVALIDATE(m_systolic, HVClientError_InvalidBloodPressure);
    HVVALIDATE(m_diastolic, HVClientError_InvalidBloodPressure);
    
    HVVALIDATE_OPTIONAL(m_pulse);
    HVVALIDATE_OPTIONAL(m_heartbeat);
    
    HVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_systolic content:m_systolic];
    [writer writeElementXmlName:x_element_diastolic content:m_diastolic];
    
    [writer writeElementXmlName:x_element_pulse content:m_pulse];
    [writer writeElementXmlName:x_element_heartbeat content:m_heartbeat];
}

-(void) deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDateTime class]];
    
    m_systolic = [reader readElementWithXmlName:x_element_systolic asClass:[MHVNonNegativeInt class]];
    m_diastolic = [reader readElementWithXmlName:x_element_diastolic asClass:[MHVNonNegativeInt class]];
    
    m_pulse = [reader readElementWithXmlName:x_element_pulse asClass:[MHVNonNegativeInt class]];
    m_heartbeat = [reader readElementWithXmlName:x_element_heartbeat asClass:[MHVBool class]];
}

+(NSString *) typeID
{
    return c_typeID;
}

+(NSString *) XRootElement
{
    return c_typeName;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVBloodPressure typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Blood Pressure", @"Blood Pressure Type Name");
}

@end
