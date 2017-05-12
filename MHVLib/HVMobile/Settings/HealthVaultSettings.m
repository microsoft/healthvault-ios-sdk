//
//  HealthVaultSettings.m
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

#import "MHVCommon.h"
#import "HealthVaultSettings.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVKeychainService.h"

/// Used for unique identification setting in preferences.
#define HEALTHVAULT_SETTINGS_PREFIX @"HealthVault"

/// Used for storing settings when name is not specified.
#define DEFAULT_SETTINGS_NAME @""

@interface HealthVaultSettings ()

@property (nonatomic, strong) id<MHVKeychainServiceProtocol> keychainService;

@end

@implementation HealthVaultSettings

- (id)initWithName: (NSString *)name
{
	if (self = [super init]) {

		self.name = name;
        
        _keychainService = [MHVKeychainService new];
	}

	return self;
}


- (void)save {

	NSUserDefaults *perfs = [NSUserDefaults standardUserDefaults];
	NSString *prefix = [HealthVaultSettings makePrefixForName: self.name];

	[perfs setObject: self.version 
			  forKey: [NSString stringWithFormat: @"%@version", prefix]];

	[perfs setObject: self.applicationId
			  forKey: [NSString stringWithFormat: @"%@applicationId", prefix]];

	[perfs setObject: self.applicationCreationToken
			  forKey: [NSString stringWithFormat: @"%@applicationCreationToken", prefix]];
    
	[perfs setObject: self.authorizationSessionToken
			  forKey: [NSString stringWithFormat: @"%@authorizationSessionToken", prefix]];
    
    [perfs setObject: self.userAuthToken
			  forKey: [NSString stringWithFormat: @"%@userAuthToken", prefix]];
    
    [self.keychainService setString:self.sharedSecret forKey:[NSString stringWithFormat:@"%@sharedSecret", prefix]];
    [self.keychainService setString:self.sessionSharedSecret forKey:[NSString stringWithFormat:@"%@sessionSharedSecret", prefix]];
    
	[perfs setObject: self.country
			  forKey: [NSString stringWithFormat: @"%@country", prefix]];

	[perfs setObject: self.language
			  forKey: [NSString stringWithFormat: @"%@language", prefix]];
        
	[perfs setObject: self.personId.UUIDString
			  forKey: [NSString stringWithFormat: @"%@personId", prefix]];
	
	[perfs setObject: self.recordId.UUIDString
			  forKey: [NSString stringWithFormat: @"%@recordId", prefix]];

	[perfs synchronize];
}

+ (HealthVaultSettings *)loadWithName: (NSString *)name {

	NSUserDefaults *perfs = [NSUserDefaults standardUserDefaults];
	NSString *prefix = [HealthVaultSettings makePrefixForName: name];

	HealthVaultSettings *settings = [HealthVaultSettings new];

	settings.version = [perfs objectForKey: [NSString stringWithFormat: @"%@version", prefix]];

	settings.applicationId = [perfs objectForKey: [NSString stringWithFormat: @"%@applicationId", prefix]];

	settings.applicationCreationToken = [perfs objectForKey: [NSString stringWithFormat: @"%@applicationCreationToken", prefix]];
    settings.authorizationSessionToken = [perfs objectForKey: [NSString stringWithFormat: @"%@authorizationSessionToken", prefix]];
    settings.userAuthToken = [perfs objectForKey: [NSString stringWithFormat: @"%@userAuthToken", prefix]];

    NSString* sessionToken = settings.authorizationSessionToken;
    if ([NSString isNilOrEmpty:sessionToken])
    {
        settings.sharedSecret = nil;
        settings.sessionSharedSecret = nil;
    }
    else 
    {
        id<MHVKeychainServiceProtocol> keychainService = [MHVKeychainService new];
        
        settings.sharedSecret = [keychainService stringForKey:[NSString stringWithFormat:@"%@sharedSecret", prefix]];
        settings.sessionSharedSecret = [keychainService stringForKey:[NSString stringWithFormat:@"%@sessionSharedSecret", prefix]];
    }
    
	settings.country = [perfs objectForKey: [NSString stringWithFormat: @"%@country", prefix]];

	settings.language = [perfs objectForKey: [NSString stringWithFormat: @"%@language", prefix]];

	
	settings.personId = [[NSUUID alloc] initWithUUIDString:[perfs objectForKey: [NSString stringWithFormat: @"%@personId", prefix]]];
	
	settings.recordId = [[NSUUID alloc] initWithUUIDString:[perfs objectForKey: [NSString stringWithFormat: @"%@recordId", prefix]]];


	return settings;
}

+ (NSString *)makePrefixForName: (NSString *)name {

	// Sets default value for name of this is nil.
	if (!name) {
		name = DEFAULT_SETTINGS_NAME;
	}
	NSString *prefix = [NSString stringWithFormat: @"%@%@", HEALTHVAULT_SETTINGS_PREFIX, name];

	return prefix;
}

@end
