//
// MHVExercise.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString *const c_typeid = @"85a21ddb-db20-4c65-8d30-33c899ccf612";
static NSString *const c_typename = @"exercise";

static const xmlChar *x_element_when = XMLSTRINGCONST("when");
static const xmlChar *x_element_activity = XMLSTRINGCONST("activity");
static const xmlChar *x_element_title = XMLSTRINGCONST("title");
static const xmlChar *x_element_distance = XMLSTRINGCONST("distance");
static const xmlChar *x_element_duration = XMLSTRINGCONST("duration");
static NSString *const c_element_detail = @"detail";
static NSString *const c_element_segment = @"segment";

static NSString *const c_vocabName_Activities = @"exercise-activities";
static NSString *const c_vocabName_Details = @"exercise-detail-names";
static NSString *const c_vocabName_Units = @"exercise-units";

static NSString *const c_code_stepCount = @"Steps_count";
static NSString *const c_code_caloriesBurned = @"CaloriesBurned_calories";

static MHVVocabIdentifier *s_vocabIDActivities;
static MHVVocabIdentifier *s_vocabIDDetails;
static MHVVocabIdentifier *s_vocabIDUnits;

@interface MHVExercise ()

@property (nonatomic, strong) MHVPositiveDouble *duration;

@end

@implementation MHVExercise

- (NSDate *)getDate
{
    return [self.when toDate];
}

- (NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [self.when toDateForCalendar:calendar];
}

- (BOOL)hasDetails
{
    return self.details && self.details.count > 0;
}

- (MHVNameValueCollection *)details
{
    if (!_details)
    {
        _details = [MHVNameValueCollection new];
    }

    return _details;
}

- (double)durationMinutesValue
{
    return self.duration != nil ? self.duration.value : NAN;
}

- (void)setDurationMinutesValue:(double)durationMinutesValue
{
    if (!self.duration)
    {
        self.duration = [MHVPositiveDouble new];
    }

    self.duration.value = durationMinutesValue;
}

+ (void)initialize
{
    s_vocabIDActivities = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Activities];
    s_vocabIDDetails = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Details];
    s_vocabIDUnits = [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:c_vocabName_Units];
}

- (instancetype)initWithDate:(NSDate *)date
{
    MHVASSERT_PARAMETER(date);
    
    if (!date)
    {
        return nil;
    }

    self = [super init];
    
    if (self)
    {
        _when = [[MHVApproxDateTime alloc] initWithDate:date];
        
        if (!_when)
        {
            return nil;
        }
    }

    return self;
}

+ (MHVCodableValue *)createActivity:(NSString *)activity
{
    return [MHVExercise newActivity:activity];
}

- (BOOL)setStandardActivity:(NSString *)activity
{
    self.activity = [MHVExercise newActivity:activity];
    
    return self.activity != nil;
}

- (MHVNameValue *)getDetailWithNameCode:(NSString *)name
{
    if (!self.hasDetails)
    {
        return nil;
    }

    NSUInteger index = [self.details indexOfThingWithNameCode:name];
    
    if (index == NSNotFound)
    {
        return nil;
    }

    return [self.details objectAtIndex:index];
}

- (BOOL)addOrUpdateDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    MHVNameValue *detail = [MHVExercise newDetailWithNameCode:name andValue:value];

    if (!detail)
    {
        return NO;
    }

    [self.details addOrUpdate:detail];

    return YES;
}

+ (MHVNameValue *)createDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    return [MHVExercise newDetailWithNameCode:name andValue:value];
}

+ (BOOL)isDetailForCaloriesBurned:(MHVNameValue *)nv
{
    MHVASSERT_PARAMETER(nv);
    
    if (!nv)
    {
        return NO;
    }

    MHVCodedValue *name = nv.name;
    
    return [name isEqualToCode:c_code_caloriesBurned fromVocab:c_vocabName_Details] || [name.code isEqualToString:@"Calories burned"]; // Fitbug bug
}

+ (BOOL)isDetailForNumberOfSteps:(MHVNameValue *)nv
{
    MHVASSERT_PARAMETER(nv);
    
    if (!nv)
    {
        return NO;
    }

    MHVCodedValue *name = nv.name;
    
    return [name isEqualToCode:c_code_stepCount fromVocab:c_vocabName_Details] || [name.code isEqualToString:@"Number of steps"]; // Fitbit bug
}

+ (MHVCodableValue *)codeFromUnitsText:(NSString *)unitsText andUnitsCode:(NSString *)unitsCode
{
    return [[MHVExercise vocabForUnits] codableValueForText:unitsText andCode:unitsCode];
}

