//
//  MHVTime.m
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
#import "MHVTime.h"

static const xmlChar* x_element_hour = XMLSTRINGCONST("h");
static const xmlChar* x_element_minute = XMLSTRINGCONST("m");
static const xmlChar* x_element_second = XMLSTRINGCONST("s");
static const xmlChar* x_element_millis = XMLSTRINGCONST("f");

@implementation MHVTime

-(int) hour
{
    return (m_hours ? m_hours.value : -1);
}

-(void) setHour:(int) hours
{
    if (hours >= 0)
    {
        MHVENSURE(m_hours, MHVHour);
        m_hours.value = hours;
    }
    else
    {
        m_hours = nil;
    }
}

-(int) minute
{
    return (m_minutes ? m_minutes.value : -1);
}

-(void) setMinute:(int)minutes
{
    if (minutes >= 0)
    {
        MHVENSURE(m_minutes, MHVMinute);
        m_minutes.value = minutes;
    }
    else
    {
        m_minutes = nil;
    }
}

-(BOOL)hasSecond
{
    return (m_seconds != nil);
}

-(int) second
{
    return (m_seconds ? m_seconds.value : -1);
}

-(void) setSecond:(int)seconds
{
    if (seconds >= 0)
    {
        MHVENSURE(m_seconds, MHVSecond);
        m_seconds.value = seconds;
    }
    else
    {
        m_seconds = nil;
    }
}

-(BOOL)hasMillisecond
{
    return (m_seconds != nil);
}

-(int) millisecond
{
    return (m_milliseconds ? m_milliseconds.value : -1);
}

-(void) setMillisecond:(int)milliseconds
{
    if (milliseconds >= 0)
    {
        MHVENSURE(m_milliseconds, MHVMillisecond);
        m_milliseconds.value = milliseconds;
        
    }
    else
    {
        m_milliseconds = nil;
    }
}

+(void)initialize
{
}

-(id)initWithHour:(int)hour minute:(int)minute
{
    return [self initWithHour:hour minute:minute second:-1];
}

-(id) initWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    self = [super init];
    MHVCHECK_SELF;
    
    if (hour != NSDateComponentUndefined)
    {
        m_hours = [[MHVHour alloc] initWith:(int)hour];
    }
    MHVCHECK_NOTNULL(m_hours);
    
    if (minute != NSDateComponentUndefined)
    {
        m_minutes = [[MHVMinute alloc] initWith:(int)minute];
    }
    MHVCHECK_NOTNULL(m_minutes);
    
    if (second >= 0 && second != NSDateComponentUndefined)
    {
        m_seconds = [[MHVSecond alloc] initWith:(int)second];
        MHVCHECK_NOTNULL(m_seconds);
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    return [self initWithHour:[components hour] minute:[components minute] second:[components second]];
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    return [self initWithComponents:[NSCalendar componentsFromDate:date]];
    
LError:
    MHVALLOC_FAIL;
}

+(MHVTime *)fromHour:(int)hour andMinute:(int)minute
{
    return [[MHVTime alloc] initWithHour:hour minute:minute];
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

-(BOOL) getComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    if (m_hours)
    {
        [components setHour:self.hour];
    }
    if (m_minutes)
    {
        [components setMinute:self.minute];
    }
    if (m_seconds)
    {
        [components setSecond:self.second];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSDate *) toDate
{
    NSDateComponents *components = [NSCalendar newComponents];
    MHVCHECK_NOTNULL(components);
    
    MHVCHECK_SUCCESS([self getComponents:components]);
    
    NSDate* newDate = [components date];
    
    return newDate;
}

-(BOOL)setWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);
    
    self.hour = (int)[components hour];
    self.minute = (int)[components minute];
    self.second = (int)[components second];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)setWithDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    return [self setWithComponents:[NSCalendar componentsFromDate:date]];
    
LError:
    return FALSE;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"hh:mm aaa"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDate *date = [self toDate];
    return [date toStringWithFormat:format];
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_hours, MHVClientError_InvalidTime);
    MHVVALIDATE(m_minutes, MHVClientError_InvalidTime);
    MHVVALIDATE_OPTIONAL(m_seconds);
    MHVVALIDATE_OPTIONAL(m_milliseconds);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_hour content:m_hours];
    [writer writeElementXmlName:x_element_minute content:m_minutes];
    [writer writeElementXmlName:x_element_second content:m_seconds];
    [writer writeElementXmlName:x_element_millis content:m_milliseconds];
}

-(void) deserialize:(XReader *)reader
{
    m_hours = [reader readElementWithXmlName:x_element_hour asClass:[MHVHour class]];
    m_minutes = [reader readElementWithXmlName:x_element_minute asClass:[MHVMinute class]];
    m_seconds = [reader readElementWithXmlName:x_element_second asClass:[MHVSecond class]];
    m_milliseconds = [reader readElementWithXmlName:x_element_millis asClass:[MHVMillisecond class]];
}

@end

@implementation MHVTimeCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVTime class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVTime *)itemAtIndex:(NSUInteger)index
{
    return (MHVTime *) [self objectAtIndex:index];
}

@end
