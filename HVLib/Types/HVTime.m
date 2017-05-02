//
//  HVTime.m
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
#import "HVTime.h"

static const xmlChar* x_element_hour = XMLSTRINGCONST("h");
static const xmlChar* x_element_minute = XMLSTRINGCONST("m");
static const xmlChar* x_element_second = XMLSTRINGCONST("s");
static const xmlChar* x_element_millis = XMLSTRINGCONST("f");

@implementation HVTime

-(int) hour
{
    return (m_hours ? m_hours.value : -1);
}

-(void) setHour:(int) hours
{
    if (hours >= 0)
    {
        HVENSURE(m_hours, HVHour);
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
        HVENSURE(m_minutes, HVMinute);
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
        HVENSURE(m_seconds, HVSecond);
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
        HVENSURE(m_milliseconds, HVMillisecond);
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
    HVCHECK_SELF;
    
    if (hour != NSUndefinedDateComponent)
    {
        m_hours = [[HVHour alloc] initWith:(int)hour];
    }
    HVCHECK_NOTNULL(m_hours);
    
    if (minute != NSUndefinedDateComponent)
    {
        m_minutes = [[HVMinute alloc] initWith:(int)minute];
    }
    HVCHECK_NOTNULL(m_minutes);
    
    if (second >= 0 && second != NSUndefinedDateComponent)
    {
        m_seconds = [[HVSecond alloc] initWith:(int)second];
        HVCHECK_NOTNULL(m_seconds);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    return [self initWithHour:[components hour] minute:[components minute] second:[components second]];
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    return [self initWithComponents:[NSCalendar componentsFromDate:date]];
    
LError:
    HVALLOC_FAIL;
}

+(HVTime *)fromHour:(int)hour andMinute:(int)minute
{
    return [[[HVTime alloc] initWithHour:hour minute:minute] autorelease];
}

-(void) dealloc
{
    [m_hours release];
    [m_minutes release];
    [m_seconds release];
    [m_milliseconds release];
    [super dealloc];
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

-(BOOL) getComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
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
    HVCHECK_NOTNULL(components);
    
    HVCHECK_SUCCESS([self getComponents:components]);
    
    NSDate* newDate = [components date];
    [components release];
    
    return newDate;
}

-(BOOL)setWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    self.hour = (int)[components hour];
    self.minute = (int)[components minute];
    self.second = (int)[components second];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)setWithDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
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

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_hours, HVClientError_InvalidTime);
    HVVALIDATE(m_minutes, HVClientError_InvalidTime);
    HVVALIDATE_OPTIONAL(m_seconds);
    HVVALIDATE_OPTIONAL(m_milliseconds);
    
    HVVALIDATE_SUCCESS;
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
    m_hours = [[reader readElementWithXmlName:x_element_hour asClass:[HVHour class]] retain];
    m_minutes = [[reader readElementWithXmlName:x_element_minute asClass:[HVMinute class]] retain];
    m_seconds = [[reader readElementWithXmlName:x_element_second asClass:[HVSecond class]] retain];
    m_milliseconds = [[reader readElementWithXmlName:x_element_millis asClass:[HVMillisecond class]] retain];
}

@end

@implementation HVTimeCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVTime class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVTime *)itemAtIndex:(NSUInteger)index
{
    return (HVTime *) [self objectAtIndex:index];
}

@end
