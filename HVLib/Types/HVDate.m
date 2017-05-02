//
//  HVDate.m
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
#import "HVDate.h"

static const xmlChar* x_element_year  = XMLSTRINGCONST("y");
static const xmlChar* x_element_month = XMLSTRINGCONST("m");
static const xmlChar* x_element_day   = XMLSTRINGCONST("d");

@implementation HVDate

-(int) year
{
    return (m_year) ? m_year.value : -1;
}

-(void) setYear:(int)year
{
    if (year >= 0)
    {
        HVENSURE(m_year, HVYear);
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
        HVENSURE(m_month, HVMonth);
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
        HVENSURE(m_day, HVDay);
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
    HVCHECK_NOTNULL(date);
    
    [self initWithComponents:[NSCalendar componentsFromDate:date]];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    return [self initWithYear:[components year] month:[components month] day:[components day]];
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithYear:(NSInteger)yearValue month:(NSInteger)monthValue day:(NSInteger)dayValue
{
    self = [super init];
    
    HVCHECK_SELF;
    
    if (yearValue != NSDateComponentUndefined)
    {
        m_year = [[HVYear alloc] initWith:(int)yearValue];
    }
    if (monthValue != NSDateComponentUndefined)
    {
        m_month = [[HVMonth alloc] initWith:(int)monthValue];
    }
    if (dayValue != NSDateComponentUndefined)
    {
        m_day = [[HVDay alloc] initWith:(int)dayValue];
    }
    
    HVCHECK_TRUE(m_year && m_month && m_day);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_year release];
    [m_month release];
    [m_day release];
    [super dealloc];
}

-(BOOL)setWithDate:(NSDate *)date
{
    return [self setWithComponents:[NSCalendar componentsFromDate:date]];
}

-(BOOL)setWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    m_year = nil;
    m_month = nil;
    m_day = nil;
    
    m_year = [[HVYear alloc] initWith:(int)components.year];
    m_month = [[HVMonth alloc] initWith:(int)components.month];
    m_day = [[HVDay alloc] initWith:(int)components.day];
    
    HVCHECK_TRUE(m_year && m_month && m_day);
    
    return TRUE;
    
LError:
    return FALSE;
}

+(HVDate *)fromDate:(NSDate *)date
{
    return [[[HVDate alloc] initWithDate:date] autorelease];
}

+(HVDate *)fromYear:(int)year month:(int)month day:(int)day
{
    return [[[HVDate alloc] initWithYear:year month:month day:day] autorelease];
}

+(HVDate *)now
{
    return [[[HVDate alloc] initNow] autorelease];
}

-(NSDateComponents *) toComponents
{
    NSDateComponents *components = [[NSCalendar newComponents] autorelease];
    HVCHECK_NOTNULL(components);
    
    HVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
    
LError:
    return nil;
}

-(NSDateComponents *)toComponentsForCalendar:(NSCalendar *)calendar
{
    NSDateComponents *components = [calendar componentsForCalendar];
    HVCHECK_NOTNULL(components);
    
    HVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
    
LError:
    return nil;
}

-(BOOL) getComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
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
    HVCHECK_NOTNULL(calendar);
    
    NSDate *date = [self toDateForCalendar:calendar];
    [calendar release];
    
    return date;
    
LError:
    return nil;
}

-(NSDate *)toDateForCalendar:(NSCalendar *)calendar
{
    if (calendar)
    {
        NSDateComponents *components = [NSDateComponents new];
        HVCHECK_NOTNULL(components);
        
        HVCHECK_SUCCESS([self getComponents:components]);
        
        NSDate *date = [calendar dateFromComponents:components];
        [components release];
        
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

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_year, HVClientError_InvalidDate);
    HVVALIDATE(m_month, HVClientError_InvalidDate);
    HVVALIDATE(m_day, HVClientError_InvalidDate);
    
    HVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *) writer
{
    [writer writeElementXmlName:x_element_year content:m_year];
    [writer writeElementXmlName:x_element_month content:m_month];
    [writer writeElementXmlName:x_element_day content:m_day];
}

-(void) deserialize:(XReader *)reader
{
    m_year = [[reader readElementWithXmlName:x_element_year asClass:[HVYear class]] retain];
    m_month = [[reader readElementWithXmlName:x_element_month asClass:[HVMonth class]] retain];
    m_day = [[reader readElementWithXmlName:x_element_day asClass:[HVDay class]] retain];
}

@end

