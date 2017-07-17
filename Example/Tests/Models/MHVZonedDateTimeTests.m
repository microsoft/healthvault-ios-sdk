//
// MHVZonedDateTimeTests
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
#import "Kiwi.h"
#import "MHVZonedDateTime.h"

SPEC_BEGIN(MHVZonedDateTimeTests)

describe(@"MHVZonedDateTime", ^
         {
             context(@"Custom TimeZone", ^
                     {
                        it(@"should keep times using a custom time zone", ^
                           {
                               MHVZonedDateTime* dt = [[MHVZonedDateTime alloc] initWithObject:@"2017-07-06T13:13:10+01 Europe/London" objectParameters:nil];

                               [[dt.description should] equal:@"2017-07-06T13:13:10+01 Europe/London"];
                           });
                     });

             context(@"45 Minute Offset", ^
                     {
                         it(@"should handle partial hour offsets", ^
                            {
                                MHVZonedDateTime* dt = [[MHVZonedDateTime alloc] initWithObject:@"2017-07-06T13:13:10+0545 Asia/Kathmandu" objectParameters:nil];

                                [[dt.description should] equal:@"2017-07-06T13:13:10+0545 Asia/Kathmandu"];
                            });
                     });

             context(@"GMT", ^
                     {
                         it(@"should handle GMT formats", ^
                            {
                                MHVZonedDateTime* dt = [[MHVZonedDateTime alloc] initWithObject:@"2017-07-06T13:13:10Z GMT" objectParameters:nil];

                                [[dt.description should] equal:@"2017-07-06T13:13:10Z GMT"];
                            });
                     });

             context(@"Default Constructor", ^
                     {
                         it(@"should use device time zone", ^
                            {
                                NSDate* now = [NSDate date];
                                MHVZonedDateTime* dt = [[MHVZonedDateTime alloc] initWithDate:now];
                                NSTimeZone* deviceZone = [NSTimeZone systemTimeZone];

                                [[theValue([dt.description containsString:deviceZone.name]) should] beYes];
                                [[dt.date.description should] equal:now.description];
                            });
                     });
         });

SPEC_END
