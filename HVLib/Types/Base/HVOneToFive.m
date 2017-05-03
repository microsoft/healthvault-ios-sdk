//
//  HVOneToFive.m
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

#import "HVOneToFive.h"

NSString* stringFromRating(enum HVRelativeRating rating)
{
    switch (rating) {
        case HVRelativeRating_VeryLow:
            return @"Very Low";
        
        case HVRelativeRating_Low:
            return @"Low";
        
        case HVRelativeRating_Moderate:
            return @"Moderate";
            
        case HVRelativeRating_High:
            return @"High";
            
        case HVRelativeRating_VeryHigh:
            return @"Very High";
            
        default:
            break;
    }
    
    return c_emptyString;
}

NSString* stringFromNormalcy(enum HVNormalcyRating rating)
{
    switch (rating) {
        case HVNormalcy_WellAboveNormal:
            return @"Well Below Normal";
        
        case HVNormalcy_BelowNormal:
            return @"Below Normal";
        
        case HVNormalcy_Normal:
            return @"Normal";
        
        case HVNormalcy_AboveNormal:
            return @"Above Normal";
        
        case HVNormalcy_WellBelowNormal:
            return @"Well Above Normal";
            
        default:
            break;
    }
    
    return c_emptyString;
}

@implementation HVOneToFive

-(int) min
{
    return 1;
}
-(int) max
{
    return 5;
}

@end
