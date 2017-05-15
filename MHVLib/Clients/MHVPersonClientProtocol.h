//
// MHVPersonClientProtocol.h
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

#import "MHVClientProtocol.h"

@protocol MHVTaskProgressProtocol;
@class MHVApplicationSettings, MHVPersonInfo, MHVHealthRecordInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVPersonClientProtocol <MHVClientProtocol>

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getApplicationSettingsWithCompletion:(void(^)(MHVApplicationSettings *_Nullable settings, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)setApplicationSettingsWithRequestParameters:(NSString *)requestParameters
                                                                                 completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getAuthorizedPeopleWithCompletion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable people, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getPersonInfoWithCompletion:(void(^)(MHVPersonInfo *_Nullable person, NSError *_Nullable error))completion;

- (NSObject<MHVTaskProgressProtocol> *_Nullable)getAuthorizedRecordsWithRecordIds:(NSArray<NSUUID *> *)recordIds
                                                                       completion:(void(^)(NSArray<MHVHealthRecordInfo *> *_Nullable records, NSError *_Nullable error))completion;

NS_ASSUME_NONNULL_BEGIN

@end
