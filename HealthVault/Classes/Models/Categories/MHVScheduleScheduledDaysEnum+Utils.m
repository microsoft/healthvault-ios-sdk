//
// MHVScheduleScheduledDaysEnum+Utils.m
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

#import "MHVScheduleScheduledDaysEnum+Utils.h"

@implementation MHVScheduleScheduledDaysEnum (Utils)

- (BOOL)isEqualToCalendarComponentsWeekday:(NSInteger)weekday
{
    if (weekday < 1 || weekday > 7)
    {
        return NO;
    }
    
    if ([self isEqual:MHVScheduleScheduledDaysEnum.MHVEveryday])
    {
        return YES;
    }

    if (([self isEqual:MHVScheduleScheduledDaysEnum.MHVSunday] && weekday == 1) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVMonday] && weekday == 2) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVTuesday] && weekday == 3) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVWednesday] && weekday == 4) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVThursday] && weekday == 5) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVFriday] && weekday == 6) ||
        ([self isEqual:MHVScheduleScheduledDaysEnum.MHVSaturday] && weekday == 7))
    {
        return YES;
    }
    
    return NO;
}

@end
