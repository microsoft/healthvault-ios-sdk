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
#import "WebTransport.h"
#import "WebResponse.h"
#import "HealthVaultRequest.h"
#import "HealthVaultResponse.h"
#import "Base64.h"
#import "DateTimeUtils.h"
#import "Provisioner.h"
#import "XmlTextReader.h"
#import "HealthVaultSettings.h"
#import "HealthVaultConfig.h"
#import "HVCommon.h"
#import "HVClient.h"
#import "MHVHttpService.h"
#import "MHVHttpResponse.h"

@interface HealthVaultService ()

@property (nonatomic, strong) MHVHttpService *httpService;

- (BOOL)initDefaultProviders;

- (void)sendRequestImpl:(HealthVaultRequest *)request;

/// Refreshes the session token.
/// Makes a CAST call to get a new session token,
/// and then re-issues the original request.
/// @param request - the original request.
- (void)refreshSessionToken:(HealthVaultRequest *)request;

/// Invokes the calling application's callback.
/// @param request - the request object.
/// @param response - the response object.
- (void)performAppCallBack:(HealthVaultRequest *)request
                  response:(HealthVaultResponse *)response;

- (NSString *)getApplicationCreationUrl:(BOOL)isGlobal;

@end


@implementation HealthVaultService

@synthesize healthServiceUrl = _healthServiceUrl;
@synthesize shellUrl = _shellUrl;
@synthesize authorizationSessionToken = _authorizationSessionToken;
@synthesize sharedSecret = _sharedSecret;
@synthesize sessionSharedSecret = _sessionSharedSecret;
@synthesize masterAppId = _masterAppId;
@synthesize language = _language;
@synthesize country = _country;
@synthesize deviceName = _deviceName;
@synthesize appIdInstance = _appIdInstance;
@synthesize applicationCreationToken = _applicationCreationToken;
@synthesize records = _records;
@synthesize currentRecord = _currentRecord;

@synthesize requestSendDelay = _requestDelay;

- (NSString *)settingsFileName
{
    return (_settingsFileName) ? _settingsFileName : @"HVClient";
}

- (void)setSettingsFileName:(NSString *)settingsFileName
{
    HVRETAIN(_settingsFileName, settingsFileName);
}

- (id<HVHttpTransport>)transport
{
    return _transport;
}

- (void)setTransport:(id<HVHttpTransport>)transport
{
    if (transport)
    {
        HVRETAIN(_transport, transport);
    }
}

- (Provisioner *)provisioner
{
    return _provisioner;
}

- (void)setProvisioner:(Provisioner *)provisioner
{
    if (provisioner)
    {
        HVRETAIN(_provisioner, provisioner);
    }
}

- (id<HVCryptographer>)cryptographer
{
    return _cryptographer;
}

- (void)setCryptographer:(id<HVCryptographer>)cryptographer
{
    if (cryptographer)
    {
        HVRETAIN(_cryptographer, cryptographer);
    }
}

- (id)init
{
    return [self initWithUrl:nil
                    shellUrl:nil
                 masterAppId:nil];
}

- (id)initWithDefaultUrl:(NSString *)masterAppId
{
    HVEnvironmentSettings *defaultEnvironment = [[HVClient current].settings firstEnvironment];
    
    HVCHECK_NOTNULL(defaultEnvironment);
    
    return [self initForAppID:masterAppId andEnvironment:defaultEnvironment];
    
LError:
    HVALLOC_FAIL;
}

- (id)initWithUrl:(NSString *)healthServiceUrl
         shellUrl:(NSString *)shellUrl
      masterAppId:(NSString *)masterAppId
{
    self = [super init];
    HVCHECK_SELF;
    
    self.settingsFileName = masterAppId;
    self.healthServiceUrl = healthServiceUrl;
    self.shellUrl = shellUrl;
    self.masterAppId = masterAppId;
    
    self.language = DEFAULT_LANGUAGE;
    self.country = DEFAULT_COUNTRY;
    
    _records = [NSMutableArray new];
    HVCHECK_NOTNULL(_records);
    
    HVCHECK_SUCCESS([self initDefaultProviders]);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

- (id)initForAppID:(NSString *)appID andEnvironment:(HVEnvironmentSettings *)environment
{
    return [self initWithUrl:environment.serviceUrl.absoluteString
                    shellUrl:environment.shellUrl.absoluteString
                 masterAppId:appID];
}

- (void)dealloc
{
    self.healthServiceUrl = nil;
    self.shellUrl = nil;
    self.authorizationSessionToken = nil;
    self.sharedSecret = nil;
    self.sessionSharedSecret = nil;
    self.masterAppId = nil;
    self.language = nil;
    self.country = nil;
    self.deviceName = nil;
    self.appIdInstance = nil;
    self.applicationCreationToken = nil;
    self.records = nil;
    self.currentRecord = nil;
    
    [_settingsFileName release];
    
    [_transport release];
    [_cryptographer release];
    [_provisioner release];
    
    [super dealloc];
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
    
    CFStringRef queryStringEncoded = HVUrlEncode((CFStringRef)queryString);
    
    NSString *userAuthUrl = [NSString stringWithFormat:@"%@/redirect.aspx?target=APPAUTH&targetqs=%@",
                             self.shellUrl, (NSString *)queryStringEncoded];
    
    CFRelease(queryStringEncoded);
    
    return userAuthUrl;
}

- (void)sendRequest:(HealthVaultRequest *)request
{
    if (_requestDelay > 0)
    {
        [self sendRequest:request withDelay:_requestDelay];
        return;
    }
    
    if ([NSThread isMainThread])
    {
        [self sendRequestImpl:request];
    }
    else
    {
        //
        // NSURLConnection needs to be created on a thread with a guaranteed RunLoop in default mode
        // Only way to truly guarantee this is to default to the main thread
        //
        [self invokeOnMainThread:@selector(sendRequestImpl:) withObject:request];
    }
}

- (void)sendRequest:(HealthVaultRequest *)request withDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(sendRequestImpl:) withObject:request afterDelay:delay];
}

