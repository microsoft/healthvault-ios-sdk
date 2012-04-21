//
//  HVDateExtensions.m
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
#import "HVDateExtensions.h"
#import "HVValidator.h"


@implementation NSDate (HVDateExtensions)

-(NSString *)toString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init]; 
    HVCHECK_NOTNULL(formatter);
    
    NSString* string = [formatter stringFromDate:self];
    
    [formatter release];
    
    return string;
    
LError:
    return nil;
}

-(NSString*) toStringWithFormat:(id)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init]; 
    HVCHECK_NOTNULL(formatter);
    
    NSString* string = [formatter dateToString:self withFormat:format];
    [formatter release];
    
    return string;
    
LError:
    return nil;
}

-(NSString *)toZuluString
{
    NSDateFormatter* formatter = [NSDateFormatter newZuluFormatter];
    HVCHECK_NOTNULL(formatter);
    
    NSString* string = [formatter dateTimeToString:self];
    
    [formatter release];
    
    return string;

LError:
    return nil;
}

-(NSComparisonResult) compareDescending:(NSDate *)other
{
    return -([self compare:other]);
}

+(NSDate *)fromHour:(int)hour
{
    return [NSDate fromHour:hour andMinute:0];
}

+(NSDate *)fromHour:(int)hour andMinute:(int)minute
{
    NSDateComponents *components = [NSCalendar newComponents];
    HVCHECK_NOTNULL(components);
    
    components.hour = hour;
    components.minute = minute;
    
    NSDate* newDate = [components date];
    [components release];
    
    return newDate;
    
LError:
    [components release];
    return nil;
}

@end


const NSUInteger NSAllCalendarUnits =   NSDayCalendarUnit       | 
                                        NSMonthCalendarUnit     | 
                                        NSYearCalendarUnit      | 
                                        NSHourCalendarUnit      | 
                                        NSMinuteCalendarUnit    | 
                                        NSSecondCalendarUnit;

@implementation NSCalendar (HVCalendarExtensions)

-(NSDateComponents *)getComponentsFor:(NSDate *)date
{
    return [self components: NSAllCalendarUnits fromDate: date];
}

+(NSDateComponents *) componentsFromDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    NSCalendar* calendar = [NSCalendar newGregorian];
    HVCHECK_NOTNULL(calendar);
    
    NSDateComponents* components = [calendar getComponentsFor:date];
    [calendar release];
    
    return components;
    
LError:
    return nil;
    
}

+(NSDateComponents *) newComponents
{
    NSCalendar* calendar = [NSCalendar newGregorian];
    HVCHECK_NOTNULL(calendar);
    
    NSDateComponents* components = [[NSDateComponents alloc] init];
    HVCHECK_NOTNULL(components);
    
    [components setCalendar:calendar];
    [calendar release];
    
    return components;
    
LError:
    [calendar release];
    return nil;
}

+(NSDateComponents *) newUtcComponents
{
    NSCalendar* calendar = [NSCalendar newGregorianUtc];
    HVCHECK_NOTNULL(calendar);
    
    NSDateComponents* components = [[NSDateComponents alloc] init];
    HVCHECK_NOTNULL(components);
    
    [components setCalendar:calendar];
    [calendar release];
    
    return components;

LError:
    [calendar release];
    return nil;
}

+(NSDateComponents *) utcComponentsFromDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    NSCalendar* calendar = [NSCalendar newGregorianUtc];
    HVCHECK_NOTNULL(calendar);
    
    NSDateComponents* components = [calendar getComponentsFor:date];
    [calendar release];
    
    return components;

LError:
    return nil;
}

+(NSCalendar *) newGregorian
{
    return [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
}

+(NSCalendar *) newGregorianUtc
{
    NSCalendar *calendar = [NSCalendar newGregorian];
    if (calendar)
    {
        [calendar setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"UTC"]];
    }
    return calendar;
}

@end

@implementation NSDateFormatter (HVDateFormatterExtensions)

+(NSDateFormatter *) newUtcFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (formatter)
    {
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    
    return formatter;
}

+(NSDateFormatter *) newZuluFormatter
{
    NSDateFormatter *formatter = [NSDateFormatter newUtcFormatter];
    if (formatter)
    {
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"]; // Zulu time format
    }
    
    return formatter;
}

-(NSString *) dateToString:(NSDate *)date withFormat:(NSString *)format
{
    NSString* currentFormat = [self dateFormat];
    
    [self setDateFormat:format];
    NSString* dateString = [self stringFromDate:date];
    
    [self setDateFormat:currentFormat];
    
    return dateString;  
}

-(NSString *)dateToString:(NSDate *)date withStyle:(NSDateFormatterStyle)style
{
    NSDateFormatterStyle currentDateStyle = [self dateStyle];
    
    [self setDateStyle:style];
    NSString* dateString = [self stringFromDate:date];   
    
    [self setDateStyle:currentDateStyle];
    
    return dateString;  
}

-(NSString *)dateTimeToString:(NSDate *)date withStyle:(NSDateFormatterStyle)style
{
    NSDateFormatterStyle currentDateStyle = [self dateStyle];
    NSDateFormatterStyle currentTimeStyle = [self timeStyle];
    
    [self setDateStyle:style];
    [self setTimeStyle:style];
    
    NSString* dateString = [self stringFromDate:date];   
    
    [self setDateStyle:currentDateStyle];
    [self setTimeStyle:currentTimeStyle];
    
    return dateString;  

}

-(NSString *)dateTimeToString:(NSDate *)date
{
    return [self dateToString:date withFormat:@"MM/dd/YY hh:mm aaa"];
}

@end