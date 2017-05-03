//
//  MHVExercise.m
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
#import "MHVExercise.h"

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

@interface MHVExercise (HVPrivate)

+(MHVCodableValue *) newActivity:(NSString *) activity;
+(MHVNameValue *) newDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value;

@end

static MHVVocabIdentifier* s_vocabIDActivities;
static MHVVocabIdentifier* s_vocabIDDetails;
static MHVVocabIdentifier* s_vocabIDUnits;

@implementation MHVExercise

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

-(MHVNameValueCollection *)details
{
    HVENSURE(m_details, MHVNameValueCollection);
    return m_details;
}

-(void)setDetails:(MHVNameValueCollection *)details
{
    m_details = details;
}

-(double)durationMinutesValue
{
    return (m_duration) ? m_duration.value : NAN;
}

-(void)setDurationMinutesValue:(double)durationMinutesValue
{
    HVENSURE(m_duration, MHVPositiveDouble);
    m_duration.value = durationMinutesValue;
}

+(void)initialize
{
    s_vocabIDActivities = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Activities];
    s_vocabIDDetails = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Details];
    s_vocabIDUnits = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Units];
}


-(id)initWithDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[MHVApproxDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

+(MHVCodableValue *)createActivity:(NSString *)activity
{
    return [MHVExercise newActivity:activity];
}

-(BOOL)setStandardActivity:(NSString *)activity
{
    m_activity = nil;
    m_activity = [MHVExercise newActivity:activity];
    return (m_activity != nil);
}

-(MHVNameValue *)getDetailWithNameCode:(NSString *)name
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

-(BOOL)addOrUpdateDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    MHVNameValue* detail = [MHVExercise newDetailWithNameCode:name andValue:value];
    HVCHECK_NOTNULL(detail);
    
    [self.details addOrUpdate:detail];
    
    return TRUE;
    
LError:
    return FALSE;
}

+(MHVNameValue *)createDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    return [MHVExercise newDetailWithNameCode:name andValue:value];
}

+(BOOL)isDetailForCaloriesBurned:(MHVNameValue *)nv
{
    HVCHECK_NOTNULL(nv);
    
    MHVCodedValue* name = nv.name;
    return (
            [name isEqualToCode:c_code_caloriesBurned fromVocab:c_vocabName_Details] ||
            [name.code isEqualToString:@"Calories burned"] // Fitbug bug
            );

LError:
     return FALSE;
}

+(BOOL)isDetailForNumberOfSteps:(MHVNameValue *)nv
{
    HVCHECK_NOTNULL(nv);
    
    MHVCodedValue* name = nv.name;
    return (
            [name isEqualToCode:c_code_stepCount fromVocab:c_vocabName_Details] ||
            [name.code isEqualToString:@"Number of steps"] // Fitbit bug
            );
    
LError:
    return FALSE;
    
}

+(MHVCodableValue *)codeFromUnitsText:(NSString *)unitsText andUnitsCode:(NSString *)unitsCode
{
    return [[MHVExercise vocabForUnits] codableValueForText:unitsText andCode:unitsCode];
}

+(MHVCodableValue *)unitsCodeForCount
{
    return [MHVExercise codeFromUnitsText:@"Count" andUnitsCode:@"Count"];
}

+(MHVCodableValue *)unitsCodeForCalories
{
    return [MHVExercise codeFromUnitsText:@"Calories" andUnitsCode:@"Calories"];    
}

+(MHVMeasurement *)measurementFor:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)unitsCode
{
    MHVCodableValue* codedUnits = [MHVExercise codeFromUnitsText:unitsText andUnitsCode:unitsCode];
    HVCHECK_NOTNULL(codedUnits);
    
    return [MHVMeasurement fromValue:value andUnits:codedUnits];

LError:
    return nil;
}

+(MHVMeasurement *)measurementForCount:(double)value
{
    return [MHVMeasurement fromValue:value andUnits:[MHVExercise unitsCodeForCount]];
}

+(MHVMeasurement *)measurementForCalories:(double)value
{
    return [MHVMeasurement fromValue:value andUnits:[MHVExercise unitsCodeForCalories]];
}

+(MHVCodedValue *)detailNameWithCode:(NSString *)code
{
    return [[MHVExercise vocabForDetails] codedValueForCode:code];
}

+(MHVCodedValue *)detailNameForSteps
{
    return [MHVExercise detailNameWithCode:c_code_stepCount];
}

+(MHVCodedValue *)detailNameForCaloriesBurned
{
    return [MHVExercise detailNameWithCode:c_code_caloriesBurned];
}

+(MHVVocabIdentifier *)vocabForActivities
{
    return s_vocabIDActivities;
}

+(MHVVocabIdentifier *)vocabForDetails
{
    return s_vocabIDDetails;                
}

+(MHVVocabIdentifier *)vocabForUnits
{
    return s_vocabIDUnits;                
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_when, HVClientError_InvalidExercise);
    HVVALIDATE(m_activity, HVClientError_InvalidExercise);
    HVVALIDATE_STRINGOPTIONAL(m_title, HVClientError_InvalidExercise);
    HVVALIDATE_OPTIONAL(m_distance);
    HVVALIDATE_OPTIONAL(m_duration);
    HVVALIDATE_ARRAYOPTIONAL(m_details, HVClientError_InvalidExercise);

    HVVALIDATE_SUCCESS;
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
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    m_activity = [reader readElementWithXmlName:x_element_activity asClass:[MHVCodableValue class]];
    m_title = [reader readStringElementWithXmlName:x_element_title];
    m_distance = [reader readElementWithXmlName:x_element_distance asClass:[MHVLengthMeasurement class]];
    m_duration = [reader readElementWithXmlName:x_element_duration asClass:[MHVPositiveDouble class]];
    m_details = (MHVNameValueCollection *)[reader readElementArray:c_element_detail asClass:[MHVNameValue class] andArrayClass:[MHVNameValueCollection class]];
    
    m_segmentsXml = [reader readRawElementArray:c_element_segment]; 
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVExercise typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Exercise", @"Exercise Type Name");
}

@end

@implementation MHVExercise (HVPrivate)

+(MHVCodableValue *)newActivity:(NSString *)activity
{
    return [[MHVCodableValue alloc] initWithText:activity code:activity andVocab:c_vocabName_Activities];
}

+(MHVNameValue *) newDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    MHVCodedValue* codedValue = [[MHVExercise vocabForDetails] codedValueForCode:name];
    HVCHECK_NOTNULL(codedValue);
    
    return [[MHVNameValue alloc] initWithName:codedValue andValue:value];

LError:
    return nil;
}

@end