- (void)sendRequestCallback:(MHVHttpResponse *)response
                    context:(HealthVaultRequest *)healthVaultRequest
{
    HealthVaultResponse *healthVaultResponse = [[[HealthVaultResponse alloc] initWithResponse:response
                                                                                      request:healthVaultRequest] autorelease];
    
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
    NSString *keyString = [[NSString alloc] initWithData:keyData
                                                encoding:NSASCIIStringEncoding];
    NSString *hmac = [MobilePlatform computeSha256Hmac:keyData data:stringToSign];
    [keyString release];
    
    NSMutableString *xml = [NSMutableString new];
    [xml appendString:@"<info>"];
    [xml appendString:@"<auth-info>"];
    [xml appendFormat:@"<app-id>%@</app-id>", self.appIdInstance];
    [xml appendString:@"<credential>"];
    [xml appendString:@"<appserver2>"];
    [xml appendFormat:@"<hmacSig algName=\"HMACSHA256\">%@</hmacSig>", hmac];
    [xml appendString:stringToSign];
    [stringToSign release];
    [xml appendString:@"</appserver2>"];
    [xml appendString:@"</credential>"];
    [xml appendString:@"</auth-info>"];
    [xml appendString:@"</info>"];
    
    return [xml autorelease];
}

- (void)saveCastCallResults:(NSString *)responseXml
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    @try
    {
        XmlTextReader *xmlReader = [XmlTextReader new];
        XmlElement *responseRootNode = [xmlReader read:responseXml];
        
        self.authorizationSessionToken = [responseRootNode selectSingleNode:@"token"].text;
        self.sessionSharedSecret = [responseRootNode selectSingleNode:@"shared-secret"].text;
        
        [xmlReader release];
    }
    @finally
    {
        [pool release];
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
    [settings release];
}

- (void)loadSettings
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
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
            [record release];
        }
        else
        {
            self.currentRecord = nil;
        }
    }
    @finally
    {
        [pool release];
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
    
    _records = [NSMutableArray new];
}

- (void)applyEnvironmentSettings:(HVEnvironmentSettings *)settings
{
    self.healthServiceUrl = settings.serviceUrl.absoluteString;
    self.shellUrl = settings.shellUrl.absoluteString;
}

@end

@implementation HealthVaultService (HVPrivate)

- (BOOL)initDefaultProviders
{
    _transport = [[HVHttpTransport alloc] init];
    HVCHECK_NOTNULL(_transport);
    
    _provisioner = [[Provisioner alloc] init];
    HVCHECK_NOTNULL(_provisioner);
    
    _cryptographer = [[HVCryptographer alloc] init];
    HVCHECK_NOTNULL(_cryptographer);
    
    _httpService = [[MHVHttpService alloc] initWithURLSessionConfiguration:nil];
    
    return TRUE;
    
LError:
    return FALSE;
}

- (void)sendRequestImpl:(HealthVaultRequest *)request
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
                               withData:requestXml
                             completion:^(MHVHttpResponse *_Nullable response, NSError *_Nullable error)
     {
         [self sendRequestCallback:response
                           context:request];
     }];
    
    // request.connection = [_transport sendRequestForURL: self.healthServiceUrl
    // withData: requestXml
    // context: request
    // target: self
    // callBack: @selector(sendRequestCallback: context:)];
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
    [refreshTokenRequest release];
}

- (void)performAppCallBack:(HealthVaultRequest *)request
                  response:(HealthVaultResponse *)response
{
    if (request && request.target && [request.target respondsToSelector:request.callBack])
    {
        [request.target performSelector:request.callBack
                             withObject:response];
    }
}

- (NSString *)getApplicationCreationUrl:(BOOL)isGlobal
{
    if (self.applicationCreationToken == nil || self.applicationCreationToken.length == 0)
    {
        return nil;
    }
    
    CFStringRef tokenEncoded = HVUrlEncode((CFStringRef)self.applicationCreationToken);
    
    NSString *dName = (self.deviceName) ? self.deviceName : [MobilePlatform deviceName];
    CFStringRef deviceNameEncoded = HVUrlEncode((CFStringRef)dName);
    
    NSString *queryString = [NSString stringWithFormat:@"?appid=%@&appCreationToken=%@&instanceName=%@&ismra=true",
                             self.masterAppId, tokenEncoded, deviceNameEncoded];
    if (isGlobal)
    {
        queryString = [queryString stringByAppendingString:@"&aib=true"];
    }
    
    CFStringRef queryStringEncoded = HVUrlEncode((CFStringRef)queryString);
    
    NSString *appCreationUrl = [NSString stringWithFormat:@"%@/redirect.aspx?target=CREATEAPPLICATION&targetqs=%@",
                                self.shellUrl, (NSString *)queryStringEncoded];
    
    CFRelease(tokenEncoded);
    CFRelease(deviceNameEncoded);
    CFRelease(queryStringEncoded);
    
    return appCreationUrl;
}

@end
