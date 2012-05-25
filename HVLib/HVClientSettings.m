//
//  HVClientSettings.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVCommon.h"
#import "HVClientSettings.h"

static NSString* const c_element_debug = @"debug";
static NSString* const c_element_appID = @"masterAppID";
static NSString* const c_element_appName = @"appName";
static NSString* const c_element_serviceUrl = @"serviceUrl";
static NSString* const c_element_shellUrl = @"shellUrl";
static NSString* const c_element_deviceName = @"deviceName";
static NSString* const c_element_country = @"country";
static NSString* const c_element_language = @"language";
static NSString* const c_element_signinTitle = @"signInTitle";
static NSString* const c_element_signinRetryMessage = @"signInRetryMessage";
static NSString* const c_element_httpTimeout = @"httpTimeout";
static NSString* const c_element_useCachingInStore = @"useCachingInStore";

@implementation HVClientSettings

@synthesize debug = m_debug;
@synthesize masterAppID = m_appID;
@synthesize appName = m_appName;
@synthesize serviceUrl = m_serviceUrl;
@synthesize shellUrl = m_shellUrl;
@synthesize deviceName = m_deviceName;
@synthesize country = m_country;
@synthesize language = m_language;
@synthesize signInControllerTitle = m_signInTitle;
@synthesize signinRetryMessage = m_signInRetryMessage;
@synthesize httpTimeout = m_httpTimeout;
@synthesize useCachingInStore = m_useCachingInStore;

-(NSURL *)serviceUrl
{
    if (!m_serviceUrl)
    {
        m_serviceUrl = [[NSURL alloc] initWithString:@"https://platform.healthvault-ppe.com/platform/wildcat.ashx"];
    }
    
    return m_serviceUrl;
}

-(NSURL *)shellUrl
{
    if (!m_shellUrl)
    {
        m_shellUrl = [[NSURL alloc] initWithString:@"https://account.healthvault-ppe.com"];
    }
    
    return m_shellUrl;
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

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_debug = FALSE;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_appID release];
    [m_appName release];
    [m_serviceUrl release];
    [m_shellUrl release];
    [m_deviceName release];
    [m_country release];
    [m_language release];
    
    [m_signInTitle release];
    [m_signInRetryMessage release];
    
    [super dealloc];
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_BOOL(m_debug, c_element_debug);
    HVSERIALIZE_STRING(m_appID, c_element_appID);
    HVSERIALIZE_STRING(m_appName, c_element_appName);
    HVSERIALIZE_URL(m_serviceUrl, c_element_serviceUrl);
    HVSERIALIZE_URL(m_shellUrl, c_element_shellUrl);
    HVSERIALIZE_STRING(m_deviceName, c_element_deviceName);
    HVSERIALIZE_STRING(m_country, c_element_language);
    HVSERIALIZE_STRING(m_language, c_element_language);
    HVSERIALIZE_STRING(m_signInTitle, c_element_signinTitle);
    HVSERIALIZE_STRING(m_signInRetryMessage, c_element_signinRetryMessage);
    HVSERIALIZE_DOUBLE(m_httpTimeout, c_element_httpTimeout);
    HVSERIALIZE_BOOL(m_useCachingInStore, c_element_useCachingInStore);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_BOOL(m_debug, c_element_debug);
    HVDESERIALIZE_STRING(m_appID, c_element_appID);
    HVDESERIALIZE_STRING(m_appName, c_element_appName);
    HVDESERIALIZE_URL(m_serviceUrl, c_element_serviceUrl);
    HVDESERIALIZE_URL(m_shellUrl, c_element_shellUrl);
    HVDESERIALIZE_STRING(m_deviceName, c_element_deviceName);
    HVDESERIALIZE_STRING(m_country, c_element_country);
    HVDESERIALIZE_STRING(m_language, c_element_language);
    HVDESERIALIZE_STRING(m_signInTitle, c_element_signinTitle);
    HVDESERIALIZE_STRING(m_signInRetryMessage, c_element_signinRetryMessage);
    HVDESERIALIZE_DOUBLE(m_httpTimeout, c_element_httpTimeout);
    HVDESERIALIZE_BOOL(m_useCachingInStore, c_element_useCachingInStore);
}

+(HVClientSettings *)newSettingsFromResource
{
    HVClientSettings* settings = (HVClientSettings *) [NSObject newFromResource:@"ClientSettings" withRoot:@"clientSettings" asClass:[HVClientSettings class]];
    
    if (!settings)
    {
        settings = [[HVClientSettings alloc] init];
    }
    
    return settings;
}

@end
