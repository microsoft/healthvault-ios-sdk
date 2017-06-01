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

@class MHVApplicationSettings, MHVPersonInfo, MHVHealthRecordInfo, MHVGetAuthorizedPeopleSettings, UIImage;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVPersonClientProtocol <MHVClientProtocol>

- (void)getApplicationSettingsWithCompletion:(void(^)(MHVApplicationSettings *_Nullable settings, NSError *_Nullable error))completion;

- (void)setApplicationSettingsWithRequestParameters:(NSString *)requestParameters
                                         completion:(void(^_Nullable)(NSError *_Nullable error))completion;

/**
 * Gets information about people authorized for an application.
 *
 * @param completion Envoked when the operation completes. NSArray<MHVPersonInfo *> an array of MHVPersonInfo objects representing people authorized for the application. NSError object will be nil if there is no error when performing the operation.
 */
- (void)getAuthorizedPeopleWithCompletion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;


/**
 * Gets information about people authorized for an application.
 *
 * @param settings The MHVGetAuthorizedPeopleSettings object used to configure the results returned by this method.
 * @param completion Envoked when the operation completes. NSArray<MHVPersonInfo *> an array of MHVPersonInfo objects representing people authorized for the application. NSError object will be nil if there is no error when performing the operation.
 */
- (void)getAuthorizedPeopleWithSettings:(MHVGetAuthorizedPeopleSettings *_Nonnull)settings
                             completion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;

- (void)getPersonInfoWithCompletion:(void(^)(MHVPersonInfo *_Nullable person, NSError *_Nullable error))completion;

- (void)getAuthorizedRecordsWithRecordIds:(NSArray<NSUUID *> *)recordIds
                               completion:(void(^)(NSArray<MHVHealthRecordInfo *> *_Nullable records, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
