//
//  MHVPersonClient.m
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

#import "MHVPersonClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVHttpServiceProtocol.h"
#import "MHVValidator.h"
#import "MHVMethod.h"
#import "MHVPersonInfo.h"
#import "XSerializer.h"
#import "MHVServiceResponse.h"
#import "NSError+MHVError.h"
#import "MHVGetAuthorizedPeopleResult.h"

@interface MHVPersonClient ()

@property (nonatomic, weak) id<MHVConnectionProtocol> connection;

@end

@implementation MHVPersonClient

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

- (void)getApplicationSettingsWithCompletion:(void(^)(MHVApplicationSettings *_Nullable settings, NSError *_Nullable error))completion
{
    
}

- (void)setApplicationSettingsWithRequestParameters:(NSString *)requestParameters
                                         completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    
}

- (void)getAuthorizedPeopleWithCompletion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion;
{
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    MHVMethod *method = [MHVMethod getAuthorizedPeople];
    method.parameters = @"<info><parameters></parameters></info>";
    
    [self.connection executeHttpServiceOperation:method
                                      completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            
            return;
        }
        
        MHVGetAuthorizedPeopleResult *peopleResult = (MHVGetAuthorizedPeopleResult *)[XSerializer newFromString:response.infoXml withRoot:@"info" asClass:[MHVGetAuthorizedPeopleResult class]];
       
        if (!peopleResult)
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The GetAuthorizedPeople response is invalid."]);
            
            return;
        }
        
        if (peopleResult.persons.count < 1)
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The GetAuthorizedPeople response has no authorized people."]);
            
            return;
        }
        
        completion(peopleResult.persons, nil);
        
    }];
}

- (void)getAuthorizedPeopleWithSettings:(MHVGetAuthorizedPeopleSettings *_Nonnull)settings
                             completion:(void(^)(NSArray<MHVPersonInfo *> *_Nullable personInfos, NSError *_Nullable error))completion
{
    
}

- (void)getPersonInfoWithCompletion:(void(^)(MHVPersonInfo *_Nullable person, NSError *_Nullable error))completion
{
    
}

- (void)getAuthorizedRecordsWithRecordIds:(NSArray<NSUUID *> *)recordIds
                               completion:(void(^)(NSArray<MHVHealthRecordInfo *> *_Nullable records, NSError *_Nullable error))completion
{
    
}

@end
