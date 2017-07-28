//
// MHVDateTimeDurationTests
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


#import <XCTest/XCTest.h>
#import "MHVDateTimeDuration.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVDateTimeDurationTests)

describe(@"MHVDateTimeDuration", ^
         {
             let(testDate, ^{
                 NSDateComponents *dateComponents = [NSDateComponents new];
                 
                 dateComponents.year = 2017;
                 dateComponents.month = 7;
                 dateComponents.day = 28;
                 dateComponents.hour = 1;
                 dateComponents.minute = 10;
                 dateComponents.second = 30;
                 
                 return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
             });
             
             context(@"Converting to duration in minutes", ^
                     {
                         it(@"should return correct value", ^
                            {
                                MHVDateTimeDuration *dt = [[MHVDateTimeDuration alloc] initWithDate:testDate];
                                
                                [[theValue(dt.durationInMinutes) should] equal:theValue(70)];
                            });
                     });
             context(@"Converting to duration in seconds", ^
                     {
                         it(@"should return correct value", ^
                            {
                                MHVDateTimeDuration *dt = [[MHVDateTimeDuration alloc] initWithDate:testDate];
                                
                                [[theValue(dt.durationInSeconds) should] equal:theValue(4230)];
                            });
                     });
         });

SPEC_END
