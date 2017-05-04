//
//  MHVItemDataStandard.h
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
#import "MHVString255.h"
#import "MHVStringZ512.h"
#import "MHVRelatedItem.h"

//-------------------------
//
// Common Xml data in a MHVItem 
// [Notes, tags, extensions...] 
//
//-------------------------
@interface MHVItemDataCommon : MHVType
{
@private
    NSString* m_source;
    NSString* m_note;
    MHVStringZ512* m_tags;
    NSMutableArray* m_extensions;
    MHVRelatedItemCollection* m_relatedItems;
    MHVString255* m_clientID;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Optional) The source of the MHVItem
//
@property (readwrite, nonatomic, strong) NSString* source;
//
// (Optional) Arbitrary notes associated with the MHVItem
//
@property (readwrite, nonatomic, strong) NSString* note;
//
// (Optional) One or more string tags
//
@property (readwrite, nonatomic, strong) MHVStringZ512* tags;
//
// (Optional) Additional application specific "Extension" data injected
// into the MHVItem. Can be ANY well-formed Xml node
//
@property (readwrite, nonatomic, strong) NSMutableArray* extensions;
//
// (Optional) Items related to the MHVItem
//
@property (readwrite, nonatomic, strong) MHVRelatedItemCollection* relatedItems;
//
// (Optional) Application injected ID
//
@property (readwrite, nonatomic, strong) MHVString255* clientID;
//
// Convenience properties
//
@property (readwrite, nonatomic, strong) NSString* clientIDValue;

//----------------------
//
// Methods
//
//----------------------
-(MHVRelatedItem *)addRelation:(NSString *)name toItem:(MHVItem *)item;

@end
