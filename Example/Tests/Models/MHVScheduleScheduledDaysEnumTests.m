//
// MHVScheduleScheduledDaysEnumTests.m
// healthvault-ios-sdk
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
#import "MHVSchedule.h"
#import "MHVScheduleScheduledDaysEnum+Utils.h"
#import "Kiwi.h"

SPEC_BEGIN(MHVScheduleScheduledDaysEnumTests)

describe(@"MHVScheduleScheduledDaysEnum", ^
         {
             context(@"isEqualToCalendarComponentsWeekday", ^
                     {
                         it(@"should match all days for MHVEveryday", ^
                            {
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:1]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:2]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:3]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:4]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:5]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:6]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVEveryday isEqualToCalendarComponentsWeekday:7]) should] beYes];
                            });

                         it(@"Enum values should be YES for matching weekdays", ^
                            {
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:1]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVMonday isEqualToCalendarComponentsWeekday:2]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVTuesday isEqualToCalendarComponentsWeekday:3]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVWednesday isEqualToCalendarComponentsWeekday:4]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVThursday isEqualToCalendarComponentsWeekday:5]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVFriday isEqualToCalendarComponentsWeekday:6]) should] beYes];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSaturday isEqualToCalendarComponentsWeekday:7]) should] beYes];
                            });

                         it(@"should not match incorrect days", ^
                            {
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:2]) should] beNo];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:3]) should] beNo];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:4]) should] beNo];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:5]) should] beNo];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:6]) should] beNo];
                                [[theValue([MHVScheduleScheduledDaysEnum.MHVSunday isEqualToCalendarComponentsWeekday:7]) should] beNo];
                            });
                     });
         });

SPEC_END
