//
// HealthVaultService.m
// HealthVault Mobile Library for iOS
//
// Copyright 2011, 2014 Microsoft Corp.
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

#import "HealthVaultService.h"
#import "MobilePlatform.h"
#import "MHVHttpService.h"
#import "HealthVaultRequest.h"
#import "HealthVaultResponse.h"
#import "Base64.h"
#import "DateTimeUtils.h"
#import "Provisioner.h"
#import "HealthVaultSettings.h"
#import "HealthVaultConfig.h"
#import "MHVCommon.h"
#import "MHVConfiguration.h"
#import "MHVClient.h"

@implementation HealthVaultService

- (NSString *)settingsFileName
{
    return (_settingsFileName) ? _settingsFileName : @"MHVClient";
}

- (instancetype)init
{
    return [self initWithUrl:nil
                    shellUrl:nil
                 masterAppId:nil];
}

- (instancetype)initWithDefaultUrl:(NSString *)masterAppId
{
    MHVEnvironmentSettings *defaultEnvironment = [[MHVClient current].settings firstEnvironment];
    
    MHVCHECK_NOTNULL(defaultEnvironment);
    
    return [self initForAppID:masterAppId andEnvironment:defaultEnvironment];
}

- (instancetype)initWithUrl:(NSString *)healthServiceUrl
                   shellUrl:(NSString *)shellUrl
                masterAppId:(NSString *)masterAppId
{
    self = [super init];
    if (self)
    {
        _settingsFileName = masterAppId;
        _healthServiceUrl = healthServiceUrl;
        _shellUrl = shellUrl;
        _masterAppId = masterAppId;
        
        _language = DEFAULT_LANGUAGE;
        _country = DEFAULT_COUNTRY;
        
        _records = [NSMutableArray new];
        MHVCHECK_NOTNULL(_records);
        
        MHVCHECK_SUCCESS([self setupDefaultProviders]);
    }
    return self;
}

- (instancetype)initForAppID:(NSString *)appID andEnvironment:(MHVEnvironmentSettings *)environment
{
    return [self initWithUrl:environment.serviceUrl.absoluteString
                    shellUrl:environment.shellUrl.absoluteString
                 masterAppId:appID];
}

- (NSString *)getApplicationCreationUrl
{
    return [self getApplicationCreationUrl:FALSE];
}

- (NSString *)getApplicationCreationUrlGA
{
    return [self getApplicationCreationUrl:TRUE];
}

- (NSString *)getUserAuthorizationUrl
{
    NSString *queryString = [NSString stringWithFormat:@"?appid=%@&ismra=true", self.appIdInstance];
    
    CFStringRef queryStringEncoded = CreateHVUrlEncode((__bridge CFStringRef)queryString);
    
    NSString *userAuthUrl = [NSString stringWithFormat:@"%@/redirect.aspx?target=APPAUTH&targetqs=%@",
                             self.shellUrl, (__bridge NSString *)queryStringEncoded];
    
    CFRelease(queryStringEncoded);
    
    return userAuthUrl;
}

- (void)sendRequestCallback:(MHVHttpServiceResponse *)response
                    context:(HealthVaultRequest *)healthVaultRequest
{
    HealthVaultResponse *healthVaultResponse = [[HealthVaultResponse alloc] initWithWebResponse:response
                                                                                        request:healthVaultRequest];
    
    // The token that is returned from GetAuthenticatedSessionToken has a limited lifetime. When it expires,
    // we will get an error here. We detect that situation, get a new token, and then re-issue the call.
    if (healthVaultResponse.statusCode == RESPONSE_AUTH_SESSION_TOKEN_EXPIRED)
    {
        [self refreshSessionToken:healthVaultRequest];
        return;
    }
    
    // Returns source request and response to app.
    [self performAppCallBack:healthVaultRequest
                    response:healthVaultResponse];
}

- (void)performAuthenticationCheck:(NSObject *)target
           authenticationCompleted:(SEL)authCompleted
                 shellAuthRequired:(SEL)shellAuthRequired
{
    [_provisioner performAuthenticationCheck:self
                                      target:target
                     authenticationCompleted:authCompleted
                           shellAuthRequired:shellAuthRequired];
}

- (void)   authorizeRecords:(NSObject *)target
    authenticationCompleted:(SEL)authCompleted
          shellAuthRequired:(SEL)shellAuthRequired
{
    [_provisioner authorizeRecords:self
                            target:target
           authenticationCompleted:authCompleted
                 shellAuthRequired:shellAuthRequired];
}

