//
// MHVPlatformClientProtocol.h
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
@class MHVLocation, MHVServiceInstance, MHVServiceInfo, MHVServiceInfoSections, MHVThingTypeSections, MHVThingTypeDefinition, MHVApplicationCreationInfo, MHVPersonInfo, MHVGetAuthorizedPeopleSettings;

NS_ASSUME_NONNULL_BEGIN

/**
 * Methods to interact with the platform.
 */
@protocol MHVPlatformClientProtocol <MHVClientProtocol>

/**
 * Gets the instance where a HealthVault account should be created for the specified account location.
 *
 * @param preferredLocation  A user's preferred geographical location, used to select the best instance in which to create a new HealthVault account. If there is a location associated with the credential that will be used to log into the account, that location should be used.
 * @param completion Envoked when the operation completes. MHVServiceInstance object represents the selected instance, or nil if no suitable instance exists. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 *
 * @note If no suitable instance can be found, a nil is returned. This can happen, for example, if the account location is not supported by HealthVault. Currently the returned instance IDs all parse to integers, but that is not guaranteed and should not be relied upon.
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)selectInstanceWithPreferredLocation:(MHVLocation *)preferredLocation
                                                                         completion:(void(^)(MHVServiceInstance *_Nullable serviceInstance, NSError *_Nullable error))completion;

/**
 * Gets information about the HealthVault service.
 *
 * @param completion Envoked when the operation completes. MHVServiceInfo instance that contains the service version, SDK assemblies versions and URLs, method information, and so on. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 *
 * @note This includes:
 * - The version of the service.
 * - The SDK assembly URLs.
 * - The SDK assembly versions.
 * - The SDK documentation URL.
 * - The URL to the HealthVault Shell.
 * - The schema definition for the HealthVault method's request and response.
 * - The common schema definitions for types that the HealthVault methods use.
 * - Information about all available HealthVault instances.
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getServiceDefinitionWithCompletion:(void(^)(MHVServiceInfo *_Nullable serviceInfo, NSError *_Nullable error))completion;


/**
 * Gets information about the HealthVault service only if it has been updated since the specified update time.
 *
 * @param lastUpdatedTime The time of the last update to an existing cached copy of MHVServiceInfo
 * @param completion Envoked when the operation completes. MHVServiceInfo instance that contains the service version, SDK assemblies versions and URLs, method information, and so on. If there were no updates MHVServiceInfo will be nil. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 *
 * @note This includes:
 * - The version of the service.
 * - The SDK assembly URLs.
 * - The SDK assembly versions.
 * - The SDK documentation URL.
 * - The URL to the HealthVault Shell.
 * - The schema definition for the HealthVault method's request and response.
 * - The common schema definitions for types that the HealthVault methods use.
 * - Information about all available HealthVault instances.
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getServiceDefinitionWithWithLastUpdatedTime:(NSDate *)lastUpdatedTime
                                                                                 completion:(void(^)(MHVServiceInfo *_Nullable serviceInfo, NSError *_Nullable error))completion;


/**
 * Gets information about the HealthVault service corresponding to the specified categories.
 *
 * @param responseSections A bitmask of one or more MHVServiceInfoSections which specify the categories of information to be populated in the MHVServiceInfo object
 * @param completion Envoked when the operation completes. MHVServiceInfo instance that contains the service version, SDK assemblies versions and URLs, method information, and so on. If there were no updates MHVServiceInfo will be nil. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 *
 * @note Depending on the specified responseSections this will include some or all of:
 * - The version of the service.
 * - The SDK assembly URLs.
 * - The SDK assembly versions.
 * - The SDK documentation URL.
 * - The URL to the HealthVault Shell.
 * - The schema definition for the HealthVault method's request and response.
 * - The common schema definitions for types that the HealthVault methods use.
 * - Information about all available HealthVault instances.
 * Retrieving only the sections you need will give a faster response time than downloading the full response.
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getServiceDefinitionWithWithResponseSections:(MHVServiceInfoSections)responseSections
                                                                                  completion:(void(^)(MHVServiceInfo *_Nullable serviceInfo, NSError *_Nullable error))completion;

/**
 * Gets Gets information about the HealthVault service corresponding to the specified categories if the requested information has been updated since the specified update time.
 *
 * @param lastUpdatedTime The time of the last update to an existing cached copy of MHVServiceInfo
 * @param responseSections A bitmask of one or more MHVServiceInfoSections which specify the categories of information to be populated in the MHVServiceInfo object
 * @param completion Envoked when the operation completes. MHVServiceInfo instance that contains the service version, SDK assemblies versions and URLs, method information, and so on. If there were no updates MHVServiceInfo will be nil. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 *
 * @note Depending on the specified responseSections this will include some or all of:
 * - The version of the service.
 * - The SDK assembly URLs.
 * - The SDK assembly versions.
 * - The SDK documentation URL.
 * - The URL to the HealthVault Shell.
 * - The schema definition for the HealthVault method's request and response.
 * - The common schema definitions for types that the HealthVault methods use.
 * - Information about all available HealthVault instances.
 * Retrieving only the sections you need will give a faster response time than downloading the full response.
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getServiceDefinitionWithWithLastUpdatedTime:(NSDate *)lastUpdatedTime
                                                                           responseSections:(MHVServiceInfoSections)responseSections
                                                                                 completion:(void(^)(MHVServiceInfo *_Nullable serviceInfo, NSError *_Nullable error))completion;


/**
 * Gets the definitions for one or more thing type definitions supported by HealthVault.
 *
 * @param typeIds A collection of health item type IDs whose details are being requested. Nil indicates that all health item types should be returned.
 * @param sections A collection of ThingTypeSections enumeration values that indicate the type of details to be returned for the specified health item records(s).
 * @param imageTypes A collection of strings that identify which health item record images should be retrieved.
 * @param lastClientRefreshDate  A NSDate instance that specifies the time of the last refresh made by the client.
 * @param completion Envoked when the operation completes. NSDictionary<NSUUID *, MHVThingTypeDefinition *> a dictionary containing type definitions for the specified types, or empty if the typeIds parameter does not represent a known unique type identifier. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getHealthRecordItemTypeDefinitionsWithTypeIds:(NSArray<NSUUID *> *_Nullable)typeIds
                                                                                     sections:(MHVThingTypeSections)sections
                                                                                   imageTypes:(NSArray<NSString *> *_Nullable)imageTypes
                                                                        lastClientRefreshDate:(NSDate *_Nullable)lastClientRefreshDate
                                                                                   completion:(void(^)(NSDictionary<NSUUID *, MHVThingTypeDefinition *> *_Nullable definitions, NSError *_Nullable error))completion;


/**
 * Creates a new application instance. This is the first step in the SODA authentication flow.
 *
 * @param completion Envoked when the operation completes. MHVApplicationCreationInfo Information about the newly created application instance. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)newApplicationCreationInfoWithCompletion:(void(^)(MHVApplicationCreationInfo *_Nullable applicationCreationInfo, NSError *_Nullable error))completion;


/**
 * Gets information about people authorized for an application.
 *
 * @param completion Envoked when the operation completes. NSArray<MHVPersonInfo *> an array of MHVPersonInfo objects representing people authorized for the application. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getAuthorizedPeopleWithCompletion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;


/**
 * Gets information about people authorized for an application.
 *
 * @param settings The MHVGetAuthorizedPeopleSettings object used to configure the results returned by this method.
 * @param completion Envoked when the operation completes. NSArray<MHVPersonInfo *> an array of MHVPersonInfo objects representing people authorized for the application. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)getAuthorizedPeopleWithSettings:(MHVGetAuthorizedPeopleSettings *_Nonnull)settings
                                                                     completion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;


/**
 * Removes authorization for the given record.
 *
 * @param recordId The record to remove authorization for.
 * @param completion Envoked when the operation completes. NSError object will be nil if there is no error when performing the operation.
 * @return TaskProgress object that can be cancelled or used for observing progress. Can be nil if arguments are invalid
 */
- (NSObject<MHVTaskProgressProtocol> *_Nullable)removeApplicationAuthorizationWithRecordId:(NSUUID *)recordId
                                                                                completion:(void(^_Nullable)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
