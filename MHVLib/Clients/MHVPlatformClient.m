//
//  MHVPlatformClient.m
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

#import "MHVPlatformClient.h"
#import "MHVValidator.h"
#import "MHVConnectionProtocol.h"
#import "MHVMethod.h"
#import "XSerializer.h"
#import "MHVServiceResponse.h"
#import "MHVApplicationCreationInfo.h"
#import "NSError+MHVError.h"
#import "MHVServiceDefinitionRequestParameters.h"
#import "MHVServiceDefinition.h"

@interface MHVPlatformClient ()

@property (nonatomic, weak) id<MHVConnectionProtocol> connection;

@end

@implementation MHVPlatformClient

@synthesize correlationId = _correlationId;

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection
{
    MHVASSERT_PARAMETER(connection);
    
    self = [super init];
    
    if (self)
    {
        _connection = connection;
    }
    
    return self;
}

#pragma mark - Public

- (void)selectInstanceWithPreferredLocation:(MHVLocation *)preferredLocation
                                 completion:(void(^)(MHVServiceInstance *_Nullable serviceInstance, NSError *_Nullable error))completion;
{
    
}

- (void)getServiceDefinitionWithCompletion:(void(^)(MHVServiceDefinition *_Nullable serviceDefinition, NSError *_Nullable error))completion;
{
    [self getServiceDefinitionWithWithParameters:nil
                                      completion:completion];
}

- (void)getServiceDefinitionWithWithLastUpdatedTime:(NSDate *)lastUpdatedTime
                                         completion:(void(^)(MHVServiceDefinition *_Nullable serviceDefinition, NSError *_Nullable error))completion;
{

}

- (void)getServiceDefinitionWithWithResponseSections:(MHVServiceInfoSections)responseSections
                                          completion:(void(^)(MHVServiceDefinition *_Nullable serviceDefinition, NSError *_Nullable error))completion;
{
    NSString *parameters = [self parametersForInfoSections:responseSections lastUpdatedTime:nil];
    
    [self getServiceDefinitionWithWithParameters:parameters
                                      completion:completion];
}

- (void)getServiceDefinitionWithWithLastUpdatedTime:(NSDate *)lastUpdatedTime
                                   responseSections:(MHVServiceInfoSections)responseSections
                                         completion:(void(^)(MHVServiceDefinition *_Nullable serviceDefinition, NSError *_Nullable error))completion;
{
    
}

- (void)getHealthRecordThingTypeDefinitionsWithTypeIds:(NSArray<NSUUID *> *_Nullable)typeIds
                                              sections:(MHVThingTypeSections)sections
                                            imageTypes:(NSArray<NSString *> *_Nullable)imageTypes
                                 lastClientRefreshDate:(NSDate *_Nullable)lastClientRefreshDate
                                            completion:(void(^)(NSDictionary<NSUUID *, MHVThingTypeDefinition *> *_Nullable definitions, NSError *_Nullable error))completion;
{
    
}

- (void)newApplicationCreationInfoWithCompletion:(void(^)(MHVApplicationCreationInfo *_Nullable applicationCreationInfo, NSError *_Nullable error))completion;
{
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    [self.connection executeHttpServiceOperation:[MHVMethod newApplicationCreationInfo]
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            
            return;
        }
        
        MHVApplicationCreationInfo *info = (MHVApplicationCreationInfo *)[XSerializer newFromString:response.infoXml withRoot:@"info" asClass:[MHVApplicationCreationInfo class]];
        
        if (!info || !info.appInstanceId || [NSString isNilOrEmpty:info.sharedSecret] || [NSString isNilOrEmpty:info.appCreationToken])
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The NewApplicationCreationInfo response is invalid."]);
            
            return;
        }
        
        completion(info, nil);
    }];
}

- (void)removeApplicationAuthorizationWithRecordId:(NSUUID *)recordId
                                        completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    MHVMethod *method = [MHVMethod removeApplicationRecordAuthorization];
    method.recordId = recordId;
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (completion)
        {
            completion(error);
        }
    }];
}

#pragma mark - Private

- (void)getServiceDefinitionWithWithParameters:(NSString *)parameters
                                    completion:(void(^)(MHVServiceDefinition *_Nullable serviceDefinition, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    MHVMethod *method = [MHVMethod getServiceDefinition];
    method.parameters = parameters;
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            
            return;
        }
        
        MHVServiceDefinition *definition = (MHVServiceDefinition *)[XSerializer newFromString:response.infoXml withRoot:@"info" asClass:[MHVServiceDefinition class]];
        
        if (!definition)
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The GetServiceDefinition response is invalid."]);
            
            return;
        }
        
        completion(definition, nil);
    
    }];
}

- (NSString *)parametersForInfoSections:(MHVServiceInfoSections)infoSections lastUpdatedTime:(NSDate *)lastUpdatedTime
{
    MHVServiceDefinitionRequestParameters *parameters = [[MHVServiceDefinitionRequestParameters alloc] initWithInfoSections:infoSections lastUpdatedTime:lastUpdatedTime];
    
    return [XSerializer serializeToString:parameters withRoot:@"info"];
}

@end
