//
// MHVClientSettings.h
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

#import <Foundation/Foundation.h>
#import "XSerializableType.h"
#import "MHVInstance.h"

//
// MHVEnvironmentSettings is used by MHVClientSettings (see below)
//
@interface MHVEnvironmentSettings : XSerializableType
//
// In Xml, properties are in precisely this SEQUENCE
// The element name for each property is listed below
//

//
// <name>
// Optional Environment name
//
@property (readwrite, nonatomic, strong) NSString *name;
//
// <friendlyName>
// Optional. Friendly name for the environment.
//
@property (readwrite, nonatomic, strong) NSString *friendlyName;
//
// <serviceUrl>
// Optional. Url for HealthVault platform
//
@property (readwrite, nonatomic, strong) NSURL *serviceUrl;
//
// <shellUrl>
// Optional. Url for HealthVault Shell
//
@property (readwrite, nonatomic, strong) NSURL *shellUrl;
//
// <instanceID>
// Optional. Instance ID of the targeted HealthVault environment
//
@property (readwrite, nonatomic, strong) NSString *instanceID;
//
// <appData>
// Optional. Can contain arbitrary Xml that you can use as you see fit
// This property gets/set the OUTER Xml for the <appData> element
//
@property (readwrite, nonatomic, strong) NSString *appDataXml;

@property (readonly, nonatomic) BOOL hasName;
@property (readonly, nonatomic) BOOL hasInstanceID;

+ (MHVEnvironmentSettings *)fromInstance:(MHVInstance *)instance;

// -------------------------
//
// Network reachability
//
// -------------------------
- (BOOL)isServiceNetworkReachable;
- (BOOL)isShellNetworkReachable;

@end

// -----------------
//
// Settings for MHVClient.
//
// MHVClient loads ClientSettings from an Xml resource file named ClientSettings.xml
// If not found, creates a default MHVClientSettings that you can configure
//
// -----------------
@interface MHVClientSettings : XSerializableType
// Begin PERSISTED PROPERTIES
//
// ClientSettings.xml contains properties in precisely this SEQUENCE
// The element name for each property is listed below
//
//
// <debug>
// Run in debug mode. Useful if you want to look at wire Xml in the debugger
// Default is false
//
@property (readwrite, nonatomic) BOOL debug;
//
// <masterAppID>
// Required. Master SODA appID
//
@property (readwrite, nonatomic, strong) NSString *masterAppID;
//
// <appName>
// Optional
@property (readwrite, nonatomic, strong) NSString *appName;
//
// <isMultiInstanceAware>
// Is this application globally available?. Default is false
//
@property (readwrite, nonatomic) BOOL isMultiInstanceAware;
//
// <environment>
// Service environments that this environment could run against.
// To create multiple environments, add multiple <enviromnent> elements in the Xml file
// Each <environment> element is of type MHVEnvironmentSettings (see above).
//
@property (readwrite, nonatomic, strong) NSArray *environments;
//
// The name of this device...
// <deviceName>
// Default - uses the [[UIDevice device] name]
//
@property (readwrite, nonatomic, strong) NSString *deviceName;
//
// <country>
// If not specified, uses the current system configured country
//
@property (readwrite, nonatomic, strong) NSString *country;
//
// <language>
// If not specified, uses the current system configured language
//
@property (readwrite, nonatomic, strong) NSString *language;
//
// <signInTitle>
//
@property (readwrite, nonatomic, strong) NSString *signInControllerTitle;
@property (readwrite, nonatomic, strong) NSString *signInRetryMessage;
//
// <httpTimeout>
// Timeout for Http requests in seconds. Default is 60 seconds.
//
@property (readwrite, nonatomic) NSTimeInterval httpTimeout; // Standard timeout in seconds
//
// <maxAttemptsPerRequest>
// Set this to > 0 to automatically retry requests if they fail due to network errors
// Default is 3
//
@property (readwrite, nonatomic) NSInteger maxAttemptsPerRequest;
//
// <useCachingInStore>
// Used for MHVTypeViews. If true, uses NSCache to cache MHVItem* objects in memory
//
@property (readwrite, nonatomic) BOOL useCachingInStore;
//
// <autoRequestDelay>
// If > 0, will automatically delay each request... useful for faking "slow" networks
// Useful for debugging
//
@property (readwrite, nonatomic) NSTimeInterval autoRequestDelay;
//
// Get/Set the outXml for an <appData> element
// <appData> contain arbitray Xml that you can use as you see fit
//
@property (readwrite, nonatomic, strong) NSString *appDataXml;
//
// End PERSISTED PROPERTIES

@property (strong, readonly, nonatomic) MHVEnvironmentSettings *firstEnvironment;

@property (readwrite, nonatomic, strong) NSURL *rootDirectoryPath;

- (void)validateSettings;

- (MHVEnvironmentSettings *)environmentWithName:(NSString *)name;
- (MHVEnvironmentSettings *)environmentAtIndex:(NSUInteger)index;
- (MHVEnvironmentSettings *)environmentWithInstanceID:(NSString *)instanceID;
//
// Load client settings from a resource file named ClientSettings.xml
//
+ (MHVClientSettings *)newSettingsFromResource;
+ (MHVClientSettings *)newDefault;

@end
