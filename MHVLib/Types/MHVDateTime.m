//
//  DateTime.m
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
#import "MHVDateTime.h"

static const xmlChar* x_element_date = XMLSTRINGCONST("date");
static const xmlChar* x_element_time = XMLSTRINGCONST("time");
static const xmlChar* x_element_timeZone = XMLSTRINGCONST("tz");

@implementation MHVDateTime

@synthesize date = m_date;
@synthesize time = m_time;
@synthesize timeZone = m_timeZone;

-(BOOL) hasTime
{
    return (m_time != nil);
}

-(BOOL) hasTimeZone
{
    return (m_timeZone != nil);
}

-(id) initNow
{
    return [self initWithDate:[NSDate date]];
}

-(id) initWithDate:(NSDate *) dateValue
{
    MHVCHECK_NOTNULL(dateValue);
    
    NSDateComponents *components = [NSCalendar componentsFromDate:dateValue];
    MHVCHECK_NOTNULL(components);
    
    return [self initWithComponents:components];
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_date = [[MHVDate alloc] initWithComponents:components];
    m_time = [[MHVTime alloc] initWithComponents:components];
    
    MHVCHECK_TRUE(m_date && m_time);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

+(MHVDateTime *)now
{
    return [[MHVDateTime alloc] initNow];
}

+(MHVDateTime *)fromDate:(NSDate *)date
{
    return [[MHVDateTime alloc] initWithDate:date];
}

-(BOOL) setWithDate:(NSDate *) dateValue
{
    MHVCHECK_NOTNULL(dateValue);
    
    NSDateComponents *components = [NSCalendar componentsFromDate:dateValue];
    MHVCHECK_NOTNULL(components);
    
    return [self setWithComponents:components];

LError:
    return FALSE;
}

-(BOOL) setWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    m_date = nil;
    m_time = nil;
    
    m_date = [[MHVDate alloc] initWithComponents:components];
    m_time = [[MHVTime alloc] initWithComponents:components];
    
    MHVCHECK_TRUE(m_date && m_time);
    
    return TRUE;
    
LError:
    return FALSE;
}


-(NSString *)description
{
    return [self toString];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"MM/dd/yy hh:mm aaa"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDate *date = [self toDate];
    return [date toStringWithFormat:format];
}

-(NSDateComponents *) toComponents
{
    NSDateComponents *components = [NSCalendar newComponents];
    MHVCHECK_SUCCESS([self getComponents:components]);
    
    return components;
}

-(BOOL) getComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    MHVCHECK_NOTNULL(m_date);
    
    [m_date getComponents:components];
    if (m_time)
    {
        [m_time getComponents:components];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSDate *)toDate
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
        NSDateComponents *components = [[NSDateComponents alloc] init];
        MHVCHECK_NOTNULL(components);
        
        MHVCHECK_SUCCESS([self getComponents:components]);
        
        NSDate *date = [calendar dateFromComponents:components];
        
        return date;
        
    LError:
        return nil;
        
    }
    
    return nil;    
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_date, MHVClientError_InvalidDateTime);
    MHVVALIDATE_OPTIONAL(m_time);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_date content:m_date];
    [writer writeElementXmlName:x_element_time content:m_time];
    [writer writeElementXmlName:x_element_timeZone content:m_timeZone];
}

-(void) deserialize:(XReader *)reader
{
    m_date = [reader readElementWithXmlName:x_element_date asClass:[MHVDate class]];
    m_time = [reader readElementWithXmlName:x_element_time asClass:[MHVTime class]];
    m_timeZone = [reader readElementWithXmlName:x_element_timeZone asClass:[MHVCodableValue class]];
}

@end
