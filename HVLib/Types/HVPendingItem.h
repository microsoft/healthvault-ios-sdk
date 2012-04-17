//
//  HVPendingItem.h
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
#import "HVItemKey.h"
#import "HVItemType.h"

@interface HVPendingItem : HVType
{
@private
    HVItemKey* m_id;
    HVItemType* m_type;
    NSDate* m_eDate;
}

@property (readwrite, nonatomic, retain) HVItemKey* key;
@property (readwrite, nonatomic, retain) HVItemType* type;
@property (readwrite, nonatomic, retain) NSDate* effectiveDate;

@end

@interface HVPendingItemCollection : HVCollection
@end