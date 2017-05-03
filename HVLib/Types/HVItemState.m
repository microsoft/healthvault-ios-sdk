//
//  HVItemState.m
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

#import "HVCommon.h"
#import "HVItemState.h"

NSString* const c_itemstate_active = @"Active";
NSString* const c_itemstate_deleted = @"Deleted";

NSString* HVItemStateToString(enum HVItemState state)
{
    NSString* value = nil;
    
    if (state & HVItemStateActive)
    {
        return c_itemstate_active;
    }
    
    if (state & HVItemStateDeleted)
    {
        return c_itemstate_deleted;
    }
    
    return value;
}

enum HVItemState HVItemStateFromString(NSString* value)
{
    if ([NSString isNilOrEmpty:value])
    {
        return HVItemStateNone;
    }
    
    if ([value isEqualToString:c_itemstate_active])
    {
        return HVItemStateActive;
    }
    
    if ([value isEqualToString:c_itemstate_deleted])
    {
        return HVItemStateDeleted;
    }
    
    return HVItemStateNone;
}
