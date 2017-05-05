//
//  MHVTime.h
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

#import <Foundation/Foundation.h>
#import "MHVType.h"
#import "MHVHour.h"
#import "MHVMinute.h"
#import "MHVSecond.h"
#import "MHVMillisecond.h"

@interface MHVTime : MHVType
{
@private
    MHVHour *m_hours;
    MHVMinute *m_minutes;
    MHVSecond *m_seconds;
    MHVMillisecond *m_milliseconds;
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

+(MHVTime *) fromHour:(int) hour andMinute:(int)minute;

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

@interface MHVTimeCollection : MHVCollection

-(MHVTime *) itemAtIndex:(NSUInteger) index;

@end