//
//  DateTime.h
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
#import "HVType.h"
#import "HVDate.h"
#import "HVTime.h"
#import "HVCodableValue.h"

@interface HVDateTime : HVType
{
@private
    HVDate* m_date;
    HVTime* m_time;
    HVCodableValue* m_timeZone;
}

//-------------------------
//
// Data
//
//-------------------------
//
// Reqired
//
@property (readwrite, nonatomic, retain) HVDate* date;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVTime* time;
@property (readwrite, nonatomic, retain) HVCodableValue *timeZone;

//
// Convenience
//
@property (readonly, nonatomic) BOOL hasTime;
@property (readonly, nonatomic) BOOL hasTimeZone;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithDate:(NSDate *) dateValue;
-(id) initWithComponents:(NSDateComponents *) components;
-(id) initNow;

+(HVDateTime *) now;
+(HVDateTime *) fromDate:(NSDate *) date;

//-------------------------
//
// Methods
//
//-------------------------
-(NSDateComponents *) toComponents;
-(BOOL) getComponents:(NSDateComponents *) components;
-(NSDate *) toDate;
-(NSDate *) toDateForCalendar:(NSCalendar *) calendar;

-(BOOL) setWithDate:(NSDate *) dateValue;
-(BOOL) setWithComponents:(NSDateComponents *) components;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

@end
