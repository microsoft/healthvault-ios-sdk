//
//  HVBloodGlucose.m
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
#import "HVBloodGlucose.h"

static NSString* const c_typeid = @"879e7c04-4e8a-4707-9ad3-b054df467ce4";
static NSString* const c_typename = @"blood-glucose";

static NSString* const c_element_when = @"when";
static NSString* const c_element_value = @"value";
static NSString* const c_element_type = @"glucose-measurement-type";
static NSString* const c_element_operatingTemp = @"outside-operating-temp";
static NSString* const c_element_controlTest = @"is-control-test";
static NSString* const c_element_normalcy = @"normalcy";
static NSString* const c_element_context = @"measurement-context";

static NSString* const c_vocab_measurement = @"glucose-measurement-type";

@interface HVBloodGlucose (HVPrivate)

+(HVCodableValue *) newMeasurementText:(NSString *) text andCode:(NSString *) code;
+(HVCodedValue *) newMeasurementCode:(NSString *) code;

@end

@implementation HVBloodGlucose

@synthesize when = m_when;
@synthesize value = m_value;
@synthesize measurementType = m_measurementType;
@synthesize isOutsideOperatingTemp = m_outsideOperatingTemp;
@synthesize isControlTest = m_controlTest;
@synthesize context = m_context;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(double)inMgPerDL
{
    return (m_value) ? m_value.mgPerDL : NAN;
}

-(void)setInMgPerDL:(double)inMgPerDL
{
    HVENSURE(m_value, HVBloodGlucoseMeasurement);
    m_value.mgPerDL = inMgPerDL;
}

-(double)inMmolPerLiter
{
    return (m_value) ? m_value.mmolPerLiter : NAN;
}

-(void)setInMmolPerLiter:(double)inMmolPerLiter
{
    HVENSURE(m_value, HVBloodGlucoseMeasurement);
    m_value.mmolPerLiter = inMmolPerLiter;
}

-(enum HVRelativeRating)normalcy
{
    return (m_normalcy) ? (enum HVRelativeRating) m_normalcy.value : HVRelativeRating_None;
}

-(void)setNormalcy:(enum HVRelativeRating)normalcy
{
    if (normalcy == HVRelativeRating_None)
    {
        HVCLEAR(m_normalcy);
    }
    else 
    {
        HVENSURE(m_normalcy, HVOneToFive);
        m_normalcy.value = normalcy;
    }
}


-(id)initWithMmolPerLiter:(double)value andDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.inMmolPerLiter = value;
    HVCHECK_NOTNULL(m_value);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_when release];
    [m_value release];
    [m_measurementType release];
    [m_outsideOperatingTemp release];
    [m_controlTest release];
    [m_normalcy release];
    [m_context release];
    
    [super dealloc];
}

-(NSString *)stringInMgPerDL:(NSString *)format
{
    return [NSString stringWithFormat:format, self.inMgPerDL];
}

-(NSString *)stringInMmolPerLiter:(NSString *)format
{
    return [NSString stringWithFormat:format, self.inMmolPerLiter];
}

-(NSString *)toString
{
    return [self stringInMmolPerLiter:@"%.3f mmol/L"];
}

-(NSString *)normalcyText
{
    return stringFromNormalcy(self.normalcy);
}

+(HVCodableValue *)createPlasmaMeasurementType
{
    return [[HVBloodGlucose newMeasurementText:@"Plasma" andCode:@"p"] autorelease];
}

+(HVCodableValue *)createWholeBloodMeasurementType
{
    return [[HVBloodGlucose newMeasurementText:@"Whole blood" andCode:@"wb"] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidBloodGlucose);
    HVVALIDATE(m_value, HVClientError_InvalidBloodGlucose);
    HVVALIDATE(m_measurementType, HVClientError_InvalidBloodGlucose);
    HVVALIDATE_OPTIONAL(m_outsideOperatingTemp);
    HVVALIDATE_OPTIONAL(m_controlTest);
    HVVALIDATE_OPTIONAL(m_normalcy);
    HVVALIDATE_OPTIONAL(m_context);

    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_value, c_element_value);
    HVSERIALIZE(m_measurementType, c_element_type);
    HVSERIALIZE(m_outsideOperatingTemp, c_element_operatingTemp);
    HVSERIALIZE(m_controlTest, c_element_controlTest);
    HVSERIALIZE(m_normalcy, c_element_normalcy);
    HVSERIALIZE(m_context, c_element_context);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDateTime);
    HVDESERIALIZE(m_value, c_element_value, HVBloodGlucoseMeasurement);
    HVDESERIALIZE(m_measurementType, c_element_type, HVCodableValue);
    HVDESERIALIZE(m_outsideOperatingTemp, c_element_operatingTemp, HVBool);
    HVDESERIALIZE(m_controlTest, c_element_controlTest, HVBool);
    HVDESERIALIZE(m_normalcy, c_element_normalcy, HVOneToFive);
    HVDESERIALIZE(m_context, c_element_context, HVCodableValue);    
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
    return [[HVItem alloc] initWithType:[HVBloodGlucose typeID]];
}

@end

@implementation HVBloodGlucose (HVPrivate)
    
+(HVCodableValue *)newMeasurementText:(NSString *)text andCode:(NSString *)code
{
    HVCodedValue* codedValue = [HVBloodGlucose newMeasurementCode:code];
    HVCodableValue* codableValue = [[HVCodableValue alloc] initWithText:text andCode:codedValue];
    [codedValue release];
    return codableValue;
}

+(HVCodedValue *) newMeasurementCode:(NSString *)code
{
    return [[HVCodedValue alloc] initWithCode:code andVocab:c_vocab_measurement];
}

@end
