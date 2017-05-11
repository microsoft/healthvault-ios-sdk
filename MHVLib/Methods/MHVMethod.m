//
//  MHVMethod.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVMethod.h"

@implementation MHVMethod

- (instancetype)initWithName:(NSString *)name isAnonymous:(BOOL)isAnonymous
{
    self = [super init];
    
    if (self)
    {
        _name = name;
        _isAnonymous = isAnonymous;
    }
    
    return self;
}

+ (MHVMethod *)allocatePackageId;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        method = [[MHVMethod alloc] initWithName:@"AllocatePackageId" isAnonymous:NO];
    });
    return method;
}

+ (MHVMethod *)associateAlternateId;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"AssociateAlternateId" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)beginPutBlob;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"BeginPutBlob" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)beginPutConnectPackageBlob;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"BeginPutConnectPackageBlob" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)createAuthenticatedSessionToken;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"CreateAuthenticatedSessionToken" isAnonymous:YES];
                  });
    return method;
}

+ (MHVMethod *)createConnectPackage;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"CreateConnectPackage" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)createConnectRequest;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"CreateConnectRequest" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)deletePendingConnectPackage;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"DeletePendingConnectPackage" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)deletePendingConnectRequest;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"DeletePendingConnectRequest" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)disassociateAlternateId;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"DisassociateAlternateId" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getAlternateIds;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetAlternateIds" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getApplicationInfo;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetApplicationInfo" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getApplicationSettings;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetApplicationSettings" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getAuthorizedConnectRequests;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetAuthorizedConnectRequests" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getAuthorizedPeople;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetAuthorizedPeople" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getAuthorizedRecords;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetAuthorizedRecords" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getEventSubscriptions;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetEventSubscriptions" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getMeaningfulUseTimelyAccessReport;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetMeaningfulUseTimelyAccessReport" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getMeaningfulUseVDTReport;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetMeaningfulUseVDTReport" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getPersonInfo;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetPersonInfo" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getServiceDefinition;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetServiceDefinition" isAnonymous:YES];
                  });
    return method;
}

+ (MHVMethod *)getThings;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetThings" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getThingType;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetThingType" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getUpdatedRecordsForApplication;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetUpdatedRecordsForApplication" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getValidGroupMembership;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetValidGroupMembership" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)getVocabulary;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"GetVocabulary" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)newApplicationCreationInfo;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"NewApplicationCreationInfo" isAnonymous:YES];
                  });
    return method;
}

+ (MHVMethod *)newSignupCode;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"NewSignupCode" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)putThings;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"PutThings" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)queryPermissions;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"QueryPermissions" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)removeApplicationRecordAuthorization;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"RemoveApplicationRecordAuthorization" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)removeThings;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"RemoveThings" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)searchVocabulary;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SearchVocabulary" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)selectInstance;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SelectInstance" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)sendInsecureMessage;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SendInsecureMessage" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)sendInsecureMessageFromApplication;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SendInsecureMessageFromApplication" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)setApplicationSettings;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SetApplicationSettings" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)subscribeToEvent;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"SubscribeToEvent" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)unsubscribeToEvent;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"UnsubscribeToEvent" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)updateEventSubscription;
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"UpdateEventSubscription" isAnonymous:NO];
                  });
    return method;
}

+ (MHVMethod *)updateExternalId
{
    static MHVMethod *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      method = [[MHVMethod alloc] initWithName:@"UpdateExternalId" isAnonymous:NO];
                  });
    return method;
}

@end
