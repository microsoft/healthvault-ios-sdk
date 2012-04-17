//
//  Validator.m
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

#import "HVValidator.h"
#import "HVStringExtensions.h"
#import "HVExceptionExtensions.h"
#import "HVClientException.h"
#import "HVType.h"

HVClientResult* HVValidateArray(NSArray* array, enum HVClientResultCode error)
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_PTR(array, error);
    
    Class hvClass = [HVType class];
    Class stringClass = [NSString class];
    
    for (id obj in array) 
    {
        HVVALIDATE_PTR(obj, error);
        
        if ([obj isKindOfClass:hvClass])
        {
            HVType* hvType = (HVType *) obj;
            HVVALIDATE_SUCCESS([hvType validate]);
        }
        else if ([obj isKindOfClass:stringClass])
        {
            HVVALIDATE_STRING((NSString *) obj, error);
        }
    }
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}