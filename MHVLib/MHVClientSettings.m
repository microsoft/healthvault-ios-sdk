//
// MHVClientSettings.m
// MHVLib
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

#import <UIKit/UIKit.h>
#import "MHVCommon.h"
#import "MHVClientSettings.h"
#import "MHVNetworkReachability.h"

static NSString *const c_element_debug = @"debug";
static NSString *const c_element_appID = @"masterAppID";
static NSString *const c_element_appName = @"appName";
static NSString *const c_element_name = @"name";
static NSString *const c_element_friendlyName = @"friendlyName";
static NSString *const c_element_serviceUrl = @"serviceUrl";
static NSString *const c_element_shellUrl = @"shellUrl";
static NSString *const c_element_environment = @"environment";
static NSString *const c_element_appData = @"appData";
static NSString *const c_element_deviceName = @"deviceName";
static NSString *const c_element_country = @"country";
static NSString *const c_element_language = @"language";
static NSString *const c_element_signinTitle = @"signInTitle";
static NSString *const c_element_signinRetryMessage = @"signInRetryMessage";
static NSString *const c_element_httpTimeout = @"httpTimeout";
static NSString *const c_element_maxAttemptsPerRequest = @"maxAttemptsPerRequest";
static NSString *const c_element_useCachingInStore = @"useCachingInStore";
static NSString *const c_element_autoRequestDelay = @"autoRequestDelay";
static NSString *const c_element_multiInstance = @"isMultiInstanceAware";
static NSString *const c_element_instanceID = @"instanceID";

@interface MHVEnvironmentSettings ()

@property (nonatomic, strong) NSString *appData;

@end

@implementation MHVEnvironmentSettings

- (NSString *)name
{
    if ([NSString isNilOrEmpty:_name])
    {
        _name = @"PPE";
    }

    return _name;
}

- (NSString *)friendlyName
{
    if ([NSString isNilOrEmpty:_friendlyName])
    {
        _friendlyName = @"HealthVault Pre-Production";
    }

    return _friendlyName;
}

- (NSURL *)serviceUrl
{
    if (!_serviceUrl)
    {
        _serviceUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform/wildcat.ashx"];
    }

    return _serviceUrl;
}

- (NSURL *)shellUrl
{
    if (!_shellUrl)
    {
        _shellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    }

    return _shellUrl;
}

- (NSString *)instanceID
{
    if ([NSString isNilOrEmpty:_instanceID])
    {
        return @"1";
    }

    return _instanceID;
}

- (BOOL)hasName
{
    return !([NSString isNilOrEmpty:_name]);
}

- (BOOL)hasInstanceID
{
    return !([NSString isNilOrEmpty:_instanceID]);
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElement:c_element_friendlyName value:self.friendlyName];
    [writer writeElement:c_element_serviceUrl value:self.serviceUrl.absoluteString];
    [writer writeElement:c_element_shellUrl value:self.shellUrl.absoluteString];
    [writer writeElement:c_element_instanceID value:self.instanceID];
    [writer writeRaw:self.appData];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.friendlyName = [reader readStringElement:c_element_friendlyName];

    NSString *serviceUrlString = [reader readStringElement:c_element_serviceUrl];
    if (serviceUrlString)
    {
        self.serviceUrl = [[NSURL alloc] initWithString:serviceUrlString];
    }

    NSString *shellUrlString = [reader readStringElement:c_element_shellUrl];
    if (shellUrlString)
    {
        self.shellUrl = [[NSURL alloc] initWithString:shellUrlString];
    }

    self.instanceID = [reader readStringElement:c_element_instanceID];
    self.appData = [reader readElementRaw:c_element_appData];
}

+ (MHVEnvironmentSettings *)fromInstance:(MHVInstance *)instance
{
    MHVCHECK_NOTNULL(instance);

    MHVEnvironmentSettings *settings = [[MHVEnvironmentSettings alloc] init];
    MHVCHECK_NOTNULL(settings);

    settings.name = instance.name;
    settings.friendlyName = instance.name;
    settings.serviceUrl = [NSURL URLWithString:instance.platformUrl];
    settings.shellUrl = [NSURL URLWithString:instance.shellUrl];
    settings.instanceID = instance.instanceID;

    return settings;
}

- (BOOL)isServiceNetworkReachable
{
    return MHVIsHostNetworkReachable(self.serviceUrl.host);
}

- (BOOL)isShellNetworkReachable
{
    return MHVIsHostNetworkReachable(self.shellUrl.host);
}

@end

@interface MHVClientSettings ()

@property (nonatomic, strong) NSString *appData;

@end

@implementation MHVClientSettings

- (NSArray *)environments
{
    if ([NSArray isNilOrEmpty:_environments])
    {
        _environments = nil;

        NSMutableArray *defaultEnvironments = [[NSMutableArray alloc] init];
        _environments = defaultEnvironments;

        MHVEnvironmentSettings *defaultEnvironment = [[MHVEnvironmentSettings alloc] init];
        [defaultEnvironments addObject:defaultEnvironment];
    }

    return _environments;
}

- (NSString *)deviceName
{
    if ([NSString isNilOrEmpty:_deviceName])
    {
        _deviceName = [[UIDevice currentDevice] name];
    }

    return _deviceName;
}

