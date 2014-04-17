//
//  HVService.h
//  HVLib
//
// Copyright 2014 Microsoft Corp.
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
//
//

#import <Foundation/Foundation.h>
#import "HVHttpTransport.h"
#import "HVCryptographer.h"
#import "Provisioner.h"
#import "HealthVaultRecord.h"
#import "HVClientSettings.h"

@class HealthVaultRequest;

@protocol HealthVaultService <NSObject>

@property (retain) NSString *healthServiceUrl;
@property (retain) NSString *shellUrl;
@property (retain) NSString *authorizationSessionToken;
@property (retain) NSString *sharedSecret;
@property (retain) NSString *sessionSharedSecret;
@property (retain) NSString *masterAppId;
@property (retain) NSString *language;
@property (retain) NSString *country;
@property (retain) NSString* deviceName;
@property (retain) NSString *appIdInstance;
@property (retain) NSString *applicationCreationToken;
@property (retain) NSMutableArray *records;
@property (retain) HealthVaultRecord *currentRecord;
@property (readonly) BOOL isAppCreated;

@property (retain) id<HVHttpTransport> transport;
@property (retain) id<HVCryptographer> cryptographer;
@property (retain) Provisioner* provisioner;

- (NSString *)getApplicationCreationUrl;
- (NSString *)getApplicationCreationUrlGA; // HealthVault global architecture aware
- (NSString *)getUserAuthorizationUrl;

- (void)sendRequest:(HealthVaultRequest *)request;
- (void)authorizeRecords: (NSObject *)target authenticationCompleted: (SEL)authCompleted shellAuthRequired: (SEL)shellAuthRequired;

- (void)performAuthenticationCheck: (NSObject *)target authenticationCompleted: (SEL)authCompleted shellAuthRequired: (SEL)shellAuthRequired;

- (void)saveSettings;
- (void)loadSettings;

-(void) reset;
-(void) applyEnvironmentSettings:(HVEnvironmentSettings *) settings;

@end
