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

@class MHVApplicationSettings, MHVPersonInfo, MHVHealthRecordInfo;

@protocol MHVPersonClientProtocol <MHVClientProtocol>

- (void)getApplicationSettingsWithCompletion:(void(^_Nonnull)(MHVApplicationSettings *_Nullable settings, NSError *_Nullable error))completion;

- (void)setApplicationSettingsWithRequestParameters:(NSString *_Nonnull)requestParameters
                                         completion:(void(^_Nonnull)(NSError *_Nullable error))completion;

- (void)getAuthorizedPeopleWithCompletion:(void(^_Nonnull)(NSArray<MHVPersonInfo *> *_Nullable people, NSError *_Nullable error))completion;

- (void)getPersonInfoWithCompletion:(void(^_Nonnull)(MHVPersonInfo *_Nullable person, NSError *_Nullable error))completion;

- (void)getAuthorizedRecordsWithRecordIds:(NSArray<NSUUID *> *_Nonnull)recordIds
                               completion:(void(^_Nonnull)(NSArray<MHVHealthRecordInfo *> *_Nullable records, NSError *_Nullable error))completion;

@end
