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

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_activity = XMLSTRINGCONST("activity");
static const xmlChar* x_element_title = XMLSTRINGCONST("title");
static const xmlChar* x_element_distance = XMLSTRINGCONST("distance");
static const xmlChar* x_element_duration = XMLSTRINGCONST("duration");
static NSString* const c_element_detail = @"detail";
static NSString* const c_element_segment = @"segment";

static NSString* const c_vocabName_Activities = @"exercise-activities";
static NSString* const c_vocabName_Details = @"exercise-detail-names";
static NSString* const c_vocabName_Units = @"exercise-units";

static NSString* const c_code_stepCount = @"Steps_count";
static NSString* const c_code_caloriesBurned = @"CaloriesBurned_calories";

@interface HVExercise (HVPrivate)

+(HVCodableValue *) newActivity:(NSString *) activity;
+(HVNameValue *) newDetailWithNameCode:(NSString *)name andValue:(HVMeasurement *)value;

@end

static HVVocabIdentifier* s_vocabIDActivities;
static HVVocabIdentifier* s_vocabIDDetails;
static HVVocabIdentifier* s_vocabIDUnits;

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

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
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

+(void)initialize
{
    s_vocabIDActivities = [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Activities];
    s_vocabIDDetails = [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Details];
    s_vocabIDUnits = [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Units];
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
    HVCLEAR(m_activity);
    m_activity = [HVExercise newActivity:activity];
    return (m_activity != nil);
}

-(HVNameValue *)getDetailWithNameCode:(NSString *)name
{
    if (!self.hasDetails)
    {
        return nil;
    }
    
    NSUInteger index = [m_details indexOfItemWithNameCode:name];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [m_details objectAtIndex:index];
}

-(BOOL)addOrUpdateDetailWithNameCode:(NSString *)name andValue:(HVMeasurement *)value
{
    HVNameValue* detail = [HVExercise newDetailWithNameCode:name andValue:value];
    HVCHECK_NOTNULL(detail);
    
    [self.details addOrUpdate:detail];
    [detail release];
    
    return TRUE;
    
LError:
    return FALSE;
}

+(HVNameValue *)createDetailWithNameCode:(NSString *)name andValue:(HVMeasurement *)value
{
    return [[HVExercise newDetailWithNameCode:name andValue:value] autorelease];
}

+(BOOL)isDetailForCaloriesBurned:(HVNameValue *)nv
{
    HVCHECK_NOTNULL(nv);
    
    HVCodedValue* name = nv.name;
    return (
            [name isEqualToCode:c_code_caloriesBurned fromVocab:c_vocabName_Details] ||
            [name.code isEqualToString:@"Calories burned"] // Fitbug bug
            );

LError:
     return FALSE;
}

+(BOOL)isDetailForNumberOfSteps:(HVNameValue *)nv
{
    HVCHECK_NOTNULL(nv);
    
    HVCodedValue* name = nv.name;
    return (
            [name isEqualToCode:c_code_stepCount fromVocab:c_vocabName_Details] ||
            [name.code isEqualToString:@"Number of steps"] // Fitbit bug
            );
    
LError:
    return FALSE;
    
}

+(HVCodableValue *)codeFromUnitsText:(NSString *)unitsText andUnitsCode:(NSString *)unitsCode
{
    return [[HVExercise vocabForUnits] codableValueForText:unitsText andCode:unitsCode];
}

+(HVCodableValue *)unitsCodeForCount
{
    return [HVExercise codeFromUnitsText:@"Count" andUnitsCode:@"Count"];
}

+(HVCodableValue *)unitsCodeForCalories
{
    return [HVExercise codeFromUnitsText:@"Calories" andUnitsCode:@"Calories"];    
}

+(HVMeasurement *)measurementFor:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)unitsCode
{
    HVCodableValue* codedUnits = [HVExercise codeFromUnitsText:unitsText andUnitsCode:unitsCode];
    HVCHECK_NOTNULL(codedUnits);
    
    return [HVMeasurement fromValue:value andUnits:codedUnits];

LError:
    return nil;
}

+(HVMeasurement *)measurementForCount:(double)value
{
    return [HVMeasurement fromValue:value andUnits:[HVExercise unitsCodeForCount]];
}

+(HVMeasurement *)measurementForCalories:(double)value
{
    return [HVMeasurement fromValue:value andUnits:[HVExercise unitsCodeForCalories]];
}

+(HVCodedValue *)detailNameWithCode:(NSString *)code
{
    return [[HVExercise vocabForDetails] codedValueForCode:code];
}

+(HVCodedValue *)detailNameForSteps
{
    return [HVExercise detailNameWithCode:c_code_stepCount];
}

+(HVCodedValue *)detailNameForCaloriesBurned
{
    return [HVExercise detailNameWithCode:c_code_caloriesBurned];
}

+(HVVocabIdentifier *)vocabForActivities
{
    return s_vocabIDActivities;
}

+(HVVocabIdentifier *)vocabForDetails
{
    return s_vocabIDDetails;                
}

+(HVVocabIdentifier *)vocabForUnits
{
    return s_vocabIDUnits;                
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
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_activity content:m_activity];
    [writer writeElementXmlName:x_element_title value:m_title];
    [writer writeElementXmlName:x_element_distance content:m_distance];
    [writer writeElementXmlName:x_element_duration content:m_duration];
    [writer writeElementArray:c_element_detail elements:m_details];
    
    [writer writeRawElementArray:c_element_segment elements:m_segmentsXml];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElementWithXmlName:x_element_when asClass:[HVApproxDateTime class]] retain];
    m_activity = [[reader readElementWithXmlName:x_element_activity asClass:[HVCodableValue class]] retain];
    m_title = [[reader readStringElementWithXmlName:x_element_title] retain];
    m_distance = [[reader readElementWithXmlName:x_element_distance asClass:[HVLengthMeasurement class]] retain];
    m_duration = [[reader readElementWithXmlName:x_element_duration asClass:[HVPositiveDouble class]] retain];
    m_details = (HVNameValueCollection *)[[reader readElementArray:c_element_detail asClass:[HVNameValue class] andArrayClass:[HVNameValueCollection class]] retain];
    
    m_segmentsXml = [[reader readRawElementArray:c_element_segment] retain]; 
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

-(NSString *)typeName
{
    return NSLocalizedString(@"Exercise", @"Exercise Type Name");
}

@end

@implementation HVExercise (HVPrivate)

+(HVCodableValue *)newActivity:(NSString *)activity
{
    return [[HVCodableValue alloc] initWithText:activity code:activity andVocab:c_vocabName_Activities];
}

+(HVNameValue *) newDetailWithNameCode:(NSString *)name andValue:(HVMeasurement *)value
{
    HVCodedValue* codedValue = [[HVExercise vocabForDetails] codedValueForCode:name];
    HVCHECK_NOTNULL(codedValue);
    
    return [[HVNameValue alloc] initWithName:codedValue andValue:value];

LError:
    return nil;
}

@end
