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
#import "MHVRestRequest.h"
#import "MHVHttpServiceResponse.h"

static NSString *const kCorrelationIdContextKey = @"WC_CorrelationId";
static NSString *const kResponseIdContextKey = @"WC_ResponseId";

@interface MHVConnection ()

@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) NSMutableArray<MHVHttpServiceRequest *> *requests;

// Clients
@property (nonatomic, strong) id<MHVPlatformClientProtocol> platformClient;
@property (nonatomic, strong) id<MHVPersonClientProtocol> personClient;
@property (nonatomic, strong) id<MHVThingClientProtocol> thingClient;

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

- (void)executeMethod:(id<MHVHttpServiceOperationProtocol> _Nonnull)method
           completion:(void (^_Nullable)(MHVServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(method);
    
    dispatch_async(self.completionQueue, ^
    {
        if (!method.isAnonymous && [NSString isNilOrEmpty:self.sessionCredential.token])
        {
            if (completion)
            {
                completion(nil, [NSError error:[NSError MHVUnauthorizedError] withDescription:@"The connection is not authenticated. You must first call authenticateWithViewController:completion: before this operation can be performed."]);
            }
            
            return;
        }
        else
        {
            [self executeHttpServiceRequest:[[MHVHttpServiceRequest alloc] initWithServiceOperation:method completion:completion]];
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

- (id<MHVVocabularyClientProtocol> _Nullable)vocabularyClient
{
    NSAssert(NO, @"Must Implement");
    return nil;
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
    else
    {
        NSString *message = [NSString stringWithFormat:@"ServiceOperation not known: %@", NSStringFromClass([request.serviceOperation class])];
        MHVASSERT_MESSAGE(message);
    }
}

- (void)executeMethodRequest:(MHVHttpServiceRequest *)request
{
    [self.httpService sendRequestForURL:self.serviceInstance.healthServiceUrl
                                 method:nil
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
            [self parseResponse:response request:request isXML:YES completion:request.completion];
        }
    }];
}

- (void)executeRestRequest:(MHVHttpServiceRequest *)request
{
    MHVRestRequest *restRequest = request.serviceOperation;
    
    if (restRequest.restRequestType == MHVRestRequestJSON)
    {
        [self executeJsonRestRequest:request];
    }
}

- (void)executeJsonRestRequest:(MHVHttpServiceRequest *)request
{
    MHVRestRequest *restRequest = request.serviceOperation;

    // If no URL is set, build it from serviceInstance
    if (!restRequest.url)
    {
        [restRequest updateUrlWithServiceUrl:self.serviceInstance.healthServiceUrl];
    }
    
    // Add authorization header
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    if (!restRequest.isAnonymous)
    {
        headers[@"Authorization"] = self.sessionCredential.token;
    }
    
    [self.httpService sendRequestForURL:restRequest.url
                                 method:restRequest.method
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
            [self parseResponse:response request:request isXML:NO completion:request.completion];
        }
    }];
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
