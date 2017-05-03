//
//  MHVItemSection.m
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

#import "MHVCommon.h"
#import "MHVItemSection.h"

NSString* const c_itemsection_core = @"core";
NSString* const c_itemsection_audit = @"audits";
NSString* const c_itemsection_blob = @"blobpayload";
NSString* const c_itemsection_tags = @"tags";
NSString* const c_itemsection_permissions = @"effectivepermissions";
NSString* const c_itemsection_signatures = @"digitalsignatures";

NSString* HVItemSectionToString(enum MHVItemSection section)
{
   switch (section) {
        case HVItemSection_Core:
            return c_itemsection_core;
            
        case HVItemSection_Audits:
            return c_itemsection_audit;
            
        case HVItemSection_Blobs:
            return c_itemsection_blob;
            
        case HVItemSection_Tags:
            return c_itemsection_tags;
            
        case HVItemSection_Permissions:
            return c_itemsection_permissions;
            
        case HVItemSection_Signatures:
            return c_itemsection_signatures;
            
        default:
            break;
    }
    
    return nil;
}

enum MHVItemSection HVItemSectionFromString(NSString* value)
{
    if ([NSString isNilOrEmpty:value])
    {
        return HVItemSection_None;
    }
    
    enum MHVItemSection section = HVItemSection_None;

    if ([value isEqualToString:c_itemsection_core])
    {
        section = HVItemSection_Core;
    }
    else if ([value isEqualToString:c_itemsection_audit])
    {
        section = HVItemSection_Audits;
    }
    else if ([value isEqualToString:c_itemsection_blob])
    {
        section = HVItemSection_Blobs;
    }
    else if ([value isEqualToString:c_itemsection_tags])
    {
        section = HVItemSection_Tags;
    }
    else if ([value isEqualToString:c_itemsection_permissions])
    {
        section = HVItemSection_Permissions;
    }
    else if ([value isEqualToString:c_itemsection_signatures])
    {
        section = HVItemSection_Signatures;
    }

    return section;
}
