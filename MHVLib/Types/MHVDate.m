//
//  MHVDate.m
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
#import "MHVDate.h"

static const xmlChar* x_element_year  = XMLSTRINGCONST("y");
static const xmlChar* x_element_month = XMLSTRINGCONST("m");
static const xmlChar* x_element_day   = XMLSTRINGCONST("d");

@implementation MHVDate

-(int) year
{
    return (m_year) ? m_year.value : -1;
}

-(void) setYear:(int)year
{
    if (year >= 0)
    {
        MHVENSURE(m_year, MHVYear);
        m_year.value = year;
    }
    else
    {
        m_year = nil;
    }
}

-(int) month
{
    return (m_month) ? m_month.value : -1;
}

-(void) setMonth:(int) month
{
    if (month >= 0)
    {
        MHVENSURE(m_month, MHVMonth);
        m_month.value = month;
    }
    else
    {
        m_month = nil;
    }
}

-(int) day
{
    return (m_day) ? m_day.value : -1;
}

-(void) setDay:(int)day
{
    if (day >= 0)
    {
        MHVENSURE(m_day, MHVDay);
        m_day.value = day;
    }
    else
    {
        m_day = nil;
    }
}

-(id) initNow
{
    return [self initWithDate:[NSDate date]];
}

-(id) initWithDate:(NSDate *) date
{
    MHVCHECK_NOTNULL(date);
    
    if (!(self = [self initWithComponents:[NSCalendar componentsFromDate:date]])) return nil;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    return [self initWithYear:[components year] month:[components month] day:[components day]];
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithYear:(NSInteger)yearValue month:(NSInteger)monthValue day:(NSInteger)dayValue
{
    self = [super init];
    
    MHVCHECK_SELF;
    
    if (yearValue != NSDateComponentUndefined)
    {
        m_year = [[MHVYear alloc] initWith:(int)yearValue];
    }
    if (monthValue != NSDateComponentUndefined)
    {
        m_month = [[MHVMonth alloc] initWith:(int)monthValue];
    }
    if (dayValue != NSDateComponentUndefined)
    {
        m_day = [[MHVDay alloc] initWith:(int)dayValue];
    }
    
    MHVCHECK_TRUE(m_year && m_month && m_day);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL)setWithDate:(NSDate *)date
{
    return [self setWithComponents:[NSCalendar componentsFromDate:date]];
}

-(BOOL)setWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    m_year = nil;
    m_month = nil;
    m_day = nil;
    
    m_year = [[MHVYear alloc] initWith:(int)components.year];
    m_month = [[MHVMonth alloc] initWith:(int)components.month];
    m_day = [[MHVDay alloc] initWith:(int)components.day];
    
    MHVCHECK_TRUE(m_year && m_month && m_day);
    
    return TRUE;
    
LError:
    return FALSE;
}

+(MHVDate *)fromDate:(NSDate *)date
{
    return [[MHVDate alloc] initWithDate:date];
}

+(MHVDate *)fromYear:(int)year month:(int)month day:(int)day
{
    return [[MHVDate alloc] initWithYear:year month:month day:day];
}

+(MHVDate *)now
{
    return [[MHVDate alloc] initNow];
}

-(NSDateComponents *) toComponents
{
    NSDateComponents *components = [NSCalendar newComponents];
    MHVCHECK_NOTNULL(components);
    
    MHVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
    
LError:
    return nil;
}

-(NSDateComponents *)toComponentsForCalendar:(NSCalendar *)calendar
{
    NSDateComponents *components = [calendar componentsForCalendar];
    MHVCHECK_NOTNULL(components);
    
    MHVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
    
LError:
    return nil;
}

-(BOOL) getComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    if (m_year)
    {
        [components setYear:self.year];
    }
    if (m_month)
    {
        [components setMonth:self.month];
    }
    if (m_day)
    {
        [components setDay:self.day];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSDate *) toDate
{
    NSCalendar* calendar = [NSCalendar newGregorian];
    MHVCHECK_NOTNULL(calendar);
    
    NSDate *date = [self toDateForCalendar:calendar];
    
    return date;
    
LError:
    return nil;
}

-(NSDate *)toDateForCalendar:(NSCalendar *)calendar
{
    if (calendar)
    {
        NSDateComponents *components = [NSDateComponents new];
        MHVCHECK_NOTNULL(components);
        
        MHVCHECK_SUCCESS([self getComponents:components]);
        
        NSDate *date = [calendar dateFromComponents:components];
        
        return date;
    }
    
    return nil;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"MM/dd/yy"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDate* date = [self toDate];
    return [date toStringWithFormat:format];
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_year, MHVClientError_InvalidDate);
    MHVVALIDATE(m_month, MHVClientError_InvalidDate);
    MHVVALIDATE(m_day, MHVClientError_InvalidDate);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *) writer
{
    [writer writeElementXmlName:x_element_year content:m_year];
    [writer writeElementXmlName:x_element_month content:m_month];
    [writer writeElementXmlName:x_element_day content:m_day];
}

-(void) deserialize:(XReader *)reader
{
    m_year = [reader readElementWithXmlName:x_element_year asClass:[MHVYear class]];
    m_month = [reader readElementWithXmlName:x_element_month asClass:[MHVMonth class]];
    m_day = [reader readElementWithXmlName:x_element_day asClass:[MHVDay class]];
}

@end

