//
//  HVDateExtensions.h
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

#import <Foundation/Foundation.h>

const NSUInteger NSAllCalendarUnits;

@interface NSDate (HVDateExtensions)

-(NSString*) toString;
-(NSString*) toStringWithFormat:(NSString*) format;
-(NSString *) toZuluString;

-(NSComparisonResult) compareDescending:(NSDate*) other;

+(NSDate *) fromHour:(int) hour;
+(NSDate *) fromHour:(int)hour andMinute:(int) minute;

@end


@interface NSCalendar (HVCalendarExtensions)

-(NSDateComponents *) getComponentsFor:(NSDate *) date;

+(NSDateComponents *) componentsFromDate:(NSDate *) date;
+(NSDateComponents *) newComponents;

+(NSDateComponents *) newUtcComponents;
+(NSDateComponents *) utcComponentsFromDate:(NSDate *)date;

+(NSCalendar *) newGregorian;
+(NSCalendar *) newGregorianUtc;

@end

@interface NSDateFormatter (HVDateFormatterExtensions) 

+(NSDateFormatter *) newUtcFormatter;
+(NSDateFormatter *) newZuluFormatter;

-(NSString *) dateToString:(NSDate*) date withFormat:(NSString*) format;
-(NSString *) dateToString:(NSDate*) date withStyle:(NSDateFormatterStyle) style;
-(NSString *) dateTimeToString:(NSDate*) date withStyle:(NSDateFormatterStyle) style;
-(NSString *) dateTimeToString:(NSDate *)date;

@end