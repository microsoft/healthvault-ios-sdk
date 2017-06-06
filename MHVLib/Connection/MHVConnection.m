//
//  MHVConnection.m
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

#import "MHVCommon.h"
#import "MHVConfiguration.h"
#import "MHVConnection.h"
#import "MHVAuthSession.h"
#import "MHVMethod.h"
#import "MHVSessionCredential.h"
#import "MHVRequestMessageCreatorProtocol.h"
#import "MHVRequestMessageCreator.h"
#import "MHVHttpServiceProtocol.h"
#import "MHVInstance.h"
#import "NSError+MHVError.h"
#import "MHVErrorConstants.h"
#import "MHVServiceResponse.h"
#import "MHVHttpServiceRequest.h"
#import "MHVClientFactory.h"
#import "MHVApplicationCreationInfo.h"
#import "MHVValidator.h"
#import "MHVThingClient.h"
#import "MHVRestRequest.h"
#import "MHVBlobDownloadRequest.h"
#import "MHVHttpServiceResponse.h"
#import "MHVPersonInfo.h"

static NSString *const kCorrelationIdContextKey = @"WC_CorrelationId";
static NSString *const kResponseIdContextKey = @"WC_ResponseId";

@interface MHVConnection ()

@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) NSMutableArray<MHVHttpServiceRequest *> *requests;
@property (nonatomic, strong) MHVConfiguration *configuration;

// Clients
@property (nonatomic, strong) id<MHVPlatformClientProtocol> platformClient;
@property (nonatomic, strong) id<MHVPersonClientProtocol> personClient;
@property (nonatomic, strong) id<MHVRemoteMonitoringClientProtocol> remoteMonitoringClient;
@property (nonatomic, strong) id<MHVThingClientProtocol> thingClient;
@property (nonatomic, strong) id<MHVVocabularyClientProtocol> vocabularyClient;

// Dependencies
@property (nonatomic, strong) MHVClientFactory *clientFactory;
@property (nonatomic, strong) id<MHVHttpServiceProtocol> httpService;

@end

@implementation MHVConnection

