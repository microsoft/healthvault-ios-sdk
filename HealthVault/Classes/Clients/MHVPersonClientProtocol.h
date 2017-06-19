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

@class MHVApplicationSettings, MHVPersonInfo, MHVGetAuthorizedPeopleResult, MHVRecord, MHVRecordCollection, MHVGetAuthorizedPeopleSettings;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVPersonClientProtocol <MHVClientProtocol>

/**
 * Gets the application settings for the current application.
 * The appSettingsXml will also be set on the MHVPersonInfo in getPersonInfoWithCompletion
 *
 * @param completion Envoked when the operation completes.
 *        MHVApplicationSettings application settings.
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)getApplicationSettingsWithCompletion:(void(^)(MHVApplicationSettings *_Nullable settings, NSError *_Nullable error))completion;

/**
 * Sets the application settings for the current application.
 * The applicationSettings.appSettingsXml will not be processed by HealthVault, but must be valid XML
 *
 * @param completion Envoked when the operation completes.
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)setApplicationSettings:(MHVApplicationSettings *)settings
                    completion:(void(^_Nullable)(NSError *_Nullable error))completion;

/**
 * Gets information about people authorized for an application.
 *
 * @param completion Envoked when the operation completes.
 *        NSArray of MHVPersonInfo objects representing people authorized for the application.
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)getAuthorizedPeopleWithCompletion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;

/**
 * Gets information about people authorized for an application.
 *
 * @param settings The MHVGetAuthorizedPeopleSettings object used to configure the results returned by this method.
 *        This allows continuing if a previous getAuthorizedPeople call had the moreResults flag set
 * @param completion Envoked when the operation completes. 
 *        MHVGetAuthorizedPeopleResult containing an array of MHVPersonInfo objects representing people authorized for the application, and a moreResults flag.
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)getAuthorizedPeopleWithSettings:(MHVGetAuthorizedPeopleSettings *)settings
                             completion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;

/**
 * Gets information about current person for an application.
 *
 * @param completion Envoked when the operation completes.
 *        MHVPersonInfo for the current person
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)getPersonInfoWithCompletion:(void(^)(MHVPersonInfo *_Nullable person, NSError *_Nullable error))completion;

/**
 * Gets all the records that the user has authorized the application use.
 *
 * @param recordIds Array of recordIds to retrieve recordInfo
 * @param completion Envoked when the operation completes.
 *        MHVRecordCollection the records for the IDs if successful
 *        NSError object will be nil if there is no error when performing the operation.
 */
- (void)getAuthorizedRecordsWithRecordIds:(NSArray<NSUUID *> *)recordIds
                               completion:(void(^)(MHVRecordCollection *_Nullable records, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
