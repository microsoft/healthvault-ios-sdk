//
//  HealthVaultRequest.m
//  HealthVault Mobile Library for iOS
//
// Copyright 2017 Microsoft Corp.
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

#import "HealthVaultRequest.h"
#import "DateTimeUtils.h"
#import "MobilePlatform.h"
#import "Base64.h"
#import "HVCommon.h"

@implementation HealthVaultRequest

@synthesize methodName = _methodName;
@synthesize methodVersion = _methodVersion;
@synthesize infoXml = _infoXml;
@synthesize recordId = _recordId;
@synthesize personId = _personId;

@synthesize authorizationSessionToken = _authorizationSessionToken;
@synthesize userAuthToken = _userAuthToken;
@synthesize appIdInstance = _appIdInstance;
@synthesize sessionSharedSecret = _sessionSharedSecret;

@synthesize language = _language;
@synthesize country = _country;
@synthesize msgTime = _msgTime;
@synthesize msgTTL = _msgTTL;
@synthesize userState = _userState;

@synthesize target = _target;
@synthesize callBack = _callBack;
@synthesize isAnonymous = _isAnonymous;

-(BOOL)hasSessionToken
{
    return ![NSString isNilOrEmpty:_authorizationSessionToken];
}

-(BOOL)hasUserAuthToken
{
    return ![NSString isNilOrEmpty:_userAuthToken];
}

-(BOOL)hasCredentials
{
    return (self.hasSessionToken);
}

-(NSURLConnection *)connection
{
    @synchronized(self)
    {
        return _connection;
    }
}

-(void)setConnection:(NSURLConnection *)connection
{
    @synchronized(self)
    {
        _connection = connection;
    }    
}

- (id)initWithMethodName: (NSString *)name
		   methodVersion: (float)methodVersion
			 infoSection: (NSString *)info
				  target: (NSObject *)target
				callBack: (SEL)callBack {

	if (self = [super init]) {

		self.methodName = name;
		self.methodVersion = methodVersion;
		self.infoXml = info;
		self.target = target;
		self.callBack = callBack;

		// Sets default values.
		self.language = @"en";
		self.country = @"US";
		self.msgTTL = 1800;
        
        _isAnonymous = [@"CreateAuthenticatedSessionToken" isEqualToString:self.methodName];
	}

	return self;
}


-(NSString *)toXml
{
    return [self toXml:nil];
}

- (NSString *)toXml:(id<HealthVaultService>)service
{
    _service = service; // Weak ref
	NSMutableString *xml = [NSMutableString new];

	[xml appendString:@"<wc-request:request xmlns:wc-request=\"urn:com.microsoft.wc.request\">"];
    {
        NSString* infoString;
        if (self.infoXml)
        {
            infoString = self.infoXml;
        }
        else
        {
            infoString = @"<info />";
        }
	
        NSMutableString *header = [[NSMutableString alloc] init];
        
        [self writeHeader:header forBody:infoString];
 
        [self writeAuth:xml forHeader:header];
        [xml appendString: header];
        

        [xml appendString:infoString];
    }
	[xml appendString: @"</wc-request:request>"];
    
    _service = nil;
    
	return xml;
}

-(void)cancel
{
    @synchronized(self)
    {
        if (_connection)
        {
            [_connection cancel];
        }
        _connection = nil;
    }
}

-(void)writeHeader:(NSMutableString *)header forBody:(NSString *)body
{
    [header appendXmlElementStart:@"header"];
    {
        [self writeMethodHeaders:header];
        [self writeRecordHeaders:header];
        [self writeAuthSessionHeader:header];
        [self writeStandardHeaders:header];
        [self writeHashHeader:header forBody:body];
    }
    
	[header appendXmlElementEnd:@"header"];
}

-(void)writeMethodHeaders:(NSMutableString *)header
{
    [header appendXmlElement:@"method" text:self.methodName];
    [header appendXmlElementStart:@"method-version"];
    {
        [header appendFormat: @"%.0f", self.methodVersion];
    }
    [header appendXmlElementEnd:@"method-version"];
}

-(void)writeRecordHeaders:(NSMutableString *)header
{
    if (self.recordId)
    {
        [header appendXmlElement:@"record-id" text:self.recordId];
    }
}

-(void)writeStandardHeaders:(NSMutableString *)header
{
    [header appendXmlElement:@"language" text:self.language];
    [header appendXmlElement:@"country" text:self.country];
    [header appendXmlElement:@"msg-time" text:[DateTimeUtils dateToUtcString:self.msgTime]];
    [header appendXmlElementStart:@"msg-ttl"];
    {
        [header appendFormat: @"%d", self.msgTTL];
    }
    [header appendXmlElementEnd:@"msg-ttl"];
    [header appendXmlElement:@"version" text:[MobilePlatform platformAbbreviationAndVersion]];
}

-(void)writeAuthSessionHeader:(NSMutableString *)header
{
    if (!self.hasCredentials)
    {
        [header appendXmlElement:@"app-id" text:self.appIdInstance];
        return;
    }
    
    [header appendXmlElementStart:@"auth-session"];
    [header appendXmlElement:@"auth-token" text:self.authorizationSessionToken];
    if (self.hasUserAuthToken)
    {
        [header appendXmlElement:@"user-auth-token" text:self.userAuthToken];
    }
    else if (self.personId)
    {
        [header appendXmlElementStart: @"offline-person-info"];
        [header appendXmlElement: @"offline-person-id" text:self.personId];
        [header appendXmlElementEnd: @"offline-person-info"];
    }
    [header appendXmlElementEnd:@"auth-session"];
}

-(void)writeHashHeader:(NSMutableString *)header forBody:(NSString *)body
{
    if (_isAnonymous)
    {
        return;
    }
    
    [header appendXmlElementStart:@"info-hash"];
    {
        NSString* hash;
        if (_service)
        {
            hash = [[_service cryptographer] computeSha256Hash:body];
        }
        else
        {
            hash = [MobilePlatform computeSha256Hash:body];
        }
        [header appendFormat: @"<hash-data algName=\"SHA256\">%@</hash-data>", hash];
    }
    [header appendXmlElementEnd:@"info-hash"];
}

-(void)writeAuth:(NSMutableString *)xml forHeader:(NSString *)header
{
    if (self.sessionSharedSecret && !_isAnonymous)
    {
        NSData *decodedKey = [Base64 decodeBase64WithString: self.sessionSharedSecret];
        
        NSString* hmac;
        if (_service)
        {
            hmac = [[_service cryptographer] computeSha256Hmac:decodedKey data:header];
        }
        else
        {
            hmac = [MobilePlatform computeSha256Hmac:decodedKey data:header];
        }
        [xml appendXmlElementStart:@"auth"];
        {
            [xml appendFormat: @"<hmac-data algName=\"HMACSHA256\">%@</hmac-data>", hmac];
        }
        [xml appendXmlElementEnd:@"auth"];
    }
}

@end
