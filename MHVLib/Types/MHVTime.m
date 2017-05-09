//
// MHVTime.m
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
#import "MHVTime.h"

static const xmlChar *x_element_hour = XMLSTRINGCONST("h");
static const xmlChar *x_element_minute = XMLSTRINGCONST("m");
static const xmlChar *x_element_second = XMLSTRINGCONST("s");
static const xmlChar *x_element_millis = XMLSTRINGCONST("f");

@interface MHVTime ()

@property (nonatomic, strong) MHVHour *hourValue;
@property (nonatomic, strong) MHVMinute *minuteValue;
@property (nonatomic, strong) MHVSecond *secondValue;
@property (nonatomic, strong) MHVMillisecond *millisecondValue;

@end

@implementation MHVTime

- (int)hour
{
    return self.hourValue ? self.hourValue.value : -1;
}

- (void)setHour:(int)hours
{
    if (hours >= 0)
    {
        MHVENSURE(self.hourValue, MHVHour);
        self.hourValue.value = hours;
    }
    else
    {
        self.hourValue = nil;
    }
}

- (int)minute
{
    return self.minuteValue ? self.minuteValue.value : -1;
}

- (void)setMinute:(int)minutes
{
    if (minutes >= 0)
    {
        MHVENSURE(self.minuteValue, MHVMinute);
        self.minuteValue.value = minutes;
    }
    else
    {
        self.minuteValue = nil;
    }
}

- (BOOL)hasSecond
{
    return self.secondValue != nil;
}

- (int)second
{
    return self.secondValue ? self.secondValue.value : -1;
}

- (void)setSecond:(int)seconds
{
    if (seconds >= 0)
    {
        MHVENSURE(self.secondValue, MHVSecond);
        self.secondValue.value = seconds;
    }
    else
    {
        self.secondValue = nil;
    }
}

- (BOOL)hasMillisecond
{
    return self.millisecondValue != nil;
}

- (int)millisecond
{
    return self.millisecondValue ? self.millisecondValue.value : -1;
}

- (void)setMillisecond:(int)milliseconds
{
    if (milliseconds >= 0)
    {
        MHVENSURE(self.millisecondValue, MHVMillisecond);
        self.millisecondValue.value = milliseconds;
    }
    else
    {
        self.millisecondValue = nil;
    }
}

- (instancetype)initWithHour:(int)hour minute:(int)minute
{
    return [self initWithHour:hour minute:minute second:-1];
}

- (instancetype)initWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    self = [super init];
    if (self)
    {
        if (hour != NSDateComponentUndefined)
        {
            _hourValue = [[MHVHour alloc] initWith:(int)hour];
        }

        MHVCHECK_NOTNULL(_hourValue);

        if (minute != NSDateComponentUndefined)
        {
            _minuteValue = [[MHVMinute alloc] initWith:(int)minute];
        }

        MHVCHECK_NOTNULL(_minuteValue);

        if (second >= 0 && second != NSDateComponentUndefined)
        {
            _secondValue = [[MHVSecond alloc] initWith:(int)second];
            MHVCHECK_NOTNULL(_secondValue);
        }
    }

    return self;
}

- (instancetype)initWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);

    return [self initWithHour:[components hour] minute:[components minute] second:[components second]];
}

- (instancetype)initWithDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);

    return [self initWithComponents:[NSCalendar componentsFromDate:date]];
}

+ (MHVTime *)fromHour:(int)hour andMinute:(int)minute
{
    return [[MHVTime alloc] initWithHour:hour minute:minute];
}

- (NSDateComponents *)toComponents
{
    NSDateComponents *components = [NSCalendar newComponents];

    MHVCHECK_NOTNULL(components);

    MHVCHECK_SUCCESS([self getComponents:components]);

    return components;
}

- (BOOL)getComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);

    if (self.hourValue)
    {
        [components setHour:self.hour];
    }

    if (self.minuteValue)
    {
        [components setMinute:self.minute];
    }

    if (self.secondValue)
    {
        [components setSecond:self.second];
    }

    return TRUE;
}

- (NSDate *)toDate
{
    NSDateComponents *components = [NSCalendar newComponents];

    MHVCHECK_NOTNULL(components);

    MHVCHECK_SUCCESS([self getComponents:components]);

    NSDate *newDate = [components date];

    return newDate;
}

- (BOOL)setWithComponents:(NSDateComponents *)components
{
    MHVCHECK_NOTNULL(components);

    self.hour = (int)[components hour];
    self.minute = (int)[components minute];
    self.second = (int)[components second];

    return TRUE;
}

- (BOOL)setWithDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);

    return [self setWithComponents:[NSCalendar componentsFromDate:date]];
}

- (NSString *)description
{
    return [self toString];
}

- (NSString *)toString
{
    return [self toStringWithFormat:@"hh:mm aaa"];
}

- (NSString *)toStringWithFormat:(NSString *)format
{
    NSDate *date = [self toDate];

    return [date toStringWithFormat:format];
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE(self.hourValue, MHVClientError_InvalidTime);
    MHVVALIDATE(self.minuteValue, MHVClientError_InvalidTime);
    MHVVALIDATE_OPTIONAL(self.secondValue);
    MHVVALIDATE_OPTIONAL(self.millisecondValue);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_hour content:self.hourValue];
    [writer writeElementXmlName:x_element_minute content:self.minuteValue];
    [writer writeElementXmlName:x_element_second content:self.secondValue];
    [writer writeElementXmlName:x_element_millis content:self.millisecondValue];
}

- (void)deserialize:(XReader *)reader
{
    self.hourValue = [reader readElementWithXmlName:x_element_hour asClass:[MHVHour class]];
    self.minuteValue = [reader readElementWithXmlName:x_element_minute asClass:[MHVMinute class]];
    self.secondValue = [reader readElementWithXmlName:x_element_second asClass:[MHVSecond class]];
    self.millisecondValue = [reader readElementWithXmlName:x_element_millis asClass:[MHVMillisecond class]];
}

@end

@implementation MHVTimeCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVTime class];
    }

    return self;
}

- (MHVTime *)itemAtIndex:(NSUInteger)index
{
    return (MHVTime *)[self objectAtIndex:index];
}

@end