@dynamic sessionCredential;
@dynamic personInfo;

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                        clientFactory:(MHVClientFactory *)clientFactory
                          httpService:(id<MHVHttpServiceProtocol>)httpService
{
    MHVASSERT_PARAMETER(configuration);
    MHVASSERT_PARAMETER(clientFactory);
    MHVASSERT_PARAMETER(httpService);
    
    self = [super init];
    
    if (self)
    {
        _configuration = configuration;
        _clientFactory = clientFactory;
        _httpService = httpService;
        _requests = [NSMutableArray new];
        _completionQueue = dispatch_queue_create("MHVConnection.requestQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Public

- (NSUUID *_Nullable)applicationId;
{
    return nil;
}

- (void)executeHttpServiceOperation:(id<MHVHttpServiceOperationProtocol> _Nonnull)operation
                         completion:(void (^_Nullable)(MHVServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(operation);
    
    dispatch_async(self.completionQueue, ^
                   {
                       if (!operation.isAnonymous && [NSString isNilOrEmpty:self.sessionCredential.token])
                       {
                           if (completion)
                           {
                               completion(nil, [NSError error:[NSError MHVUnauthorizedError] withDescription:@"The connection is not authenticated. You must first call authenticateWithViewController:completion: before this operation can be performed."]);
                           }
                           
                           return;
                       }
                       else
                       {
                           [self executeHttpServiceRequest:[[MHVHttpServiceRequest alloc] initWithServiceOperation:operation completion:completion]];
                       }
                   });
}

- (void)getPersonInfoWithCompletion:(void (^_Nonnull)(MHVPersonInfo *_Nullable, NSError *_Nullable error))completion;
{
    NSString *message = [NSString stringWithFormat:@"Subclasses must implement %@", NSStringFromSelector(_cmd)];\
    MHVASSERT_MESSAGE(message);
}

- (void)authenticateWithViewController:(UIViewController *_Nullable)viewController
                            completion:(void(^_Nullable)(NSError *_Nullable error))completion;
{
    NSString *message = [NSString stringWithFormat:@"Subclasses must implement %@", NSStringFromSelector(_cmd)];\
    MHVASSERT_MESSAGE(message);
}

- (id<MHVPersonClientProtocol> _Nullable)personClient;
{
    if (!_personClient)
    {
        _personClient = [self.clientFactory personClientWithConnection:self];
    }
    
    return _personClient;
}

- (id<MHVPlatformClientProtocol> _Nullable)platformClient
{
    if (!_platformClient)
    {
        _platformClient = [self.clientFactory platformClientWithConnection:self];
    };
    
    return _platformClient;
}

- (id<MHVThingClientProtocol> _Nullable)thingClient
{
    if (!_thingClient)
    {
        _thingClient = [self.clientFactory thingClientWithConnection:self];
    }
    
    return _thingClient;
}

- (id<MHVRemoteMonitoringClientProtocol> _Nullable)remoteMonitoringClient
{
    if (!_remoteMonitoringClient)
    {
        _remoteMonitoringClient = [self.clientFactory remoteMonitoringClientWithConnection:self];
    }
    
    return _remoteMonitoringClient;
}

- (id<MHVVocabularyClientProtocol> _Nullable)vocabularyClient
{
    if (!_vocabularyClient)
    {
        _vocabularyClient = [self.clientFactory vocabularyClientWithConnection:self];
    }
    
    return _vocabularyClient;
}

#pragma mark - Private

- (void)executeHttpServiceRequest:(MHVHttpServiceRequest *)request
{
    if ([request.serviceOperation isKindOfClass:[MHVMethod class]])
    {
        [self executeMethodRequest:request];
    }
    else if ([request.serviceOperation isKindOfClass:[MHVRestRequest class]])
    {
        [self executeRestRequest:request];
    }
    else if ([request.serviceOperation isKindOfClass:[MHVBlobDownloadRequest class]])
    {
        [self executeBlobDownloadRequest:request];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"ServiceOperation not known: %@", NSStringFromClass([request.serviceOperation class])];
        MHVASSERT_MESSAGE(message);
    }
}

- (void)executeMethodRequest:(MHVHttpServiceRequest *)request
{
    NSString *cacheKey = [request.serviceOperation getCacheKey];
    if (request.serviceOperation.cache)
    {
        // Handle returning cached values
        MHVHttpServiceResponse *cachedResponse = (MHVHttpServiceResponse*)[request.serviceOperation.cache objectForKey:cacheKey];
        if (cachedResponse)
        {
            [self parseResponse:cachedResponse request:request isXML:YES completion:request.completion];
            return;
        }
    }
    
    [self.httpService sendRequestForURL:self.serviceInstance.healthServiceUrl
                             httpMethod:nil
                                   body:[[self messageForMethod:request.serviceOperation] dataUsingEncoding:NSUTF8StringEncoding]
                                headers:[self headersForMethod:request.serviceOperation]
                             completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            if (error.code == MHVErrorTypeUnauthorized)
            {
                [self refreshTokenAndReissueRequest:request];
                
                return;
            }
            else
            {
                if (request.completion)
                {
                    request.completion(nil, error);
                }
                
                return;
            }
        }
        else
        {
            if (request.serviceOperation.cache)
            {
                [request.serviceOperation.cache setObject:response forKey:cacheKey];
            }
            
            [self parseResponse:response request:request isXML:YES completion:request.completion];
        }
    }];
}

- (void)executeRestRequest:(MHVHttpServiceRequest *)request
{
    // TODO: Add cache support
    MHVRestRequest *restRequest = request.serviceOperation;
    
    // If no URL is set, build it from serviceInstance
    if (!restRequest.url)
    {
        [restRequest updateUrlWithServiceUrl:self.configuration.restHealthVaultUrl];
    }
    
    // Add authorization header
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    if (!restRequest.isAnonymous)
    {
        headers[@"Authorization"] = [NSString stringWithFormat:@"MSH-V1 app-token=%@,offline-person-id=%@,record-id=%@", self.sessionCredential.token, self.personInfo.ID, self.personInfo.selectedRecordID];
    }
    
    headers[@"Content-Type"] = @"application/json";
    
    [self.httpService sendRequestForURL:restRequest.url
                             httpMethod:restRequest.httpMethod
                                   body:restRequest.body
                                headers:headers
                             completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        // If unauthorized, refresh token and retry request
        if (error.code == MHVErrorTypeUnauthorized || response.statusCode == 401)
        {
            [self refreshTokenAndReissueRequest:request];
            
            return;
        }
        
        if (response.hasError)
        {
            if (request.completion)
            {
                if (!error)
                {
                    error = [NSError error:[NSError MHVNetworkError] withDescription:[NSString stringWithFormat:@"Response:%@(%@) - %@", @(response.statusCode), response.errorText, response.responseAsString]];
                }

                request.completion(nil, error);
            }

            return;
        }
        else if (error)
        {
            if (request.completion)
            {
                request.completion(nil, error);
            }
            
            return;
        }
        else
        {
            [self parseResponse:response request:request isXML:NO completion:request.completion];
        }
    }];
}

