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

static NSString* const c_element_when = @"when";
static NSString* const c_element_drugName = @"drug-name";
static NSString* const c_element_dosesConsumed = @"number-doses-consumed-in-day";
static NSString* const c_element_purpose = @"purpose-of-use";
static NSString* const c_element_dosesIntended = @"number-doses-intended-in-day";
static NSString* const c_element_usageSchedule = @"medication-usage-schedule";
static NSString* const c_element_drugForm = @"drug-form";
static NSString* const c_element_prescriptionType = @"prescription-type";
static NSString* const c_element_singleDoseDescr = @"single-dose-description";

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
    HVCHECK_NOTNULL(drug);
    HVCHECK_NOTNULL(day);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVDate alloc] initWithDate:day];
    HVCHECK_NOTNULL(m_when);
    
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
    HVSERIALIZE(m_when, c_element_when);
    HVSERIALIZE(m_drugName, c_element_drugName);
    HVSERIALIZE(m_dosesConsumed, c_element_dosesConsumed);
    HVSERIALIZE(m_purpose, c_element_purpose);
    HVSERIALIZE(m_dosesIntended, c_element_dosesIntended);
    HVSERIALIZE(m_usageSchedule, c_element_usageSchedule);
    HVSERIALIZE(m_drugForm, c_element_drugForm);
    HVSERIALIZE(m_prescriptionType, c_element_prescriptionType);
    HVSERIALIZE(m_singleDoseDescription, c_element_singleDoseDescr);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_when, c_element_when, HVDate);
    HVDESERIALIZE(m_drugName, c_element_drugName, HVCodableValue);
    HVDESERIALIZE(m_dosesConsumed, c_element_dosesConsumed, HVInt);
    HVDESERIALIZE(m_purpose, c_element_purpose, HVCodableValue);
    HVDESERIALIZE(m_dosesIntended, c_element_dosesIntended, HVInt);
    HVDESERIALIZE(m_usageSchedule, c_element_usageSchedule, HVCodableValue);
    HVDESERIALIZE(m_drugForm, c_element_drugForm, HVCodableValue);
    HVDESERIALIZE(m_prescriptionType, c_element_prescriptionType, HVCodableValue);
    HVDESERIALIZE(m_singleDoseDescription, c_element_singleDoseDescr, HVCodableValue);
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

@end
