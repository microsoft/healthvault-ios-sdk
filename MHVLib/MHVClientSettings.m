//
//  MHVClientSettings.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString* const c_element_debug = @"debug";
static NSString* const c_element_appID = @"masterAppID";
static NSString* const c_element_appName = @"appName";
static NSString* const c_element_name = @"name";
static NSString* const c_element_friendlyName = @"friendlyName";
static NSString* const c_element_serviceUrl = @"serviceUrl";
static NSString* const c_element_shellUrl = @"shellUrl";
static NSString* const c_element_environment = @"environment";
static NSString* const c_element_appData = @"appData";
static NSString* const c_element_deviceName = @"deviceName";
static NSString* const c_element_country = @"country";
static NSString* const c_element_language = @"language";
static NSString* const c_element_signinTitle = @"signInTitle";
static NSString* const c_element_signinRetryMessage = @"signInRetryMessage";
static NSString* const c_element_httpTimeout = @"httpTimeout";
static NSString* const c_element_maxAttemptsPerRequest = @"maxAttemptsPerRequest";
static NSString* const c_element_useCachingInStore = @"useCachingInStore";
static NSString* const c_element_autoRequestDelay = @"autoRequestDelay";
static NSString* const c_element_multiInstance = @"isMultiInstanceAware";
static NSString* const c_element_instanceID = @"instanceID";

@implementation MHVEnvironmentSettings

@synthesize name = m_name;
-(NSString *)name
{
    if ([NSString isNilOrEmpty:m_name])
    {
        self.name = @"PPE";
    }
    
    return m_name;
}

@synthesize friendlyName = m_friendlyName;
-(NSString *)friendlyName
{
    if ([NSString isNilOrEmpty:m_friendlyName])
    {
        self.friendlyName = @"HealthVault Pre-Production";
    }
    
    return m_friendlyName;
}

@synthesize serviceUrl = m_serviceUrl;
-(NSURL *)serviceUrl
{
    if (!m_serviceUrl)
    {
        m_serviceUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform/wildcat.ashx"];
    }
    
    return m_serviceUrl;
}

@synthesize shellUrl = m_shellUrl;
-(NSURL *)shellUrl
{
    if (!m_shellUrl)
    {
        m_shellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    }
    
    return m_shellUrl;
}

@synthesize instanceID = m_instanceID;
-(NSString *)instanceID
{
    if ([NSString isNilOrEmpty:m_instanceID])
    {
        return @"1";
    }
    
    return m_instanceID;
}

@synthesize appDataXml = m_appData;

-(BOOL)hasName
{
    return !([NSString isNilOrEmpty:m_name]);
}

-(BOOL)hasInstanceID
{
    return !([NSString isNilOrEmpty:m_instanceID]);
}


-(void) serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:m_name];
    [writer writeElement:c_element_friendlyName value:m_friendlyName];
    [writer writeElement:c_element_serviceUrl value:m_serviceUrl.absoluteString];
    [writer writeElement:c_element_shellUrl value:m_shellUrl.absoluteString];
    [writer writeElement:c_element_instanceID value:m_instanceID];
    [writer writeRaw:m_appData];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readStringElement:c_element_name];
    m_friendlyName = [reader readStringElement:c_element_friendlyName];
    
    NSString* serviceUrlString = [reader readStringElement:c_element_serviceUrl];
    if (serviceUrlString)
    {
        m_serviceUrl = [[NSURL alloc] initWithString:serviceUrlString];
    }
    
    NSString* shellUrlString = [reader readStringElement:c_element_shellUrl];
    if (shellUrlString)
    {
        m_shellUrl = [[NSURL alloc] initWithString:shellUrlString];
    }
    
    m_instanceID = [reader readStringElement:c_element_instanceID];
    m_appData = [reader readElementRaw:c_element_appData];
}