+ (MHVCodableValue *)unitsCodeForCount
{
    return [MHVExercise codeFromUnitsText:@"Count" andUnitsCode:@"Count"];
}

+ (MHVCodableValue *)unitsCodeForCalories
{
    return [MHVExercise codeFromUnitsText:@"Calories" andUnitsCode:@"Calories"];
}

+ (MHVMeasurement *)measurementFor:(double)value unitsText:(NSString *)unitsText unitsCode:(NSString *)unitsCode
{
    MHVCodableValue *codedUnits = [MHVExercise codeFromUnitsText:unitsText andUnitsCode:unitsCode];

    if (!codedUnits)
    {
        return nil;
    }

    return [MHVMeasurement fromValue:value andUnits:codedUnits];;
}

+ (MHVMeasurement *)measurementForCount:(double)value
{
    return [MHVMeasurement fromValue:value andUnits:[MHVExercise unitsCodeForCount]];
}

+ (MHVMeasurement *)measurementForCalories:(double)value
{
    return [MHVMeasurement fromValue:value andUnits:[MHVExercise unitsCodeForCalories]];
}

+ (MHVCodedValue *)detailNameWithCode:(NSString *)code
{
    return [[MHVExercise vocabForDetails] codedValueForCode:code];
}

+ (MHVCodedValue *)detailNameForSteps
{
    return [MHVExercise detailNameWithCode:c_code_stepCount];
}

+ (MHVCodedValue *)detailNameForCaloriesBurned
{
    return [MHVExercise detailNameWithCode:c_code_caloriesBurned];
}

+ (MHVVocabIdentifier *)vocabForActivities
{
    return s_vocabIDActivities;
}

+ (MHVVocabIdentifier *)vocabForDetails
{
    return s_vocabIDDetails;
}

+ (MHVVocabIdentifier *)vocabForUnits
{
    return s_vocabIDUnits;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE(self.when, MHVClientError_InvalidExercise);
    MHVVALIDATE(self.activity, MHVClientError_InvalidExercise);
    MHVVALIDATE_STRINGOPTIONAL(m_title, MHVClientError_InvalidExercise);
    MHVVALIDATE_OPTIONAL(self.distance);
    MHVVALIDATE_OPTIONAL(self.duration);
    MHVVALIDATE_ARRAYOPTIONAL(self.details, MHVClientError_InvalidExercise);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:self.when];
    [writer writeElementXmlName:x_element_activity content:self.activity];
    [writer writeElementXmlName:x_element_title value:self.title];
    [writer writeElementXmlName:x_element_distance content:self.distance];
    [writer writeElementXmlName:x_element_duration content:self.duration];
    [writer writeElementArray:c_element_detail elements:self.details.toArray];

    [writer writeRawElementArray:c_element_segment elements:self.segmentsXml];
}

- (void)deserialize:(XReader *)reader
{
    self.when = [reader readElementWithXmlName:x_element_when asClass:[MHVApproxDateTime class]];
    self.activity = [reader readElementWithXmlName:x_element_activity asClass:[MHVCodableValue class]];
    self.title = [reader readStringElementWithXmlName:x_element_title];
    self.distance = [reader readElementWithXmlName:x_element_distance asClass:[MHVLengthMeasurement class]];
    self.duration = [reader readElementWithXmlName:x_element_duration asClass:[MHVPositiveDouble class]];
    self.details = (MHVNameValueCollection *)[reader readElementArray:c_element_detail asClass:[MHVNameValue class] andArrayClass:[MHVNameValueCollection class]];

    self.segmentsXml = [reader readRawElementArray:c_element_segment];
}

+ (NSString *)typeID
{
    return c_typeid;
}

+ (NSString *)XRootElement
{
    return c_typename;
}

+ (MHVThing *)newThing
{
    return [[MHVThing alloc] initWithType:[MHVExercise typeID]];
}

- (NSString *)typeName
{
    return NSLocalizedString(@"Exercise", @"Exercise Type Name");
}

+ (MHVCodableValue *)newActivity:(NSString *)activity
{
    return [[MHVCodableValue alloc] initWithText:activity code:activity andVocab:c_vocabName_Activities];
}

+ (MHVNameValue *)newDetailWithNameCode:(NSString *)name andValue:(MHVMeasurement *)value
{
    MHVCodedValue *codedValue = [[MHVExercise vocabForDetails] codedValueForCode:name];

    if (codedValue)
    {
        return nil;
    }

    return [[MHVNameValue alloc] initWithName:codedValue andValue:value];
}

@end
