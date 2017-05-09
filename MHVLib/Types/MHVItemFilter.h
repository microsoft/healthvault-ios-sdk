//
// MHVItemFilter.h
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
#import "MHVType.h"
#import "MHVCollection.h"
#import "MHVItemState.h"


@interface MHVTypeFilter : MHVType

@property (readwrite, nonatomic) MHVItemState state;

@property (readwrite, nonatomic, strong) NSDate *effectiveDateMin;
@property (readwrite, nonatomic, strong) NSDate *effectiveDateMax;

@property (readwrite, nonatomic, strong) NSString *createdByAppID;
@property (readwrite, nonatomic, strong) NSString *createdByPersonID;

@property (readwrite, nonatomic, strong) NSString *updatedByAppID;
@property (readwrite, nonatomic, strong) NSString *updatedByPersonID;

@property (readwrite, nonatomic, strong) NSDate *createDateMin;
@property (readwrite, nonatomic, strong) NSDate *createDateMax;

@property (readwrite, nonatomic, strong) NSDate *updateDateMin;
@property (readwrite, nonatomic, strong) NSDate *updateDateMax;

@property (readwrite, nonatomic, strong) NSString *xpath;

@end

@interface MHVItemFilter : MHVTypeFilter

@property (readonly, nonatomic, strong)  MHVStringCollection *typeIDs;

- (instancetype)initWithTypeID:(NSString *)typeID;
- (instancetype)initWithTypeClass:(Class)typeClass;

@end

@interface MHVItemFilterCollection : MHVCollection

- (void)addItem:(MHVItemFilter *)filter;

- (MHVItemFilter *)itemAtIndex:(NSUInteger)index;

@end
