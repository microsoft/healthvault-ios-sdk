//
//  Weight.m
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
#import "MHVWeight.h"

static NSString* const c_typeid = @"3d34d87e-7fc1-4153-800f-f56592cb0d17";
static NSString* const c_typename = @"weight";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");

@implementation MHVWeight

@synthesize when = m_when;
@synthesize value = m_value;

-(double)inPounds
{
    return (m_value) ? m_value.inPounds : NAN;
}

-(void)setInPounds:(double)inPounds
{
    MHVENSURE(m_value, MHVWeightMeasurement);
    m_value.inPounds = inPounds;
}

-(void)setInKg:(double)inKg
{
    MHVENSURE(m_value, MHVWeightMeasurement);
    m_value.inKg = inKg;
}

-(double)inKg
{
    return (m_value) ? m_value.inKg : NAN;
}


-(id) initWithKg:(double)kg andDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_value = [[MHVWeightMeasurement alloc] initWithKg:kg];
    MHVCHECK_NOTNULL(m_value);
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(m_when);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithPounds:(double)pounds andDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_value = [[MHVWeightMeasurement alloc] initWithPounds:pounds];
    MHVCHECK_NOTNULL(m_value);
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(m_when);
    
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

-(NSString *)stringInPounds
{
    return [self stringInPoundsWithFormat:@"%.2f"];
}

-(NSString *)stringInKg
{
    return [self stringInKgWithFormat:@"%.3f"];  // 3rd place precision to support Grams
}

-(NSString *)stringInPoundsWithFormat:(NSString *)format
{
    return (m_value) ? [m_value stringInPounds:format] : c_emptyString;
}

-(NSString *)stringInKgWithFormat:(NSString *)format
{
    return (m_value) ? [m_value stringInKg:format] : c_emptyString;
}

-(NSString *)toString
{
    return (m_value) ? [m_value toString] : c_emptyString;
}

-(NSString *)description
{
    return [self toString];
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_when, MHVClientError_InvalidWeight);
    MHVVALIDATE(m_value, MHVClientError_InvalidWeight);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_value content:m_value];
}

-(void) deserialize:(XReader *)reader
{
    m_when = [reader readElementWithXmlName:x_element_when asClass:[MHVDateTime class]];
    m_value = [reader readElementWithXmlName:x_element_value asClass:[MHVWeightMeasurement class]];
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
    return [[MHVItem alloc] initWithType:[MHVWeight typeID]];
}

+(MHVItem *)newItemWithKg:(double)kg andDate:(NSDate *)date
{
    MHVWeight* weight = [[MHVWeight alloc] initWithKg:kg andDate:date];
    MHVCHECK_NOTNULL(weight);
    
    MHVItem* item = [[MHVItem alloc] initWithTypedData:weight];
    
    return item;
    
LError:
    return nil;
}

+(MHVItem *)newItemWithPounds:(double)pounds andDate:(NSDate *)date
{
    MHVWeight* weight = [[MHVWeight alloc] initWithPounds:pounds andDate:date];
    MHVCHECK_NOTNULL(weight);
    
    MHVItem* item = [[MHVItem alloc] initWithTypedData:weight];
    
    return item;
    
LError:
    return nil;
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Weight", @"Weight Type Name");
}

@end
