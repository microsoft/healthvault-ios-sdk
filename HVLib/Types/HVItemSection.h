//
//  HVItemSection.h
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

#import <Foundation/Foundation.h>
#import "HVCollection.h"

enum HVItemSection 
{
    HVItemSection_None = 0,
    HVItemSection_Data = 0x01,
    HVItemSection_Core = 0x02,
    HVItemSection_Audits = 0x04,
    HVItemSection_Tags = 0x08,
    HVItemSection_Blobs = 0x10,
    HVItemSection_Permissions = 0x20,
    HVItemSection_Signatures = 0x40,
    //
    // Composite
    //
    HVItemSection_Standard = (HVItemSection_Data | HVItemSection_Core)
};

NSString* HVItemSectionToString(enum HVItemSection section);
enum HVItemSection HVItemSectionFromString(NSString *string);
