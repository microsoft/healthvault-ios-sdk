//
//  MHVThingTypeDefinition.h
//  MHVLib
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

#import "MHVType.h"

@class MHVThingTypeVersionInfoCollection, MHVBool;

@interface MHVThingTypeDefinition : MHVType

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSUUID *typeId;

@property (nonatomic, strong, readonly) NSString *xmlSchemaDefinition;

@property (nonatomic, strong, readonly) MHVBool *isCreatable;

@property (nonatomic, strong, readonly) MHVBool *isImmutable;

@property (nonatomic, strong, readonly) MHVBool *isSingletonType;

@property (nonatomic, strong, readonly) MHVBool *allowReadOnly;

@property (nonatomic, strong, readonly) MHVThingTypeVersionInfoCollection *versions;

@property (nonatomic, strong, readonly) NSString *effectiveDateXPath;

@property (nonatomic, strong, readonly) NSString *updatedEndDateXPath;

@end
