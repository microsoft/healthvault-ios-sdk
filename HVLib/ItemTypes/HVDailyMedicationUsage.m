//
//  HVDailyMedicationUsage.m
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
//

#import "HVCommon.h"
#import "HVDailyMedicationUsage.h"

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

@implementation HVDailyMedicationUsage

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
    HVENSURE(m_dosesConsumed, HVInt);
    m_dosesConsumed.value = dosesConsumedValue;
}

-(int)dosesIntendedValue
{
    return (m_dosesIntended) ? m_dosesIntended.value : -1;
}

-(void)setDosesIntendedValue:(int)dosesIntendedValue
{
    HVENSURE(m_dosesIntended, HVInt);
    m_dosesIntended.value = dosesIntendedValue;
}

-(id)initWithDoses:(int)doses forDrug:(HVCodableValue *)drug onDay:(NSDate *)day
{
    HVCHECK_NOTNULL(day);
    
    HVDate* date =  [[HVDate alloc] initWithDate:day];
    [self initWithDoses:doses forDrug:drug onDate:date];
    [date release];
    HVCHECK_SELF;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithDoses:(int)doses forDrug:(HVCodableValue *)drug onDate:(HVDate *)date
{
    HVCHECK_NOTNULL(drug);
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_when, date);
    
    self.drugName = drug;
    
    self.dosesConsumedValue = doses;
    HVCHECK_NOTNULL(m_dosesConsumed);
    
    return self;
    
LError:
    HVALLOC_FAIL;    
}

-(void)dealloc
{
    [m_when release];
    [m_drugName release];
    [m_dosesConsumed release];
    [m_purpose release];
    [m_dosesIntended release];
    [m_usageSchedule release];
    [m_drugForm release];
    [m_prescriptionType release];
    [m_singleDoseDescription release];
    
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

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_drugName) ? [m_drugName toString] : c_emptyString;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidDailyMedicationUsage);
    HVVALIDATE(m_drugName, HVClientError_InvalidDailyMedicationUsage);
    HVVALIDATE(m_dosesConsumed, HVClientError_InvalidDailyMedicationUsage);
    
    HVVALIDATE_OPTIONAL(m_purpose);
    HVVALIDATE_OPTIONAL(m_dosesIntended);
    HVVALIDATE_OPTIONAL(m_usageSchedule);
    HVVALIDATE_OPTIONAL(m_drugForm);
    HVVALIDATE_OPTIONAL(m_prescriptionType);
    HVVALIDATE_OPTIONAL(m_singleDoseDescription);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_X(m_when, x_element_when);
    HVSERIALIZE_X(m_drugName, x_element_drugName);
    HVSERIALIZE_X(m_dosesConsumed, x_element_dosesConsumed);
    HVSERIALIZE_X(m_purpose, x_element_purpose);
    HVSERIALIZE_X(m_dosesIntended, x_element_dosesIntended);
    HVSERIALIZE_X(m_usageSchedule, x_element_usageSchedule);
    HVSERIALIZE_X(m_drugForm, x_element_drugForm);
    HVSERIALIZE_X(m_prescriptionType, x_element_prescriptionType);
    HVSERIALIZE_X(m_singleDoseDescription, x_element_singleDoseDescr);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_when, x_element_when, HVDate);
    HVDESERIALIZE_X(m_drugName, x_element_drugName, HVCodableValue);
    HVDESERIALIZE_X(m_dosesConsumed, x_element_dosesConsumed, HVInt);
    HVDESERIALIZE_X(m_purpose, x_element_purpose, HVCodableValue);
    HVDESERIALIZE_X(m_dosesIntended, x_element_dosesIntended, HVInt);
    HVDESERIALIZE_X(m_usageSchedule, x_element_usageSchedule, HVCodableValue);
    HVDESERIALIZE_X(m_drugForm, x_element_drugForm, HVCodableValue);
    HVDESERIALIZE_X(m_prescriptionType, x_element_prescriptionType, HVCodableValue);
    HVDESERIALIZE_X(m_singleDoseDescription, x_element_singleDoseDescr, HVCodableValue);
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
    return [[HVItem alloc] initWithType:[HVDailyMedicationUsage typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Medication usage", @"Daily medication usage Type Name");
}

@end