- (void)executeBlobDownloadRequest:(MHVHttpServiceRequest *)request
{
    // TODO: Add cache support
    MHVBlobDownloadRequest *blobDownloadRequest = request.serviceOperation;

    if (blobDownloadRequest.toFilePath)
    {
        //Download to file
        [self.httpService downloadFileWithUrl:blobDownloadRequest.url
                                   toFilePath:blobDownloadRequest.toFilePath
                                   completion:^(NSError * _Nullable error)
         {
             if (request.completion)
             {
                 request.completion(nil, error);
             }
         }];
    }
    else
    {
        //Download as data
        [self.httpService sendRequestForURL:blobDownloadRequest.url
                                 httpMethod:nil
                                       body:nil
                                    headers:nil
                                 completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error)
             {
                 if (request.completion)
                 {
                     request.completion(nil, error);
                 }
             }
             else
             {
                 [self parseResponse:response request:request isXML:NO completion:request.completion];
             }
         }];
    }
}

- (NSString *)messageForMethod:(MHVMethod *)method
{
    MHVRequestMessageCreator *creator = [[MHVRequestMessageCreator alloc] initWithMethod:method
                                                                            sharedSecret:self.sessionCredential.sharedSecret
                                                                             authSession:[self authSession]
                                                                           configuration:self.configuration
                                                                                   appId:self.applicationId
                                                                             messageTime:[NSDate date]];
    
    return creator.xmlString;
}

- (NSDictionary<NSString *, NSString *> *)headersForMethod:(MHVMethod *)method
{
    NSUUID *correlationId = method.correlationId != nil ? method.correlationId : [NSUUID new];
    
    return @{kCorrelationIdContextKey : correlationId.UUIDString};
}

- (void)parseResponse:(MHVHttpServiceResponse *)response
              request:(MHVHttpServiceRequest *)request
                isXML:(BOOL)isXML
           completion:(void (^_Nullable)(MHVServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    // If there is no completion, there is no need to parse the response.
    if (!completion)
    {
        return;
    }
    
    MHVServiceResponse *serviceResponse = [[MHVServiceResponse alloc] initWithWebResponse:response isXML:isXML];
    
    NSError *error = serviceResponse.error;
    
    if (error)
    {
        if (error.code == MHVErrorTypeUnauthorized)
        {
            [self refreshTokenAndReissueRequest:request];
            
            return;
        }
        
        serviceResponse = nil;
    }

    if (completion)
    {
        completion(serviceResponse, error);
    }
}

- (void)refreshSessionCredentialWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    NSString *message = [NSString stringWithFormat:@"Subclasses must implement %@", NSStringFromSelector(_cmd)];\
    MHVASSERT_MESSAGE(message);
}

- (void)refreshTokenAndReissueRequest:(MHVHttpServiceRequest *)request
{
    dispatch_async(self.completionQueue, ^
    {
        [self.requests addObject:request];
        
        if (self.requests.count > 1)
        {
            return;
        }
        
        [self refreshSessionCredentialWithCompletion:^(NSError * _Nullable error)
        {
            dispatch_async(self.completionQueue, ^
            {
                while (self.requests.count > 0)
                {
                    MHVHttpServiceRequest *request = [self.requests firstObject];
                    
                    [self.requests removeObject:request];
                    
                    if (error)
                    {
                        if (request.completion)
                        {
                            request.completion(nil, error);
                        }
                        
                        return;
                    }
                    else
                    {
                        [self executeHttpServiceRequest:request];
                    }
                }
            });
        }];
    });
}

- (MHVAuthSession *)authSession
{
    return nil;
}

@end
