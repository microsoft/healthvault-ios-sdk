//
//  MHVOneToFive.h
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
#import "MHVConstrainedInt.h"

enum HVRelativeRating 
{
    HVRelativeRating_None = 0,
    HVRelativeRating_VeryLow,
    HVRelativeRating_Low,
    HVRelativeRating_Moderate,
    HVRelativeRating_High,
    HVRelativeRating_VeryHigh
};

NSString* stringFromRating(enum HVRelativeRating rating);

enum HVNormalcyRating
{
    HVNormalcy_Unknown = 0,
    HVNormalcy_WellBelowNormal,
    HVNormalcy_BelowNormal,
    HVNormalcy_Normal,
    HVNormalcy_AboveNormal,
    HVNormalcy_WellAboveNormal
};

NSString* stringFromNormalcy(enum HVNormalcyRating rating);


@interface MHVOneToFive : MHVConstrainedInt

@end

