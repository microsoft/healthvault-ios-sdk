//
// MHVUser.h
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
#import <UIKit/UIKit.h>
#import "MHVTypes.h"
#import "XLib.h"

//
// The user of your HealthVault application
//
@interface MHVUser : XSerializableType

//
// The user's display name in HealthVault
//
@property (readwrite, nonatomic, strong) NSString *name;
//
// Records this user is authorized to access
//
@property (readwrite, nonatomic, strong) MHVRecordCollection *records;
@property (readonly, nonatomic) BOOL hasRecords; // true if user has authorized records
//
// The records the application is currently working with
// To change the current record, set the currentRecordIndex property
//
@property (readwrite, nonatomic) NSInteger currentRecordIndex;
@property (readonly, nonatomic, strong) MHVRecord *currentRecord;

//
// Which service environment this user set up their app to work with
//
@property (readwrite, nonatomic, strong) NSString *environment;

@property (readwrite, nonatomic, strong) NSString *instanceID;

@property (readonly, nonatomic) BOOL hasEnvironment;
@property (readonly, nonatomic) BOOL hasInstanceID;


- (void)clear;

- (MHVClientResult *)validate;

@end
