//
// HealthVaultRequest.h
// HealthVault Mobile Library for iOS
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

#import <Foundation/Foundation.h>
#import "MHVService.h"

/// This class encapsulates the data that is contained in a request.
@interface HealthVaultRequest : NSObject

/// Gets or sets the name of the method to be called.
/// The method name and version must be one of the methods documented in the
/// method reference at:
/// http://developer.healthvault.com/pages/methods/methods.aspx
@property (strong) NSString *methodName;

/// Gets or sets the version of the method to be called.
/// The method name and version must be one of the methods documented in the
/// method reference at:
/// http://developer.healthvault.com/pages/methods/methods.aspx
@property (assign) float methodVersion;

/// Gets or sets the request-specific information.
@property (strong) NSString *infoXml;

/// Gets or sets the record id that will be used to perform request.
@property (strong) NSString *recordId;

/// Gets or sets the person id that will be used to perform request.
@property (strong) NSString *personId;

/// Gets or sets the authorization token that is required to talk to the HealthVault
/// web service.
@property (strong) NSString *authorizationSessionToken;

@property (strong) NSString *userAuthToken;

/// Gets or sets the application instance id.
@property (strong) NSString *appIdInstance;

/// Gets or sets the session shared secret.
@property (strong) NSString *sessionSharedSecret;

// Gets or sets the language that is used for responses.
@property (strong) NSString *language;

/// Gets or sets the country that is used for responses.
@property (strong) NSString *country;

/// Gets or sets request msg-time parameter.
@property (strong) NSDate *msgTime;

/// Gets or sets request msg-ttl parameter.
@property (assign) int msgTTL;

/// Gets or sets the user state.
/// User state can be used by the caller to pass state to the handler.
@property (strong) NSObject *userState;

/// Gets or sets the callback handler.
@property (strong) NSObject *target;

/// Gets or sets the callback that will be called when the request has completed.
@property (assign) SEL callBack;

@property (readwrite) BOOL isAnonymous;
@property (readonly) BOOL hasSessionToken;
@property (readonly) BOOL hasUserAuthToken;
@property (readonly) BOOL hasCredentials;

/// Initializes a new instance of the HealthVaultRequest class.
/// @param name - the name of the method.
/// @param methodVersion - the version of the method.
/// @param infoSection - the request-specific xml to pass.
/// @param target - callback method owner.
/// @param callBack - the method to call when the request has completed.
///
/// The method name and version must be one of the methods documented in the
/// method reference at:
/// http://developer.healthvault.com/pages/methods/methods.aspx
- (instancetype)initWithMethodName:(NSString *)name
                     methodVersion:(float)methodVersion
                       infoSection:(NSString *)info
                            target:(NSObject *)target
                          callBack:(SEL)callBack;

/// Converts the request to xml representation ready to be submitted to HealthVault service.
/// @returns xml representation of the request.
- (NSString *)toXml:(id<HealthVaultService>)service;

- (void)writeHeader:(NSMutableString *)header forBody:(NSString *)body;
- (void)writeMethodHeaders:(NSMutableString *)header;
- (void)writeRecordHeaders:(NSMutableString *)header;
- (void)writeStandardHeaders:(NSMutableString *)header;
- (void)writeAuthSessionHeader:(NSMutableString *)header;
- (void)writeHashHeader:(NSMutableString *)header forBody:(NSString *)body;

- (void)writeAuth:(NSMutableString *)xml forHeader:(NSString *)header;

@end
