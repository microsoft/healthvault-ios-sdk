//
//  HVExercise.m
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
#import "HVExercise.h"

static NSString* const c_typeid = @"85a21ddb-db20-4c65-8d30-33c899ccf612";
static NSString* const c_typename = @"exercise";

static NSString* const c_element_when = @"when";
static NSString* const c_element_activity = @"activity";
static NSString* const c_element_title = @"title";
static NSString* const c_element_distance = @"distance";
static NSString* const c_element_duration = @"duration";
static NSString* const c_element_detail = @"detail";
static NSString* const c_element_segment = @"segment";

@interface HVExercise (HVPrivate)

+(HVCodableValue *) newActivity:(NSString *) activity;
+(HVNameValue *) newDetailWithName:(NSString *)name andValue:(HVMeasurement *)value;

@end

@implementation HVExercise

@synthesize when = m_when;
@synthesize activity = m_activity;
@synthesize title = m_title;
@synthesize distance = m_distance;
@synthesize durationMinutes = m_duration;
@synthesize segmentsXml = m_segmentsXml;

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(BOOL)hasDetails
{
    return (m_details && m_details.count > 0);
}

-(HVNameValueCollection *)details
{
    HVENSURE(m_details, HVNameValueCollection);
    return m_details;
}

-(void)setDetails:(HVNameValueCollection *)details
{
    HVRETAIN(m_details, details);
}

-(double)durationMinutesValue
{
    return (m_duration) ? m_duration.value : NAN;
}

-(void)setDurationMinutesValue:(double)durationMinutesValue
{
    HVENSURE(m_duration, HVPositiveDouble);
    m_duration.value = durationMinutesValue;
}

-(void)dealloc
{
    [m_when release];
    [m_activity release];
    [m_title release];
    [m_distance release];
    [m_duration release];
    [m_details release];   
    [m_segmentsXml release];
    
    [super dealloc];
}

-(id)initWithDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVApproxDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

+(HVCodableValue *)createActivity:(NSString *)activity
{
    return [[HVExercise newActivity:activity] autorelease];
}

-(BOOL)setStandardActivity:(NSString *)activity
{
    HVRETAIN(m_activity, [HVExercise newActivity:activity]);
    return (m_activity != nil);
}

+(HVNameValue *)createDetailWithName:(NSString *)name andValue:(HVMeasurement *)value
{
    return [[HVExercise newDetailWithName:name andValue:value] autorelease];
}

-(BOOL)addOrUpdateDetailWithName:(NSString *)name andValue:(HVMeasurement *)value
{
    HVNameValue* detail = [HVExercise newDetailWithName:name andValue:value];
    HVCHECK_NOTNULL(detail);
    
    [self.details addOrUpdate:detail];
    [detail release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidExercise);
    HVVALIDATE(m_activity, HVClientError_InvalidExercise);
    HVVALIDATE_STRINGOPTIONAL(m_title, HVClientError_InvalidExercise);
    HVVALIDATE_OPTIONAL(m_distance);
    HVVALIDATE_OPTIONAL(m_duration);
    HVVALIDATE_ARRAYOPTIONAL(m_details, HVClientError_InvalidExercise);

    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;   
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_activity, c_element_activity);
    HVSERIALIZE_STRING(m_title, c_element_title);
    HVSERIALIZE(m_distance, c_element_distance);
    HVSERIALIZE(m_duration, c_element_duration);
    HVSERIALIZE_ARRAY(m_details, c_element_detail);
    
    HVSERIALIZE_RAWARRAY(m_segmentsXml, c_element_segment);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVApproxDateTime);
    HVDESERIALIZE(m_activity, c_element_activity, HVCodableValue);
    HVDESERIALIZE_STRING(m_title, c_element_title);
    HVDESERIALIZE(m_distance, c_element_distance, HVLengthMeasurement);
    HVDESERIALIZE(m_duration, c_element_duration, HVPositiveDouble);
    HVDESERIALIZE_TYPEDARRAY(m_details, c_element_detail, HVNameValue, HVNameValueCollection);
    
    HVDESERIALIZE_RAWARRAY(m_segmentsXml, c_element_segment); 
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
    return [[HVItem alloc] initWithType:[HVExercise typeID]];
}

@end

@implementation HVExercise (HVPrivate)

+(HVCodableValue *)newActivity:(NSString *)activity
{
    return [[HVCodableValue alloc] initWithText:activity code:activity andVocab:@"exercise-activities"];
}

+(HVNameValue *) newDetailWithName:(NSString *)name andValue:(HVMeasurement *)value
{
    HVCodedValue* codedValue = [[HVCodedValue alloc] initWithCode:name andVocab:@"exercise-detail-names"];
    HVNameValue* nv = [[HVNameValue alloc] initWithName:codedValue andValue:value];
    [codedValue release];
    
    return nv;
}

@end