- (NSString *)country
{
    if ([NSString isNilOrEmpty:_country])
    {
        _country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    }

    return _country;
}

- (NSString *)language
{
    if ([NSString isNilOrEmpty:_language])
    {
        _language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    }

    return _language;
}

- (NSString *)signInControllerTitle
{
    if ([NSString isNilOrEmpty:_signInControllerTitle])
    {
        _signInControllerTitle = NSLocalizedString(@"HealthVault", @"Sign in to HealthVault");
    }

    return _signInControllerTitle;
}

- (NSString *)signInRetryMessage
{
    if ([NSString isNilOrEmpty:_signInRetryMessage])
    {
        _signInRetryMessage = NSLocalizedString(@"Could not sign into HealthVault. Try again?", @"Retry signin message");
    }

    return _signInRetryMessage;
}

- (MHVEnvironmentSettings *)firstEnvironment
{
    return [self.environments firstObject];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _debug = FALSE;
        _isMultiInstanceAware = FALSE;
        _httpTimeout = 60;             // Default timeout in seconds
        _maxAttemptsPerRequest = 3;    // Retry thrice...
    }
    return self;
}

- (void)validateSettings
{
    if ([NSString isNilOrEmpty:_masterAppID])
    {
        [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientEror_InvalidMasterAppID)];
    }
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_debug boolValue:self.debug];
    [writer writeElement:c_element_appID value:self.masterAppID];
    [writer writeElement:c_element_appName value:self.appName];
    [writer writeElement:c_element_multiInstance boolValue:self.isMultiInstanceAware];
    [writer writeElementArray:c_element_environment elements:self.environments];
    [writer writeElement:c_element_deviceName value:self.deviceName];
    [writer writeElement:c_element_language value:self.country];
    [writer writeElement:c_element_language value:self.language];
    [writer writeElement:c_element_signinTitle value:self.signInControllerTitle];
    [writer writeElement:c_element_signinRetryMessage value:self.signInRetryMessage];
    [writer writeElement:c_element_httpTimeout doubleValue:self.httpTimeout];
    [writer writeElement:c_element_maxAttemptsPerRequest intValue:(int)self.maxAttemptsPerRequest];
    [writer writeElement:c_element_useCachingInStore boolValue:self.useCachingInStore];

    [writer writeRaw:self.appData];
}

- (void)deserialize:(XReader *)reader
{
    self.debug = [reader readBoolElement:c_element_debug];
    self.masterAppID = [reader readStringElement:c_element_appID];
    self.appName = [reader readStringElement:c_element_appName];
    self.isMultiInstanceAware = [reader readBoolElement:c_element_multiInstance];

    NSMutableArray *environs = nil;
    environs = [reader readElementArray:c_element_environment asClass:[MHVEnvironmentSettings class]];
    self.environments = environs;

    self.deviceName = [reader readStringElement:c_element_deviceName];
    self.country = [reader readStringElement:c_element_country];
    self.language = [reader readStringElement:c_element_language];
    self.signInControllerTitle = [reader readStringElement:c_element_signinTitle];
    self.signInRetryMessage = [reader readStringElement:c_element_signinRetryMessage];
    self.httpTimeout = [reader readDoubleElement:c_element_httpTimeout];
    self.maxAttemptsPerRequest = [reader readIntElement:c_element_maxAttemptsPerRequest];
    self.useCachingInStore = [reader readBoolElement:c_element_useCachingInStore];

    self.appData = [reader readElementRaw:c_element_appData];
}

- (MHVEnvironmentSettings *)environmentWithName:(NSString *)name
{
    MHVCHECK_NOTNULL(name);

    NSArray *environments = self.environments;
    for (NSUInteger i = 0; i < environments.count; ++i)
    {
        MHVEnvironmentSettings *environment = environments[i];
        if (environment.hasName && [environment.name isEqualToStringCaseInsensitive:name])
        {
            return environment;
        }
    }

    return nil;
}

- (MHVEnvironmentSettings *)environmentAtIndex:(NSUInteger)index
{
    return self.environments[index];
}

- (MHVEnvironmentSettings *)environmentWithInstanceID:(NSString *)instanceID
{
    NSArray *environments = self.environments;

    for (NSUInteger i = 0; i < environments.count; ++i)
    {
        MHVEnvironmentSettings *environment = environments[i];
        if (environment.hasInstanceID && [environment.instanceID isEqualToStringCaseInsensitive:instanceID])
        {
            return environment;
        }
    }

    return nil;
}

+ (MHVClientSettings *)newSettingsFromResource
{
    MHVClientSettings *settings = (MHVClientSettings *)[NSObject newFromResource:@"ClientSettings" withRoot:@"clientSettings" asClass:[MHVClientSettings class]];

    if (!settings)
    {
        settings = [[MHVClientSettings alloc] init];
    }

    return settings;
}

+ (MHVClientSettings *)newDefault
{
    MHVClientSettings *settings = [MHVClientSettings newSettingsFromResource];

    if (!settings)
    {
        settings = [[MHVClientSettings alloc] init]; // Default settings
    }

    return settings;
}

@end
