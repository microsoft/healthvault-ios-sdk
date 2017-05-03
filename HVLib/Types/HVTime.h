//
//  HVTime.h
//  HVLib
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

#import <Foundation/Foundation.h>
#import "HVType.h"
#import "HVHour.h"
#import "HVMinute.h"
#import "HVSecond.h"
#import "HVMillisecond.h"

@interface HVTime : HVType
{
@private
    HVHour *m_hours;
    HVMinute *m_minutes;
    HVSecond *m_seconds;
    HVMillisecond *m_milliseconds;
}

//-------------------------
//
// Data
//
//-------------------------
//
// Required
//
@property (readwrite, nonatomic) int hour;              
@property (readwrite, nonatomic) int minute; 
//
// Optional
//
@property (readwrite, nonatomic) int second; 
@property (readwrite, nonatomic) int millisecond;
@property (readonly, nonatomic) BOOL hasSecond;
@property (readonly, nonatomic) BOOL hasMillisecond;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithHour:(int) hour minute:(int) minute;
-(id) initWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
-(id) initWithDate:(NSDate *) date;
-(id) initWithComponents:(NSDateComponents *) components;

+(HVTime *) fromHour:(int) hour andMinute:(int)minute;

//-------------------------
//
// Methods
//
//-------------------------
-(NSDateComponents *) toComponents;
-(BOOL) getComponents:(NSDateComponents *) components;

-(BOOL) setWithComponents:(NSDateComponents *) components;
-(BOOL) setWithDate:(NSDate *) date;

-(NSDate *) toDate;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

@end

@interface HVTimeCollection : HVCollection

-(HVTime *) itemAtIndex:(NSUInteger) index;

@end
