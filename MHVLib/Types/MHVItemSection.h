//
// MHVItemSection.h
// MHVLib
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

#import <Foundation/Foundation.h>
#import "MHVCollection.h"

typedef NS_ENUM (NSInteger, MHVItemSection)
{
    MHVItemSection_None = 0,
    MHVItemSection_Data = 0x01,
    MHVItemSection_Core = 0x02,
    MHVItemSection_Audits = 0x04,
    MHVItemSection_Tags = 0x08,          // Not supported by MHVItem parsing
    MHVItemSection_Blobs = 0x10,
    MHVItemSection_Permissions = 0x20,   // Not supported by MHVItem parsing
    MHVItemSection_Signatures = 0x40,    // Not supported by MHVItem parsing
    //
    // Composite
    //
    MHVItemSection_Standard = (MHVItemSection_Data | MHVItemSection_Core)
};

NSString *MHVItemSectionToString(MHVItemSection section);
MHVItemSection MHVItemSectionFromString(NSString *string);
