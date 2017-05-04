//
//  MHVDailyMedicationUsage.m
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
//

#import "MHVCommon.h"
#import "MHVDailyMedicationUsage.h"

static NSString* const c_typeid = @"a9a76456-0357-493e-b840-598bbb9483fd";
static NSString* const c_typename = @"daily-medication-usage";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_drugName = XMLSTRINGCONST("drug-name");
static const xmlChar* x_element_dosesConsumed = XMLSTRINGCONST("number-doses-consumed-in-day");
static const xmlChar* x_element_purpose = XMLSTRINGCONST("purpose-of-use");
static const xmlChar* x_element_dosesIntended = XMLSTRINGCONST("number-doses-intended-in-day");
static const xmlChar* x_element_usageSchedule = XMLSTRINGCONST("medication-usage-schedule");
static const xmlChar* x_element_drugForm = XMLSTRINGCONST("drug-form");
static const xmlChar* x_element_prescriptionType = XMLSTRINGCONST("prescription-type");
static const xmlChar* x_element_singleDoseDescr = XMLSTRINGCONST("single-dose-description");

@implementation MHVDailyMedicationUsage

@synthesize when = m_when;
@synthesize drugName = m_drugName;
@synthesize dosesConsumed = m_dosesConsumed;
@synthesize purpose = m_purpose;
@synthesize dosesIntended = m_dosesIntended;
@synthesize usageSchedule = m_usageSchedule;
@synthesize drugForm = m_drugForm;
@synthesize prescriptionType = m_prescriptionType;
@synthesize singleDoseDescription = m_singleDoseDescription;

-(int)dosesConsumedValue
{
    return (m_dosesConsumed) ? m_dosesConsumed.value : -1;
}

-(void)setDosesConsumedValue:(int)dosesConsumedValue
{
    MHVENSURE(m_dosesConsumed, MHVInt);
    m_dosesConsumed.value = dosesConsumedValue;
}

-(int)dosesIntendedValue
{
    return (m_dosesIntended) ? m_dosesIntended.value : -1;
}

-(void)setDosesIntendedValue:(int)dosesIntendedValue
{
    MHVENSURE(m_dosesIntended, MHVInt);
    m_dosesIntended.value = dosesIntendedValue;
}

-(id)initWithDoses:(int)doses forDrug:(MHVCodableValue *)drug onDay:(NSDate *)day
{
    MHVCHECK_NOTNULL(day);
    
    MHVDate* date =  [[MHVDate alloc] initWithDate:day];
    if (!(self = [self initWithDoses:doses forDrug:drug onDate:date])) return nil;
    MHVCHECK_SELF;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithDoses:(int)doses forDrug:(MHVCodableValue *)drug onDate:(MHVDate *)date
{
    MHVCHECK_NOTNULL(drug);
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_when = date;
    
    self.drugName = drug;
    
    self.dosesConsumedValue = doses;
    MHVCHECK_NOTNULL(m_dosesConsumed);
    
    return self;
    
LError:
    MHVALLOC_FAIL;    
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_drugName) ? [m_drugName toString] : c_emptyString;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_when, MHVClientError_InvalidDailyMedicationUsage);
    MHVVALIDATE(m_drugName, MHVClientError_InvalidDailyMedicationUsage);
    MHVVALIDATE(m_dosesConsumed, MHVClientError_InvalidDailyMedicationUsage);
    
    MHVVALIDATE_OPTIONAL(m_purpose);
    MHVVALIDATE_OPTIONAL(m_dosesIntended);
    MHVVALIDATE_OPTIONAL(m_usageSchedule);
    MHVVALIDATE_OPTIONAL(m_drugForm);
    MHVVALIDATE_OPTIONAL(m_prescriptionType);
    MHVVALIDATE_OPTIONAL(m_singleDoseDescription);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_drugName content:m_drugName];
    [writer writeElementXmlName:x_element_dosesConsumed content:m_dosesConsumed];
    [writer writeElementXmlName:x_element_purpose content:m_purpose];
    [writer writeElementXmlName:x_element_dosesIntended content:m_dosesIntended];
    [writer writeElementXmlName:x_element_usageSchedule content:m_usageSchedule];
    [writer writeElementXmlName:x_element_drugForm content:m_drugForm];
    [writer writeElementXmlName:x_element_prescriptionType content:m_prescriptionType];
    [writer writeElementXmlName:x_element_singleDoseDescr content:m_singleDoseDescription];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDate class]];
    m_drugName = [reader readElementWithXmlName:x_element_drugName asClass:[MHVCodableValue class]];
    m_dosesConsumed = [reader readElementWithXmlName:x_element_dosesConsumed asClass:[MHVInt class]];
    m_purpose = [reader readElementWithXmlName:x_element_purpose asClass:[MHVCodableValue class]];
    m_dosesIntended = [reader readElementWithXmlName:x_element_dosesIntended asClass:[MHVInt class]];
    m_usageSchedule = [reader readElementWithXmlName:x_element_usageSchedule asClass:[MHVCodableValue class]];
    m_drugForm = [reader readElementWithXmlName:x_element_drugForm asClass:[MHVCodableValue class]];
    m_prescriptionType = [reader readElementWithXmlName:x_element_prescriptionType asClass:[MHVCodableValue class]];
    m_singleDoseDescription = [reader readElementWithXmlName:x_element_singleDoseDescr asClass:[MHVCodableValue class]];
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
    return [[MHVItem alloc] initWithType:[MHVDailyMedicationUsage typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Medication usage", @"Daily medication usage Type Name");
}

@end
