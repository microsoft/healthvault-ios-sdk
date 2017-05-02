//
//  HVHeartRate.m
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
#import "HVHeartRate.h"

static NSString* const c_typeID = @"b81eb4a6-6eac-4292-ae93-3872d6870994";
static NSString* const c_typeName = @"heart-rate";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");
static const xmlChar* x_element_method = XMLSTRINGCONST("measurement-method");
static const xmlChar* x_element_conditions = XMLSTRINGCONST("measurement-conditions");
static const xmlChar* x_element_flags = XMLSTRINGCONST("measurement-flags");

@implementation HVHeartRate

@synthesize when = m_when;
@synthesize bpm = m_bpm;
@synthesize measurementMethod = m_measurementMethod;
@synthesize measurementConditions = m_measurementConditions;
@synthesize measurementFlags = m_measurementFlags;

-(int)bpmValue
{
    return (m_bpm != nil) ? m_bpm.value : -1;
}

-(void)setBpmValue:(int)bpmValue
{
    HVENSURE(m_bpm, HVNonNegativeInt);
    m_bpm.value = bpmValue;
}

-(id)initWithBpm:(int)bpm andDate:(NSDate *)date
{
    self = [super init];
    HVCHECK_SELF;
    
    m_bpm = [[HVNonNegativeInt alloc] initWith:bpm];
    HVCHECK_NOTNULL(m_bpm);
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_when release];
    [m_bpm release];
    [m_measurementMethod release];
    [m_measurementConditions release];
    [m_measurementFlags release];
    
    [super dealloc];
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

+(HVVocabIdentifier *)vocabForMeasurementMethod
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"heart-rate-measurement-method"] autorelease];
}

+(HVVocabIdentifier *)vocabForMeasurementConditions
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"heart-rate-measurement-conditions"] autorelease];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"%d bpm"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString localizedStringWithFormat:format, self.bpmValue];
}

-(NSString *)description
{
    return [self toString];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidHeartRate);
    HVVALIDATE(m_bpm, HVClientError_InvalidHeartRate);
    HVVALIDATE_OPTIONAL(m_measurementMethod);
    HVVALIDATE_OPTIONAL(m_measurementConditions);
    HVVALIDATE_OPTIONAL(m_measurementFlags);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_value content:m_bpm];
    [writer writeElementXmlName:x_element_method content:m_measurementMethod];
    [writer writeElementXmlName:x_element_conditions content:m_measurementConditions];
    [writer writeElementXmlName:x_element_flags content:m_measurementFlags];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElementWithXmlName:x_element_when asClass:[HVDateTime class]] retain];
    m_bpm = [[reader readElementWithXmlName:x_element_value asClass:[HVNonNegativeInt class]] retain];
    m_measurementMethod = [[reader readElementWithXmlName:x_element_method asClass:[HVCodableValue class]] retain];
    m_measurementConditions = [[reader readElementWithXmlName:x_element_conditions asClass:[HVCodableValue class]] retain];
    m_measurementFlags = [[reader readElementWithXmlName:x_element_flags asClass:[HVCodableValue class]] retain];
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
    return [[HVItem alloc] initWithType:[HVHeartRate typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Heart Rate", @"Heart Rate Type Name");
}

@end
