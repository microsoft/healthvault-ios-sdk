//
//  HVTime.h
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

-(id) initWithHour:(int) hour minute:(int) minute second:(int) second;
-(id) initWithDate:(NSDate *) date;
-(id) initwithComponents:(NSDateComponents *) components;

-(NSDateComponents *) toComponents;
-(BOOL) getComponents:(NSDateComponents *) components;

@end

@interface HVTimeCollection : HVCollection

@end
