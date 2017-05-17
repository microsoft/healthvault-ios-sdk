//
//  MHVPersonClient.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/17/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVPersonClient.h"
#import "MHVConnectionProtocol.h"
#import "MHVValidator.h"
#import "MHVMethod.h"
#import "MHVPersonInfo.h"
#import "XSerializer.h"
#import "MHVServiceResponse.h"
#import "NSError+MHVError.h"

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
    
    [self.connection executeMethod:method completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            completion(nil, error);
            
            return;
        }
        
        MHVPersonInfo *personInfo = (MHVPersonInfo *)[XSerializer newFromString:response.infoXml withRoot:@"info" asClass:[MHVPersonInfo class]];
       
        if (!personInfo)
        {
            completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The GetAuthorizedPeople response is invalid."]);
            
            return;
        }
        
        completion(@[personInfo], nil);
        
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
