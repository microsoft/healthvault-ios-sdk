//
//  HVItemData.h
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
#import "HVType.h"
#import "HVItemDataCommon.h"
#import "HVItemDataTyped.h"

//-------------------------
//
// Xml data associated with an HVItem
//   - Typed data [e.g. Medication, Allergy, Exercise etc.] with associated HV Schemas
//   - Common data [Notes, tags, extensions...] 
//
//-------------------------
@interface HVItemData : HVType
{
@private
    HVItemDataCommon* m_common;
    HVItemDataTyped* m_typed;
}

//-------------------------
//
// Data
//
//-------------------------
@property (readwrite, nonatomic, retain) HVItemDataCommon* common;
@property (readwrite, nonatomic, retain) HVItemDataTyped* typed;

@property (readonly, nonatomic) BOOL hasCommon;
@property (readonly, nonatomic) BOOL hasTyped;


@end
