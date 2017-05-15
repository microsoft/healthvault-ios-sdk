//
// MHVNetworkReachability.h
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
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "MHVCore.h"

BOOL MHVIsHostNetworkReachable(NSString *hostName);

MHVDECLARE_NOTIFICATION(MHVHostReachabilityNotificationName);

@interface MHVHostReachability : NSObject

- (instancetype)initWithHostName:(NSString *)hostName;
- (instancetype)initWithUrl:(NSURL *)url;

@property (readonly, nonatomic, strong) NSString *hostName;
@property (readonly, nonatomic) SCNetworkReachabilityFlags status;
@property (readonly, nonatomic) BOOL isReachable;
@property (readwrite, nonatomic) BOOL isMonitoring;
//
// Returns 0 if no status detectable
//
- (BOOL)refreshStatus;

- (BOOL)startMonitoring;
- (BOOL)stopMonitoring;
//
// Uses [NSNotificationCenter] to broadcast changes. You are passed a reference to the MHVHostReachability that changed
//
- (void)broadcastStatusChange:(SCNetworkConnectionFlags)flags;
//
// Subscribe to network status changes (via) NSNotificationCenter
//
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector;
- (void)removeObserver:(id)notificationObserver;

@end
