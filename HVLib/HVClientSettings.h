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

@interface HVClientSettings : XSerializableType
{
    BOOL m_debug;
    NSString *m_appID;
    NSString *m_appName;
    NSURL *m_serviceUrl;
    NSURL *m_shellUrl;
    NSString *m_deviceName;
    NSString *m_country;
    NSString *m_language;
    
    NSString* m_signInTitle;
    NSString* m_signInRetryMessage;
    
    NSTimeInterval m_httpTimeout;
}

@property (readwrite, nonatomic) BOOL debug;
@property (readwrite, nonatomic, retain) NSString* masterAppID;
@property (readwrite, nonatomic, retain) NSString* appName;
@property (readwrite, nonatomic, retain) NSURL* serviceUrl;
@property (readwrite, nonatomic, retain) NSURL* shellUrl;
@property (readwrite, nonatomic, retain) NSString* deviceName;
@property (readwrite, nonatomic, retain) NSString* country;
@property (readwrite, nonatomic, retain) NSString* language;

@property (readwrite, nonatomic, retain) NSString* signInControllerTitle;
@property (readwrite, nonatomic, retain) NSString* signinRetryMessage;

@property (readwrite, nonatomic) NSTimeInterval httpTimeout;

+(HVClientSettings *) newSettingsFromResource;

@end
