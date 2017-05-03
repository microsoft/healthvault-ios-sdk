//
//  MHVItemData.h
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
#import "MHVItemDataCommon.h"
#import "MHVItemDataTyped.h"

//-------------------------
//
// Xml data associated with an MHVItem
//   - Typed data [e.g. Medication, Allergy, Exercise etc.] with associated HV Schemas
//   - Common data [Notes, tags, extensions...] 
//
//-------------------------
@interface MHVItemData : MHVType
{
@private
    MHVItemDataCommon* m_common;
    MHVItemDataTyped* m_typed;
}

//-------------------------
//
// Data
//
//-------------------------
@property (readwrite, nonatomic, strong) MHVItemDataCommon* common;
@property (readwrite, nonatomic, strong) MHVItemDataTyped* typed;

@property (readonly, nonatomic) BOOL hasCommon;
@property (readonly, nonatomic) BOOL hasTyped;


@end
