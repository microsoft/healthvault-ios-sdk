//
//  MHVDuration.h
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
#import "MHVApproxDateTime.h"

@interface MHVDuration : MHVType
{
    MHVApproxDateTime* m_startDate;
    MHVApproxDateTime* m_endDate;
}

//-------------------------
//
// Data
//
//-------------------------
@property (readwrite, nonatomic, strong) MHVApproxDateTime* startDate;
@property (readwrite, nonatomic, strong) MHVApproxDateTime* endDate;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithStartDate:(NSDate *) start endDate:(NSDate *) end;
-(id) initWithDate:(NSDate *)start andDurationInSeconds:(double) duration;

@end