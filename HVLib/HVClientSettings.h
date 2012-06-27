//
//  HVClientSettings.h
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

#import <Foundation/Foundation.h>
#import "XSerializableType.h"

@interface HVEnvironmentSettings : XSerializableType
{
    NSString* m_name;
    NSString* m_friendlyName;
    NSURL* m_serviceUrl;
    NSURL* m_shellUrl;    
}

@property (readwrite, nonatomic, retain) NSString* name;
@property (readwrite, nonatomic, retain) NSString* friendlyName;
@property (readwrite, nonatomic, retain) NSURL* serviceUrl;
@property (readwrite, nonatomic, retain) NSURL* shellUrl;

@end

@interface HVClientSettings : XSerializableType
{
    BOOL m_debug;
    NSString *m_appID;
    NSString *m_appName;
    
    NSArray* m_environments;
    
    NSString *m_deviceName;
    NSString *m_country;
    NSString *m_language;
    
    NSString* m_signInTitle;
    NSString* m_signInRetryMessage;
    
    NSTimeInterval m_httpTimeout;
    NSInteger m_maxAttemptsPerRequest;
    BOOL m_useCachingInStore;
    
    NSTimeInterval m_autoRequestDelay;
}

@property (readwrite, nonatomic) BOOL debug;
@property (readwrite, nonatomic, retain) NSString* masterAppID;
@property (readwrite, nonatomic, retain) NSString* appName;

@property (readwrite, nonatomic, retain) NSArray* environments;

@property (readwrite, nonatomic, retain) NSString* deviceName;
@property (readwrite, nonatomic, retain) NSString* country;
@property (readwrite, nonatomic, retain) NSString* language;

@property (readwrite, nonatomic, retain) NSString* signInControllerTitle;
@property (readwrite, nonatomic, retain) NSString* signinRetryMessage;

@property (readwrite, nonatomic) NSTimeInterval httpTimeout; // Standard timeout in seconds
//
// Set this to > 0 to automatically retry requests if they fail due to network errors
//
@property (readwrite, nonatomic) NSInteger maxAttemptsPerRequest;
@property (readwrite, nonatomic) BOOL useCachingInStore;
//
// If > 0, will automatically delay each request... useful for faking "slow" networks
//
@property (readwrite, nonatomic) NSTimeInterval autoRequestDelay;

@property (readonly, nonatomic) HVEnvironmentSettings* firstEnvironment;

-(HVEnvironmentSettings *) environmentWithName:(NSString *) name;

+(HVClientSettings *) newSettingsFromResource;

@end
