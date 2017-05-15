//
//  MHVShellAuthService.m
//  MHVLib
//
//  Created by Nathan Malubay on 5/15/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import "MHVShellAuthService.h"
#import "MHVValidator.h"
#import "NSError+MHVError.h"
#import "MHVConfiguration.h"
#import "MHVBrowserAuthBrokerProtocol.h"
#import "MHVDictionaryExtensions.h"
#import "MHVStringExtensions.h"

static NSString *const kInstanceIdKey = @"instanceId=";
static NSString *const kBaseQueryFormat = @"redirect.aspx?target=CREATEAPPLICATION&targetqs=%@";
static NSString *const kAppCreationQueryFormat = @"appid=%@&appCreationToken=%@&instanceName=%@&ismra=%@&mobile=true%@";
static NSString *const kRecordAuthQueryFormat = @"appid=%@&ismra=%@";

@interface MHVShellAuthService ()

@property (nonatomic, strong) MHVConfiguration *configuration;
@property (nonatomic, strong) id<MHVBrowserAuthBrokerProtocol> authBroker;
@property (nonatomic, strong) dispatch_queue_t authQueue;
@property (nonatomic, assign) BOOL isAuthInProgress;

@end

@implementation MHVShellAuthService

- (instancetype)initWithConfiguration:(MHVConfiguration *)configuration
                           authBroker:(id<MHVBrowserAuthBrokerProtocol>)authBroker
{
    MHVASSERT_PARAMETER(configuration);
    MHVASSERT_PARAMETER(authBroker);
    
    self = [super init];
    
    if (self)
    {
        _configuration = configuration;
        _authBroker = authBroker;
        _authQueue = _authQueue = dispatch_queue_create("MHVShellAuthService.authQueue", DISPATCH_QUEUE_SERIAL);
        _isAuthInProgress = NO;
    }
    
    return self;
}

#pragma mark - Public

- (void)provisionApplicationWithViewController:(UIViewController *_Nullable)viewController
                                      shellUrl:(NSURL *)shellUrl
                                   masterAppId:(NSUUID *)masterAppId
                              appCreationToken:(NSString *)appCreationToken
                                 appInstanceId:(NSString *)appInstanceId
                                    completion:(void (^)(NSString *_Nullable instanceId, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(shellUrl);
    MHVASSERT_PARAMETER(masterAppId);
    MHVASSERT_PARAMETER(appCreationToken);
    MHVASSERT_PARAMETER(appInstanceId);
    MHVASSERT_PARAMETER(completion);
    
    dispatch_async(self.authQueue, ^
    {
        if (!completion)
        {
            return;
        }
        
        if (self.isAuthInProgress)
        {
            completion(nil, [NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Another authentication operation is currently running."]);
            
            return;
        }
        
        self.isAuthInProgress = YES;
        
        if (!shellUrl || !masterAppId || !appCreationToken || !appInstanceId)
        {
            completion(nil, [NSError error:[NSError MVHInvalidParameter] withDescription:@"One or more required parameters are missing."]);
        }
        
        NSString *queryString = [NSString stringWithFormat:kAppCreationQueryFormat, masterAppId, appCreationToken, appInstanceId, [self mraBooleanString], [self miaParamString]];
        
        queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
        
        [self authenticateInBrowserWithViewController:viewController
                                             shellUrl:shellUrl
                                          queryString:queryString
                                           completion:^(NSURL * _Nullable successUrl, NSError * _Nullable error)
        {
            dispatch_async(self.authQueue, ^
            {
                if (error)
                {
                    completion(nil, error);
                    
                    self.isAuthInProgress = NO;
                    
                    return;
                }
                
                NSString *instanceId = [self instanceIdFromUrl:successUrl];
                
                if ([NSString isNilOrEmpty:instanceId])
                {
                    completion (nil, [NSError error:[NSError MHVUnknownError] withDescription:@"Failed to obtain an instanceId from the authorization service."]);
                    
                    self.isAuthInProgress = NO;
                    
                    return;
                }
                
                completion(instanceId, nil);
                
                self.isAuthInProgress = NO;
            });
        }];
    });
}

- (void)authorizeAdditionalRecordsWithViewController:(UIViewController *_Nullable)viewController
                                            shellUrl:(NSURL *)shellUrl
                                         masterAppId:(NSUUID *)masterAppId
                                          completion:(void (^_Nullable)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(shellUrl);
    MHVASSERT_PARAMETER(masterAppId);
    
    dispatch_async(self.authQueue, ^
    {
        if (!completion)
        {
            return;
        }
        
        if (self.isAuthInProgress)
        {
            completion([NSError error:[NSError MHVOperationCannotBePerformed] withDescription:@"Another authentication operation is currenlty running."]);
            
            return;
        }
        
        self.isAuthInProgress = YES;
        
        if (!shellUrl || !masterAppId)
        {
            if (completion)
            {
                completion([NSError error:[NSError MVHInvalidParameter] withDescription:@"One or more required parameters are missing."]);
            }
        }
        
        NSString *queryString = [NSString stringWithFormat:kRecordAuthQueryFormat, masterAppId, [self mraBooleanString]];
        
        queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
        
        [self authenticateInBrowserWithViewController:viewController
                                             shellUrl:shellUrl
                                          queryString:queryString
                                           completion:^(NSURL * _Nullable successUrl, NSError * _Nullable error)
        {
            dispatch_async(self.authQueue, ^
            {
                if (completion)
                {
                    completion(error);
                }
                
                self.isAuthInProgress = NO;
            });
        }];
    });
}

#pragma mark - Private

- (NSString *)mraBooleanString
{
    return self.configuration.isMultiRecordApp ? @"true" : @"false";
}

- (NSString *)miaParamString
{
    return self.configuration.isMultiRecordApp ? @"&aib=true" : @"";
}

- (NSString *)instanceIdFromUrl:(NSURL *)url
{
    NSDictionary* args = [NSDictionary dictionaryFromArgumentString:[url query]];
    
    if ([NSDictionary isNilOrEmpty:args])
    {
        return nil;
    }
    
    return [args objectForKey:@"instanceid"];
}

- (void)authenticateInBrowserWithViewController:(UIViewController *)viewController
                                       shellUrl:(NSURL *)shellUrl
                              queryString:(NSString *)queryString
                               completion:(void (^)(NSURL * _Nullable successUrl, NSError *_Nullable error))completion
{
    NSURLComponents *startComponents = [NSURLComponents componentsWithURL:shellUrl resolvingAgainstBaseURL:YES];
    startComponents.query = [NSString stringWithFormat:kBaseQueryFormat, queryString];
    
    NSURLComponents *endComponents = [NSURLComponents componentsWithURL:shellUrl resolvingAgainstBaseURL:YES];
    endComponents.path = @"application/complete";
    
    [self.authBroker authenticateWithViewController:viewController
                                           startUrl:startComponents.URL
                                             endUrl:endComponents.URL
                                         completion:completion];
}

@end
