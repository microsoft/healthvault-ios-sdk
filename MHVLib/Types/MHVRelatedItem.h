//
// MHVRelatedItem.h
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

#import "MHVBaseTypes.h"
#import "MHVType.h"
#import "MHVItemKey.h"
#import "MHVCollection.h"

@class MHVItem;

@interface MHVRelatedItem : MHVType

//
// You can have either a key OR a clientID
//
@property (readwrite, nonatomic, strong) NSString *itemID;
@property (readwrite, nonatomic, strong) NSString *version;
@property (readwrite, nonatomic, strong) MHVString255 *clientID;

@property (readwrite, nonatomic, strong) NSString *relationship;

- (instancetype)initRelationship:(NSString *)relationship toItemWithKey:(MHVItemKey *)key;
- (instancetype)initRelationship:(NSString *)relationship toItemWithClientID:(NSString *)clientID;

+ (MHVRelatedItem *)relationNamed:(NSString *)name toItemKey:(MHVItemKey *)item;
+ (MHVRelatedItem *)relationNamed:(NSString *)name toItem:(MHVItem *)key;

@end

@interface MHVRelatedItemCollection : MHVCollection<MHVRelatedItem *>

- (NSUInteger)indexOfRelation:(NSString *)name;
- (MHVRelatedItem *)addRelation:(NSString *)name toItem:(MHVItem *)item;

@end