- (BOOL)isAppCreated
{
    return [self getIsApplicationCreated];
}

- (BOOL)getIsApplicationCreated
{
    return ![NSString isNilOrEmpty:self.authorizationSessionToken] && ![NSString isNilOrEmpty:self.sharedSecret];
}

- (void)refreshSessionTokenCompleted:(HealthVaultResponse *)response
{
    // Retrieves source request, which was failed.
    HealthVaultRequest *originalRequest = (HealthVaultRequest *)response.request.userState;
    
    // Any error just gets returned to the application.
    if (response.hasError)
    {
        [self performAppCallBack:originalRequest
                        response:response];
        return;
    }
    
    // If the CAST was successful the results were saved and
    // the original request is restarted.
    [self saveCastCallResults:response.infoXml];
    //
    // Persist the new session token
    //
    [self saveSettings];
    
    // Resend original request.
    [self sendRequest:originalRequest];
}

- (NSString *)getCastCallInfoSection
{
    NSString *msgTimeString = [DateTimeUtils dateToUtcString:[NSDate date]];
    
    NSMutableString *stringToSign = [NSMutableString new];
    
    [stringToSign appendString:@"<content>"];
    [stringToSign appendFormat:@"<app-id>%@</app-id>", self.appIdInstance];
    [stringToSign appendString:@"<hmac>HMACSHA256</hmac>"];
    [stringToSign appendFormat:@"<signing-time>%@</signing-time>", msgTimeString];
    [stringToSign appendString:@"</content>"];
    
    NSData *keyData = [Base64 decodeBase64WithString:self.sharedSecret];
    NSString *hmac = [MobilePlatform computeSha256Hmac:keyData data:stringToSign];
    
    NSMutableString *xml = [NSMutableString new];
    [xml appendString:@"<info>"];
    [xml appendString:@"<auth-info>"];
    [xml appendFormat:@"<app-id>%@</app-id>", self.appIdInstance];
    [xml appendString:@"<credential>"];
    [xml appendString:@"<appserver2>"];
    [xml appendFormat:@"<hmacSig algName=\"HMACSHA256\">%@</hmacSig>", hmac];
    [xml appendString:stringToSign];
    [xml appendString:@"</appserver2>"];
    [xml appendString:@"</credential>"];
    [xml appendString:@"</auth-info>"];
    [xml appendString:@"</info>"];
    
    return xml;
}

- (void)saveCastCallResults:(NSString *)responseXml
{
    @try
    {
        XReader *reader = [[XReader alloc] initFromString:responseXml];
        [reader readStartElementWithName:@"info"];
        self.authorizationSessionToken = [reader readStringElement:@"token"];
        self.sessionSharedSecret = [reader readStringElement:@"shared-secret"];
    }
    @catch (id exception)
    {
        MHVASSERT_MESSAGE(exception);
    }
}

- (void)saveSettings
{
    HealthVaultSettings *settings = [[HealthVaultSettings alloc] initWithName:self.settingsFileName];
    
    settings.applicationId = self.appIdInstance;
    settings.authorizationSessionToken = self.authorizationSessionToken;
    settings.sharedSecret = self.sharedSecret;
    settings.country = self.country;
    settings.language = self.language;
    settings.sessionSharedSecret = self.sessionSharedSecret;
    settings.version = [MobilePlatform platformAbbreviationAndVersion];
    
    if (self.currentRecord)
    {
        settings.personId = self.currentRecord.personId;
        settings.recordId = self.currentRecord.recordId;
    }
    
    [settings save];
}

- (void)loadSettings
{
    @autoreleasepool
    {
        @try
        {
            HealthVaultSettings *settings = [HealthVaultSettings loadWithName:self.settingsFileName];
            
            self.appIdInstance = settings.applicationId;
            self.authorizationSessionToken = settings.authorizationSessionToken;
            self.sharedSecret = settings.sharedSecret;
            self.country = settings.country;
            self.language = settings.language;
            self.sessionSharedSecret = settings.sessionSharedSecret;
            
            if (settings.personId && settings.recordId)
            {
                HealthVaultRecord *record = [HealthVaultRecord new];
                record.personId = settings.personId;
                record.recordId = settings.recordId;
                self.currentRecord = record;
            }
            else
            {
                self.currentRecord = nil;
            }
        }
        @catch (id exception)
        {
        }
    }
}