+(MHVEnvironmentSettings *)fromInstance:(MHVInstance *)instance
{
    HVCHECK_NOTNULL(instance);
    
    MHVEnvironmentSettings* settings = [[MHVEnvironmentSettings alloc] init];
    HVCHECK_NOTNULL(settings);
    
    settings.name = instance.name;
    settings.friendlyName = instance.name;
    settings.serviceUrl = [NSURL URLWithString:instance.platformUrl];
    settings.shellUrl = [NSURL URLWithString:instance.shellUrl];
    settings.instanceID = instance.instanceID;
    
    return settings;
    
LError:
    return nil;
}


-(BOOL)isServiceNetworkReachable
{
    return HVIsHostNetworkReachable(self.serviceUrl.host);
}

-(BOOL)isShellNetworkReachable
{
    return HVIsHostNetworkReachable(self.shellUrl.host);
}

@end

@implementation MHVClientSettings

@synthesize debug = m_debug;
@synthesize masterAppID = m_appID;
@synthesize appName = m_appName;
@synthesize isMultiInstanceAware = m_isMultiInstanceAware;
@synthesize environments = m_environments;
@synthesize deviceName = m_deviceName;
@synthesize country = m_country;
@synthesize language = m_language;
@synthesize signInControllerTitle = m_signInTitle;
@synthesize signinRetryMessage = m_signInRetryMessage;
@synthesize httpTimeout = m_httpTimeout;
@synthesize maxAttemptsPerRequest = m_maxAttemptsPerRequest;
@synthesize useCachingInStore = m_useCachingInStore;
@synthesize autoRequestDelay = m_autoRequestDelay;
@synthesize appDataXml = m_appData;

-(NSArray *)environments
{
    if ([NSArray isNilOrEmpty:m_environments])
    {
        m_environments = nil;
        
        NSMutableArray* defaultEnvironments = [[NSMutableArray alloc] init];
        m_environments = defaultEnvironments;

        MHVEnvironmentSettings* defaultEnvironment = [[MHVEnvironmentSettings alloc] init];
        [defaultEnvironments addObject:defaultEnvironment];
    }
    
    return m_environments;
}

-(NSString *)deviceName
{
    if ([NSString isNilOrEmpty:m_deviceName])
    {
        m_deviceName = [[UIDevice currentDevice] name];
    }
    
    return m_deviceName;
}

-(NSString *)country
{
   if ([NSString isNilOrEmpty:m_country])
   {
       m_country = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
   }
    
    return m_country;
}

-(NSString *) language
{
    if ([NSString isNilOrEmpty:m_language])
    {
        m_language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    }
    
    return m_language;
}

-(NSString *)signInControllerTitle
{
    if ([NSString isNilOrEmpty:m_signInTitle])
    {
        m_signInTitle = NSLocalizedString(@"HealthVault", @"Sign in to HealthVault");
    }
    
    return m_signInTitle;
}

-(NSString *) signinRetryMessage
{
    if ([NSString isNilOrEmpty:m_signInRetryMessage])
    {
        m_signInRetryMessage = NSLocalizedString(@"Could not sign into HealthVault. Try again?", @"Retry signin message");
    }
    
    return m_signInRetryMessage;
}

-(MHVEnvironmentSettings *)firstEnvironment
{
    return [self.environments objectAtIndex:0];
}

