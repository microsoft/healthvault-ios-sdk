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

NSString* MHVItemSectionToString(enum MHVItemSection section)
{
   switch (section) {
        case MHVItemSection_Core:
            return c_itemsection_core;
            
        case MHVItemSection_Audits:
            return c_itemsection_audit;
            
        case MHVItemSection_Blobs:
            return c_itemsection_blob;
            
        case MHVItemSection_Tags:
            return c_itemsection_tags;
            
        case MHVItemSection_Permissions:
            return c_itemsection_permissions;
            
        case MHVItemSection_Signatures:
            return c_itemsection_signatures;
            
        default:
            break;
    }
    
    return nil;
}

enum MHVItemSection MHVItemSectionFromString(NSString* value)
{
    if ([NSString isNilOrEmpty:value])
    {
        return MHVItemSection_None;
    }
    
    enum MHVItemSection section = MHVItemSection_None;

    if ([value isEqualToString:c_itemsection_core])
    {
        section = MHVItemSection_Core;
    }
    else if ([value isEqualToString:c_itemsection_audit])
    {
        section = MHVItemSection_Audits;
    }
    else if ([value isEqualToString:c_itemsection_blob])
    {
        section = MHVItemSection_Blobs;
    }
    else if ([value isEqualToString:c_itemsection_tags])
    {
        section = MHVItemSection_Tags;
    }
    else if ([value isEqualToString:c_itemsection_permissions])
    {
        section = MHVItemSection_Permissions;
    }
    else if ([value isEqualToString:c_itemsection_signatures])
    {
        section = MHVItemSection_Signatures;
    }

    return section;
}