- (void)reset
{
    self.authorizationSessionToken = nil;
    self.sharedSecret = nil;
    self.sessionSharedSecret = nil;
    self.appIdInstance = nil;
    self.applicationCreationToken = nil;
    self.records = nil;
    self.currentRecord = nil;
    
    self.records = [NSMutableArray new];
}

- (void)applyEnvironmentSettings:(MHVEnvironmentSettings *)settings
{
    self.healthServiceUrl = settings.serviceUrl.absoluteString;
    self.shellUrl = settings.shellUrl.absoluteString;
}

#pragma mark - Internal methods

- (BOOL)setupDefaultProviders
{
    _httpService = [[MHVHttpService alloc] initWithConfiguration:[MHVConfiguration new]];
    MHVCHECK_NOTNULL(_httpService);
    
    _provisioner = [[Provisioner alloc] init];
    MHVCHECK_NOTNULL(_provisioner);
    
    return TRUE;
}

- (void)sendRequest:(HealthVaultRequest *)request
{
    request.msgTime = [NSDate date];
    if (!request.appIdInstance)
    {
        if (self.appIdInstance && self.appIdInstance.length > 0)
        {
            request.appIdInstance = self.appIdInstance;
        }
        else
        {
            request.appIdInstance = self.masterAppId;
        }
    }
    
    request.authorizationSessionToken = self.authorizationSessionToken;
    request.sessionSharedSecret = self.sessionSharedSecret;
    
    NSString *requestXml = [request toXml:self];
    
    [self.httpService sendRequestForURL:[NSURL URLWithString:self.healthServiceUrl]
                                   body:[requestXml dataUsingEncoding:NSUTF8StringEncoding]
                             completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         [self sendRequestCallback:response
                           context:request];
     }];
}

- (void)refreshSessionToken:(HealthVaultRequest *)request
{
    self.authorizationSessionToken = nil;
    NSString *infoSection = [self getCastCallInfoSection];
    
    HealthVaultRequest *refreshTokenRequest =
    [[HealthVaultRequest alloc] initWithMethodName:@"CreateAuthenticatedSessionToken"
                                     methodVersion:2
                                       infoSection:infoSection
                                            target:self
                                          callBack:@selector(refreshSessionTokenCompleted:)];
    
    // Saves source response to userState property, it will be resent
    // after token updating.
    refreshTokenRequest.userState = request;
    refreshTokenRequest.personId = request.personId;
    refreshTokenRequest.recordId = request.recordId;
    
    [self sendRequest:refreshTokenRequest];
}

- (void)performAppCallBack:(HealthVaultRequest *)request
                  response:(HealthVaultResponse *)response
{
    if (request && request.target && [request.target respondsToSelector:request.callBack])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [request.target performSelector:request.callBack
                             withObject:response];
#pragma clang diagnostic pop
    }
}

- (NSString *)getApplicationCreationUrl:(BOOL)isGlobal
{
    if (self.applicationCreationToken == nil || self.applicationCreationToken.length == 0)
    {
        return nil;
    }
    
    CFStringRef tokenEncoded = CreateHVUrlEncode((__bridge CFStringRef)self.applicationCreationToken);
    
    NSString *dName = (self.deviceName) ? self.deviceName : [MobilePlatform deviceName];
    CFStringRef deviceNameEncoded = CreateHVUrlEncode((__bridge CFStringRef)dName);
    
    NSString *queryString = [NSString stringWithFormat:@"?appid=%@&appCreationToken=%@&instanceName=%@&ismra=true",
                             self.masterAppId, tokenEncoded, deviceNameEncoded];
    if (isGlobal)
    {
        queryString = [queryString stringByAppendingString:@"&aib=true"];
    }
    
    CFStringRef queryStringEncoded = CreateHVUrlEncode((__bridge CFStringRef)queryString);
    
    NSString *appCreationUrl = [NSString stringWithFormat:@"%@/redirect.aspx?target=CREATEAPPLICATION&targetqs=%@",
                                self.shellUrl, (__bridge NSString *)queryStringEncoded];
    
    CFRelease(tokenEncoded);
    CFRelease(deviceNameEncoded);
    CFRelease(queryStringEncoded);
    
    return appCreationUrl;
}

@end