@synthesize rootDirectoryPath = m_rootDirectoryPath;

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_debug = FALSE;
    m_isMultiInstanceAware = FALSE;
    m_httpTimeout = 60;             // Default timeout in seconds
    m_maxAttemptsPerRequest = 3;    // Retry thrice...
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(void)validateSettings
{
    if ([NSString isNilOrEmpty:m_appID])
    {
        [MHVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientEror_InvalidMasterAppID)];
    }
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElement:c_element_debug boolValue:m_debug];
    [writer writeElement:c_element_appID value:m_appID];
    [writer writeElement:c_element_appName value:m_appName];
    [writer writeElement:c_element_multiInstance boolValue:m_isMultiInstanceAware];
    [writer writeElementArray:c_element_environment elements:m_environments];
    [writer writeElement:c_element_deviceName value:m_deviceName];
    [writer writeElement:c_element_language value:m_country];
    [writer writeElement:c_element_language value:m_language];
    [writer writeElement:c_element_signinTitle value:m_signInTitle];
    [writer writeElement:c_element_signinRetryMessage value:m_signInRetryMessage];
    [writer writeElement:c_element_httpTimeout doubleValue:m_httpTimeout];
    [writer writeElement:c_element_maxAttemptsPerRequest intValue:(int)m_maxAttemptsPerRequest];
    [writer writeElement:c_element_useCachingInStore boolValue:m_useCachingInStore];
    [writer writeElement:c_element_autoRequestDelay doubleValue:m_autoRequestDelay];
    
    [writer writeRaw:m_appData];
}

-(void)deserialize:(XReader *)reader
{
    m_debug = [reader readBoolElement:c_element_debug];
    m_appID = [reader readStringElement:c_element_appID];
    m_appName = [reader readStringElement:c_element_appName];
    m_isMultiInstanceAware = [reader readBoolElement:c_element_multiInstance];
    
    NSMutableArray* environs = nil;
    environs = [reader readElementArray:c_element_environment asClass:[MHVEnvironmentSettings class]];
    self.environments = environs;
    
    m_deviceName = [reader readStringElement:c_element_deviceName];
    m_country = [reader readStringElement:c_element_country];
    m_language = [reader readStringElement:c_element_language];
    m_signInTitle = [reader readStringElement:c_element_signinTitle];
    m_signInRetryMessage = [reader readStringElement:c_element_signinRetryMessage];
    m_httpTimeout = [reader readDoubleElement:c_element_httpTimeout];
    m_maxAttemptsPerRequest = [reader readIntElement:c_element_maxAttemptsPerRequest];
    m_useCachingInStore = [reader readBoolElement:c_element_useCachingInStore];
    m_autoRequestDelay = [reader readDoubleElement:c_element_autoRequestDelay];
    
    m_appData = [reader readElementRaw:c_element_appData];
}

-(MHVEnvironmentSettings *)environmentWithName:(NSString *)name
{
    HVCHECK_NOTNULL(name);
    
    NSArray* environments = self.environments;
    for (NSUInteger i = 0, count = environments.count; i < count; ++i)
    {
        MHVEnvironmentSettings* environment = [environments objectAtIndex:i];
        if (environment.hasName && [environment.name isEqualToStringCaseInsensitive:name])
        {
            return environment;
        }
    }
    
LError:
    return nil;
}

-(MHVEnvironmentSettings *)environmentAtIndex:(NSUInteger)index
{
    return [m_environments objectAtIndex:index];
}

-(MHVEnvironmentSettings *)environmentWithInstanceID:(NSString *)instanceID
{
    NSArray* environments = self.environments;
    for (NSUInteger i = 0, count = environments.count; i < count; ++i)
    {
        MHVEnvironmentSettings* environment = [environments objectAtIndex:i];
        if (environment.hasInstanceID && [environment.instanceID isEqualToStringCaseInsensitive:instanceID])
        {
            return environment;
        }
    }
    
    return nil;
}

+(MHVClientSettings *)newSettingsFromResource
{
    MHVClientSettings* settings = (MHVClientSettings *) [NSObject newFromResource:@"ClientSettings" withRoot:@"clientSettings" asClass:[MHVClientSettings class]];
    
    if (!settings)
    {
        settings = [[MHVClientSettings alloc] init];
    }
    
    return settings;
}

+(MHVClientSettings *)newDefault
{
    MHVClientSettings* settings = [MHVClientSettings newSettingsFromResource];
    if (!settings)
    {
        settings = [[MHVClientSettings alloc] init]; // Default settings
    }
    return settings;
}

@end
