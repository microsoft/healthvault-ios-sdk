//
// MHVNetworkObserver.h
// healthvault-ios-sdk
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
#import "MHVNetworkObserverProtocol.h"

@interface MHVNetworkObserver : NSObject<MHVNetworkObserverProtocol>

/**
 Creates a new instance of MHVNetworkObserver that observes network connectivity for a given host.

 @param hostName The host, conforming to RFC 1808. For example, in the URL http://www.example.com/index.html, the host is www.example.com.
 @return A new instance of MHVNetworkObserver.
 */
+ (instancetype)observerWithHostName:(NSString *)hostName;


@end


