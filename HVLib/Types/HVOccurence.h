//
//  HVOccurence.h
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
#import "HVBaseTypes.h"
#import "HVTime.h"

@interface HVOccurence : HVType
{
@private
    HVTime* m_when;
    HVNonNegativeInt* m_minutes;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property(readwrite, nonatomic, retain) HVTime* when;
//
// (Required)
//
@property(readwrite, nonatomic, retain) HVNonNegativeInt* durationMinutes;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initForDuration:(int)minutes startingAt:(HVTime *) time;
-(id) initForDuration:(int)minutes startingAtHour:(int) hour andMinute:(int) minute;

+(HVOccurence *) forDuration:(int) minutes atHour:(int) hour andMinute:(int) minute;

@end

@interface HVOccurenceCollection : HVCollection

-(HVOccurence *) itemAtIndex:(NSUInteger) index;

@end
