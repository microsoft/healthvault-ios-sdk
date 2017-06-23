//
//  MHVMoreFeatures.h
//  SDKFeatures
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
//

#import <Foundation/Foundation.h>
#import "MHVStatusLabel.h"

@class MHVTypeListViewController;

@interface MHVMoreFeatures : NSObject

@property (readwrite, nonatomic, weak) MHVTypeListViewController* listController;

//
// How to disconnect an app
//
- (void)disconnectApp;

//
// Get service definition
//
- (void)getServiceDefinition;

//
// Demonstrate application settings, sets current date as custom XML and then gets & displays
//
- (void)demonstrateApplicationSettings;

//
// Get the personInfo
//
- (void)getPersonInfo;

//
// Get the authorized records
//
- (void)getAuthorizedRecords;

//
// Get the authorized people
//
- (void)getAuthorizedPeople;

//
// Get the record operations
//
- (void)getRecordOperations;

//
// Authorize Additional Records;
//
- (void)authorizeAdditionalRecords;

@end
